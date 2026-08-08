"""Transaction comment service."""

from __future__ import annotations

from typing import Any
from uuid import UUID

import structlog
from sqlalchemy import Select, and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError, CommonErrorCode, NotFoundError, TransactionErrorCode
from app.models.transaction import Transaction, TransactionComment
from app.models.user import User
from app.utils.identicon import default_avatar_url

logger = structlog.get_logger(__name__)


class TransactionCommentService:
    """Service for transaction comment operations."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def _can_access_transaction_comments(self, transaction_id: UUID, user_uuid: UUID) -> Transaction:
        """Check if user can access transaction comments.

        Access is granted if:
        1. User is the transaction owner, OR
        2. Transaction is linked to a space the user is a member of.

        Returns the transaction if access is granted, raises NotFoundError otherwise.
        """
        from app.models.shared_space import SpaceMember, SpaceTransaction

        # Check ownership first (fast path)
        tx_query = select(Transaction).where(Transaction.uuid == transaction_id)
        tx_result = await self.db.execute(tx_query)
        transaction = tx_result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("Transaction")

        if transaction.user_uuid == user_uuid:
            return transaction

        # Check space membership: is the transaction linked to any space the user belongs to?
        space_access_query = (
            select(SpaceTransaction.id)
            .join(SpaceMember, SpaceMember.space_id == SpaceTransaction.space_id)
            .where(
                SpaceTransaction.transaction_id == transaction_id,
                SpaceMember.user_uuid == user_uuid,
                SpaceMember.status == "ACCEPTED",
            )
            .limit(1)
        )
        space_result = await self.db.execute(space_access_query)
        if space_result.scalar_one_or_none() is not None:
            return transaction

        raise NotFoundError("Transaction")

    async def _get_space_member_uuids(self, transaction_id: UUID) -> set[str]:
        """UUIDs of every ACCEPTED member of the shared spaces a transaction is
        linked to (excluding nobody; the commenter is filtered upstream).
        """
        from app.models.shared_space import SpaceMember, SpaceTransaction

        result = await self.db.execute(
            select(SpaceMember.user_uuid)
            .join(SpaceTransaction, SpaceTransaction.space_id == SpaceMember.space_id)
            .where(
                SpaceTransaction.transaction_id == transaction_id,
                SpaceMember.status == "ACCEPTED",
            )
        )
        return {str(uuid) for (uuid,) in result.all()}

    async def get_comments_for_transaction(self, transaction_id: UUID, user_uuid: UUID) -> list[dict[str, Any]]:
        """Get transaction comments list

        Args:
            transaction_id: Transaction ID
            user_uuid: Current user ID

        Returns:
            List of comments
        """
        # Verify access permission (owner or space member)
        await self._can_access_transaction_comments(transaction_id, user_uuid)

        # Query comments and related user information
        query = (
            select(
                TransactionComment,
                User.username.label("user_name"),
                User.avatar_url.label("user_avatar_url"),
            )
            .join(User, TransactionComment.user_uuid == User.id)
            .where(TransactionComment.transaction_id == transaction_id)
            .order_by(TransactionComment.created_at.asc())
        )

        result = await self.db.execute(query)
        comments_data = result.all()

        if not comments_data:
            return []

        # Batch-load user info for the explicit reply targets (replied_to_user_uuid
        # column). The reply target is always persisted at creation time, so no
        # parent-author fallback is needed.
        replied_to_ids = {c.replied_to_user_uuid for c, _, _ in comments_data if c.replied_to_user_uuid}
        user_by_uuid: dict[Any, str | None] = {}
        if replied_to_ids:
            user_query = select(User.uuid, User.username).where(User.uuid.in_(replied_to_ids))
            for uuid, uname in (await self.db.execute(user_query)).all():
                user_by_uuid[uuid] = uname

        # Format comment data
        formatted_comments = []
        for comment, user_name, user_avatar_url in comments_data:
            # Reply target comes straight from the persisted column.
            replied_to_user_uuid = comment.replied_to_user_uuid
            replied_to_user_name = user_by_uuid.get(replied_to_user_uuid)

            formatted_comments.append(
                {
                    "id": str(comment.uuid),
                    "transactionId": str(comment.transaction_id),
                    "userId": str(comment.user_uuid),
                    "userName": user_name or "default_name",
                    "userAvatarUrl": user_avatar_url or default_avatar_url(comment.user_uuid),
                    "parentCommentId": str(comment.parent_comment_id) if comment.parent_comment_id else None,
                    "commentText": comment.comment_text,
                    "repliedToUserId": str(replied_to_user_uuid) if replied_to_user_uuid else None,
                    "repliedToUserName": replied_to_user_name,
                    "createdAt": comment.created_at.isoformat(),
                    "updatedAt": comment.updated_at.isoformat() if comment.updated_at else None,
                }
            )

        return formatted_comments

    async def add_comment(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
        comment_text: str,
        parent_comment_id: UUID | None = None,
        mentioned_user_ids: list[str] | None = None,
        commenter_username: str = "Unknown",
        replied_to_user_id: UUID | None = None,
    ) -> dict[str, Any]:
        """Add transaction comment

        Args:
            transaction_id: Transaction ID
            user_uuid: User ID
            comment_text: Comment content
            parent_comment_id: Optional parent comment ID
            mentioned_user_ids: Optional list of mentioned user UUIDs
            commenter_username: Username of the commenter for notification
            replied_to_user_id: Explicit user the reply is directed at. In the
                flattened single-level reply layout the parent comment is the
                thread's root, whose author may differ from the user the reply
                targets; persisting the explicit target keeps the display
                (and notification) accurate. When omitted, the parent
                comment's author is the creation-time default so replies
                always carry a notification target.

        Returns:
            New comment dictionary
        """
        # Validate comment content
        if not comment_text or not comment_text.strip():
            logger.warning(
                "empty_comment_rejected",
                user_uuid=user_uuid,
                transaction_id=transaction_id,
            )
            raise BusinessError("Comment content cannot be empty", TransactionErrorCode.TRANSACTION_COMMENT_NULL)

        # Validate transaction exists and user has access
        transaction = await self._can_access_transaction_comments(transaction_id, user_uuid)

        # If there is a parent comment, validate the parent comment
        parent_comment: TransactionComment | None = None
        if parent_comment_id is not None:
            parent_comment_query = select(TransactionComment).where(
                and_(
                    TransactionComment.id == parent_comment_id,
                    TransactionComment.transaction_id == transaction_id,
                )
            )
            parent_comment_result = await self.db.execute(parent_comment_query)
            parent_comment = parent_comment_result.scalar_one_or_none()

            if not parent_comment:
                raise BusinessError("Parent comment does not exist", TransactionErrorCode.INVALID_PARENT_COMMENT_ID)

            # Ensure the parent comment is not a child comment (single-level reply structure)
            if parent_comment.parent_comment_id is not None:
                raise BusinessError("Cannot reply to a child comment", TransactionErrorCode.INVALID_PARENT_COMMENT_ID)

        # Create new comment
        # Reply target resolution: the explicit user the client tapped wins;
        # when the client omits it, the parent comment's author is the
        # creation-time default so replies ALWAYS carry a notification target
        # (never a legacy-data fallback — the value is applied on insert and
        # stays in the column for all future reads).
        resolved_reply_target: UUID | None = replied_to_user_id
        if resolved_reply_target is None and parent_comment is not None:
            resolved_reply_target = parent_comment.user_uuid
        if resolved_reply_target == user_uuid and parent_comment is not None:
            last_child_query = (
                select(TransactionComment.user_uuid)
                .where(
                    and_(
                        TransactionComment.parent_comment_id == parent_comment.id,
                        TransactionComment.user_uuid != user_uuid,
                    )
                )
                .order_by(TransactionComment.created_at.desc())
                .limit(1)
            )
            last_child_res = await self.db.execute(last_child_query)
            last_author = last_child_res.scalar_one_or_none()
            resolved_reply_target = last_author

        new_comment = TransactionComment(
            transaction_id=transaction_id,
            user_uuid=user_uuid,
            comment_text=comment_text,
            parent_comment_id=parent_comment_id,
            replied_to_user_uuid=resolved_reply_target,
        )

        # Flush (not commit): the comment and its notifications are ONE logical
        # operation and must commit atomically — a failure while creating
        # notifications must not leave an orphan comment behind.
        self.db.add(new_comment)
        await self.db.flush()
        await self.db.refresh(new_comment)

        logger.info(
            "comment_created",
            user_uuid=user_uuid,
            transaction_id=transaction_id,
            comment_id=new_comment.uuid,
            is_reply=bool(parent_comment_id),
        )

        # Collect users to notify: the transaction owner, the reply target
        # (explicit, or creation-time default = parent's author), every
        # ACCEPTED member of a linked shared space (a comment in a group is
        # group-visible), plus anyone mentioned in the text. The commenter
        # never notifies themselves.
        transaction_owner_uuid = str(transaction.user_uuid)
        space_member_uuids = await self._get_space_member_uuids(transaction_id)
        users_to_notify: set[str] = set(mentioned_user_ids or [])
        if resolved_reply_target is not None:
            users_to_notify.add(str(resolved_reply_target))
        users_to_notify.add(transaction_owner_uuid)
        users_to_notify.update(space_member_uuids)

        users_to_notify.discard(str(user_uuid))

        if users_to_notify:
            await self._notify_mentioned_users(
                mentioned_user_ids=list(users_to_notify),
                transaction_id=transaction_id,
                comment_id=new_comment.uuid,
                commenter_username=commenter_username,
                comment_text=comment_text,
                reply_target_uuids=({str(resolved_reply_target)} if resolved_reply_target is not None else set()),
                transaction_owner_uuid=transaction_owner_uuid,
                space_member_uuids=space_member_uuids,
            )

        # Single commit point: comment + notifications are persisted together.
        await self.db.commit()

        # Broadcast real-time comment created event (best-effort, after commit)
        await self._broadcast_comment_event(
            transaction_id=transaction_id,
            comment_id=new_comment.uuid,
            action="created",
        )

        # Get complete comment information (including user information)
        query = (
            select(
                TransactionComment,
                User.username.label("user_name"),
                User.avatar_url.label("user_avatar_url"),
            )
            .join(User, TransactionComment.user_uuid == User.id)
            .where(TransactionComment.id == new_comment.id)
        )

        result = await self.db.execute(query)
        comment_data = result.first()

        if not comment_data:
            raise BusinessError("Failed to retrieve new comment data", TransactionErrorCode.STORE_COMMENT_FAILED)

        comment, user_name, user_avatar_url = comment_data

        # Reply target resolution is the value persisted on insert above
        # (explicit client target, or the creation-time default = parent
        # author); the display and the notification always agree with it.
        replied_to_user_uuid: str | None = None
        replied_to_user_name = None

        if resolved_reply_target is not None:
            reply_context_query = select(User.username).where(User.uuid == resolved_reply_target)
            reply_context_result = await self.db.execute(reply_context_query)
            replied_to_user_name = reply_context_result.scalar_one_or_none()
            replied_to_user_uuid = str(resolved_reply_target)

        return {
            "id": str(comment.id),
            "transactionId": str(comment.transaction_id),
            "userId": str(comment.user_uuid),
            "userName": user_name or "Anonymous",
            "userAvatarUrl": user_avatar_url or default_avatar_url(comment.user_uuid),
            "parentCommentId": str(comment.parent_comment_id) if comment.parent_comment_id else None,
            "commentText": comment.comment_text,
            "repliedToUserId": replied_to_user_uuid,
            "repliedToUserName": replied_to_user_name,
            "createdAt": comment.created_at.isoformat(),
            "updatedAt": comment.updated_at.isoformat() if comment.updated_at else None,
        }

    async def _notify_mentioned_users(
        self,
        mentioned_user_ids: list[str],
        transaction_id: UUID,
        comment_id: UUID,
        commenter_username: str,
        comment_text: str,
        reply_target_uuids: set[str] | None = None,
        transaction_owner_uuid: str | None = None,
        space_member_uuids: set[str] | None = None,
    ) -> None:
        """Create notifications for mentioned users and push via WebSocket.

        Notification rows are added to the caller's session and committed by the
        caller — never here — so a comment and its notifications share one
        atomic transaction. WebSocket pushes remain best-effort.

        Args:
            mentioned_user_ids: Users to notify (mentions + reply targets
                + transaction owner + space members).
            transaction_id: Transaction the comment belongs to.
            comment_id: Comment that triggered the notification.
            commenter_username: Display name of the comment author.
            comment_text: Comment body (used for the notification preview).
            reply_target_uuids: User IDs the comment is directly addressed to;
                they get the "replied to your comment" title.
            transaction_owner_uuid: Owner of the transaction; they get the
                "commented on your transaction" title for direct comments.
            space_member_uuids: Members of the linked shared spaces; they get
                the "commented on a shared transaction" title.
        """
        from app.core.ws_manager import ws_manager
        from app.models.notification import Notification

        target_path = f"/home/transaction/{transaction_id}?commentId={comment_id}"

        reply_targets: set[str] = set(reply_target_uuids or ())
        space_members: set[str] = set(space_member_uuids or ())
        created_notifications: dict[str, Notification] = {}

        for mentioned_id in mentioned_user_ids:
            try:
                mentioned_uuid = UUID(mentioned_id)
            except ValueError:
                continue

            mentioned_id_str = str(mentioned_uuid)
            if mentioned_id_str in reply_targets:
                title = f"{commenter_username} 回复了你的评论"
                comment_kind = "reply"
            elif transaction_owner_uuid is not None and mentioned_id_str == transaction_owner_uuid:
                title = f"{commenter_username} 评论了你的账单"
                comment_kind = "owner"
            elif mentioned_id_str in space_members:
                title = f"{commenter_username} 在共享账单中发表了评论"
                comment_kind = "space"
            else:
                title = f"{commenter_username} 提到了你"
                comment_kind = "mention"

            notification_data = {
                "transactionId": str(transaction_id),
                "transaction_id": str(transaction_id),
                "commentId": str(comment_id),
                "comment_id": str(comment_id),
                "commentKind": comment_kind,
                "target_path": target_path,
                "commenter": commenter_username,
            }

            # Create notification record
            notification = Notification(
                user_uuid=mentioned_uuid,
                type="bill_comment",
                title=title,
                content=comment_text[:100],
                data=notification_data,
            )
            self.db.add(notification)
            created_notifications[mentioned_id_str] = notification

        await self.db.flush()

        # Push via WebSocket (best effort, don't fail the comment)
        for mentioned_id in mentioned_user_ids:
            try:
                try:
                    mentioned_uuid = UUID(mentioned_id)
                except ValueError:
                    continue
                mentioned_id_str = str(mentioned_uuid)

                is_target_reply = mentioned_id_str in reply_targets
                if is_target_reply:
                    title = f"{commenter_username} 回复了你的评论"
                    comment_kind = "reply"
                elif transaction_owner_uuid is not None and mentioned_id_str == transaction_owner_uuid:
                    title = f"{commenter_username} 评论了你的账单"
                    comment_kind = "owner"
                elif mentioned_id_str in space_members:
                    title = f"{commenter_username} 在共享账单中发表了评论"
                    comment_kind = "space"
                else:
                    title = f"{commenter_username} 提到了你"
                    comment_kind = "mention"

                notification_obj = created_notifications.get(mentioned_id_str)

                await ws_manager.send_notification(
                    mentioned_id_str,
                    {
                        "id": str(notification_obj.id) if notification_obj is not None else None,
                        "type": "bill_comment",
                        "title": title,
                        "message": comment_text[:100],
                        "data": {
                            "transactionId": str(transaction_id),
                            "commentId": str(comment_id),
                            "commentKind": comment_kind,
                            "target_path": target_path,
                        },
                    },
                )
            except Exception as e:  # noqa: BLE001 - best-effort push, don't fail the comment
                logger.warning("ws_push_failed", user_uuid=str(mentioned_id), error=str(e))

    async def delete_comment(self, comment_id: UUID, user_uuid: UUID) -> bool:
        """Delete comment

        Args:
            comment_id: Comment ID
            user_uuid: User UUID

        Returns:
            Whether the comment was deleted successfully
        """
        # Query comment
        query = select(TransactionComment).where(TransactionComment.id == comment_id)
        result = await self.db.execute(query)
        comment = result.scalar_one_or_none()

        if not comment:
            return False

        # Verify permissions
        if comment.user_uuid != user_uuid:
            raise BusinessError("You do not have permission to delete this comment", CommonErrorCode.PERMISSION_DENIED)

        target_tx_id = comment.transaction_id

        # Delete comment (if foreign key cascade delete, child comments will be automatically deleted)
        await self.db.delete(comment)
        await self.db.commit()

        # Broadcast real-time comment deleted event
        await self._broadcast_comment_event(
            transaction_id=target_tx_id,
            comment_id=comment_id,
            action="deleted",
        )

        return True

    async def _broadcast_comment_event(
        self,
        transaction_id: UUID,
        comment_id: UUID,
        action: str,
    ) -> None:
        """Broadcast real-time comment created/deleted event to all space members / transaction participants."""
        from app.core.ws_manager import ws_manager
        from app.models.shared_space import SpaceMember, SpaceTransaction
        from app.models.transaction import Transaction

        user_uuids: set[str] = set()

        # 1. Add transaction owner
        tx_query = select(Transaction.user_uuid).where(Transaction.uuid == transaction_id)
        tx_res = await self.db.execute(tx_query)
        tx_user_uuid = tx_res.scalar_one_or_none()
        if tx_user_uuid:
            user_uuids.add(str(tx_user_uuid))

        # 2. Add all space members for spaces linked to this transaction
        space_members_query = (
            select(SpaceMember.user_uuid)
            .join(SpaceTransaction, SpaceMember.space_id == SpaceTransaction.space_id)
            .where(SpaceTransaction.transaction_id == transaction_id)
        )
        sm_res = await self.db.execute(space_members_query)
        for uid in sm_res.scalars():
            if uid:
                user_uuids.add(str(uid))

        if user_uuids:
            event_payload = {
                "type": "comment_updated",
                "data": {
                    "action": action,
                    "transactionId": str(transaction_id),
                    "transaction_id": str(transaction_id),
                    "commentId": str(comment_id),
                    "comment_id": str(comment_id),
                },
            }
            await ws_manager.broadcast(list(user_uuids), event_payload)
