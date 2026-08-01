"""Transaction comment service."""

from __future__ import annotations

from typing import Any
from uuid import UUID

import structlog
from sqlalchemy import Select, and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError, NotFoundError
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
        tx_query = select(Transaction).where(Transaction.id == transaction_id)
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
            .join(User, TransactionComment.user_uuid == User.uuid)
            .where(TransactionComment.transaction_id == transaction_id)
            .order_by(TransactionComment.created_at.asc())
        )

        result = await self.db.execute(query)
        comments_data = result.all()

        if not comments_data:
            return []

        # Batch-load parent comments in one query to avoid N+1.
        parent_ids = {c.parent_comment_id for c, _, _ in comments_data if c.parent_comment_id}
        parent_by_id: dict[Any, tuple[Any, str | None]] = {}
        if parent_ids:
            parent_query = (
                select(TransactionComment, User.username)
                .join(User, TransactionComment.user_uuid == User.uuid)
                .where(TransactionComment.id.in_(parent_ids))
            )
            parent_result = await self.db.execute(parent_query)
            for pc, pn in parent_result.all():
                parent_by_id[pc.id] = (pc, pn)

        # Format comment data
        formatted_comments = []
        for comment, user_name, user_avatar_url in comments_data:
            # If there is a parent comment, get the information of the user being replied to
            replied_to_user_uuid = None
            replied_to_user_name = None

            if comment.parent_comment_id and comment.parent_comment_id in parent_by_id:
                parent_comment, parent_user_name = parent_by_id[comment.parent_comment_id]
                replied_to_user_uuid = str(parent_comment.user_uuid)
                replied_to_user_name = parent_user_name

            formatted_comments.append(
                {
                    "id": str(comment.id),
                    "transactionId": str(comment.transaction_id),
                    "userId": str(comment.user_uuid),
                    "userName": user_name or "default_name",
                    "userAvatarUrl": user_avatar_url or default_avatar_url(comment.user_uuid),
                    "parentCommentId": str(comment.parent_comment_id) if comment.parent_comment_id else None,
                    "commentText": comment.comment_text,
                    "repliedToUserId": replied_to_user_uuid,
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
        parent_comment_id: int | None = None,
        mentioned_user_ids: list[str] | None = None,
        commenter_username: str = "Unknown",
    ) -> dict[str, Any]:
        """Add transaction comment

        Args:
            transaction_id: Transaction ID
            user_uuid: User ID
            comment_text: Comment content
            parent_comment_id: Optional parent comment ID
            mentioned_user_ids: Optional list of mentioned user UUIDs
            commenter_username: Username of the commenter for notification

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
            raise BusinessError("Comment content cannot be empty", "TRANSACTION_COMMENT_NULL")

        # Validate transaction exists and user has access
        await self._can_access_transaction_comments(transaction_id, user_uuid)

        # If there is a parent comment, validate the parent comment
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
                raise BusinessError("Parent comment does not exist", "INVALID_PARENT_COMMENT_ID")

            # Ensure the parent comment is not a child comment (single-level reply structure)
            if parent_comment.parent_comment_id is not None:
                raise BusinessError("Cannot reply to a child comment", "INVALID_PARENT_COMMENT_ID")

        # Create new comment
        new_comment = TransactionComment(
            transaction_id=transaction_id,
            user_uuid=user_uuid,
            comment_text=comment_text,
            parent_comment_id=parent_comment_id,
        )

        self.db.add(new_comment)
        await self.db.commit()
        await self.db.refresh(new_comment)

        logger.info(
            "comment_created",
            user_uuid=user_uuid,
            transaction_id=transaction_id,
            comment_id=new_comment.id,
            is_reply=bool(parent_comment_id),
        )

        # Collect users to notify: mentioned + parent comment author (on reply)
        users_to_notify: set[str] = set(mentioned_user_ids or [])
        if parent_comment_id is not None:
            # Notify the parent comment's author that someone replied
            parent_author_query = select(TransactionComment.user_uuid).where(
                TransactionComment.id == parent_comment_id
            )
            parent_author_result = await self.db.execute(parent_author_query)
            parent_author_uuid = parent_author_result.scalar_one_or_none()
            if parent_author_uuid:
                users_to_notify.add(str(parent_author_uuid))

        # Don't notify the commenter themselves
        users_to_notify.discard(str(user_uuid))

        if new_comment.id is None:
            raise RuntimeError("Comment id is missing after insert")
        comment_id_int = int(new_comment.id)

        if users_to_notify:
            await self._notify_mentioned_users(
                mentioned_user_ids=list(users_to_notify),
                transaction_id=transaction_id,
                comment_id=comment_id_int,
                commenter_username=commenter_username,
                comment_text=comment_text,
                parent_author_uuid=str(parent_author_uuid)
                if parent_comment_id is not None and parent_author_uuid
                else None,
            )

        # Broadcast real-time comment created event
        await self._broadcast_comment_event(
            transaction_id=transaction_id,
            comment_id=comment_id_int,
            action="created",
        )

        # Get complete comment information (including user information)
        query = (
            select(
                TransactionComment,
                User.username.label("user_name"),
                User.avatar_url.label("user_avatar_url"),
            )
            .join(User, TransactionComment.user_uuid == User.uuid)
            .where(TransactionComment.id == new_comment.id)
        )

        result = await self.db.execute(query)
        comment_data = result.first()

        if not comment_data:
            raise BusinessError("Failed to retrieve new comment data", "STORE_COMMENT_FAILED")

        comment, user_name, user_avatar_url = comment_data

        # If there is a parent comment, get the information of the user being replied to
        replied_to_user_uuid = None
        replied_to_user_name = None

        if parent_comment_id:
            reply_context_query: Select[Any] = (
                select(TransactionComment, User.username)
                .join(User, TransactionComment.user_uuid == User.uuid)
                .where(TransactionComment.id == parent_comment_id)
            )
            reply_context_result = await self.db.execute(reply_context_query)
            reply_context_data = reply_context_result.first()

            if reply_context_data:
                parent_comment_obj, parent_user_name = reply_context_data
                replied_to_user_uuid = str(parent_comment_obj.user_uuid)
                replied_to_user_name = parent_user_name

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
        comment_id: int,
        commenter_username: str,
        comment_text: str,
        parent_author_uuid: str | None = None,
    ) -> None:
        """Create notifications for mentioned users and push via WebSocket."""
        from app.core.ws_manager import ws_manager
        from app.models.notification import Notification

        target_path = f"/home/transaction/{transaction_id}?commentId={comment_id}"

        for mentioned_id in mentioned_user_ids:
            try:
                mentioned_uuid = UUID(mentioned_id)
            except ValueError:
                continue

            is_parent_author_reply = parent_author_uuid is not None and str(mentioned_uuid) == parent_author_uuid
            title = (
                f"{commenter_username} replied to your comment"
                if is_parent_author_reply
                else f"{commenter_username} mentioned you"
            )

            notification_data = {
                "transactionId": str(transaction_id),
                "transaction_id": str(transaction_id),
                "commentId": str(comment_id),
                "comment_id": str(comment_id),
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

        await self.db.commit()

        # Push via WebSocket (best effort, don't fail the comment)
        for mentioned_id in mentioned_user_ids:
            try:
                is_parent_author_reply = parent_author_uuid is not None and mentioned_id == parent_author_uuid
                title = (
                    f"{commenter_username} replied to your comment"
                    if is_parent_author_reply
                    else f"{commenter_username} mentioned you"
                )

                await ws_manager.send_notification(
                    mentioned_id,
                    {
                        "type": "bill_comment",
                        "title": title,
                        "message": comment_text[:100],
                        "data": {
                            "transactionId": str(transaction_id),
                            "commentId": str(comment_id),
                            "target_path": target_path,
                        },
                    },
                )
            except Exception as e:  # noqa: BLE001 - best-effort push, don't fail the comment
                logger.warning("ws_push_failed", user_uuid=str(mentioned_id), error=str(e))

    async def delete_comment(self, comment_id: int, user_uuid: UUID) -> bool:
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
            raise BusinessError("You do not have permission to delete this comment", "PERMISSION_DENIED")

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
        comment_id: int,
        action: str,
    ) -> None:
        """Broadcast real-time comment created/deleted event to all space members / transaction participants."""
        from app.core.ws_manager import ws_manager
        from app.models.shared_space import SpaceMember, SpaceTransaction
        from app.models.transaction import Transaction

        user_uuids: set[str] = set()

        # 1. Add transaction owner
        tx_query = select(Transaction.user_uuid).where(Transaction.id == transaction_id)
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
