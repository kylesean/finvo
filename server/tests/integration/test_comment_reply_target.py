"""Integration tests for comment reply-target semantics.

The client flattens multi-level replies onto the single-level structure:
a reply to a reply attaches to the thread's ROOT comment, and the user the
reply is actually directed at is sent via ``replied_to_user_id``. The server
persists the explicit target; when a caller omits it, the parent author is
the creation-time default so replies always produce a notification.
"""

from datetime import UTC, datetime
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy import select

from app.models.notification import Notification
from app.models.transaction import Transaction, TransactionComment
from app.models.user import User


@pytest.mark.asyncio
async def test_comment_reply_persists_explicit_target(client_with_auth, db_session, test_user):
    """Replying to a reply keeps the tapped author as the reply target."""
    # The transaction recorder (current user).
    tx = Transaction(
        uuid=uuid4(),
        user_uuid=test_user.uuid,
        type="EXPENSE",
        amount=Decimal("10.0"),
        amount_original=Decimal("10.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
    )
    db_session.add(tx)
    await db_session.commit()
    tx_id = str(tx.uuid)

    # Another user who appears in the thread.
    other = User(
        uuid=uuid4(),
        username="integration_comment_target",
        email="comment-target@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(other)
    await db_session.commit()

    # Root comment authored by the CURRENT user...
    root = TransactionComment(
        uuid=uuid4(),
        transaction_id=tx.uuid,
        user_uuid=test_user.uuid,
        comment_text="root comment",
    )
    db_session.add(root)
    # ...and a child reply authored by the OTHER user (multi-level thread).
    child = TransactionComment(
        uuid=uuid4(),
        transaction_id=tx.uuid,
        user_uuid=other.uuid,
        comment_text="child comment",
        parent_comment_id=root.uuid,
    )
    db_session.add(child)
    await db_session.commit()
    root_id = str(root.uuid)

    # The current user replies to the child comment: flattened onto the root,
    # with the explicit target = child's author. Without the explicit target
    # this would come back as "replied to yourself" (root = own comment).
    response = client_with_auth.post(
        f"/api/v1/transactions/{tx_id}/comments",
        json={
            "comment_text": "reply to the other user",
            "parent_comment_id": root_id,
            "replied_to_user_id": str(other.uuid),
        },
    )
    assert response.status_code == 200, response.text
    created = response.json()["data"]
    assert created["repliedToUserId"] == str(other.uuid)

    # The commenter is notified as the reply target.
    reply_notifications = (
        (
            await db_session.execute(
                select(Notification).where(
                    Notification.user_uuid == other.uuid,
                    Notification.type == "bill_comment",
                )
            )
        )
        .scalars()
        .all()
    )
    assert len(reply_notifications) == 1
    assert reply_notifications[0].data.get("commentKind") == "reply"
    assert "integration_test_user" in reply_notifications[0].title

    # The explicit target survives a full reload of the thread.
    listed = client_with_auth.get(f"/api/v1/transactions/{tx_id}/comments")
    assert listed.status_code == 200
    replies = [c for c in listed.json()["data"] if c["id"] == created["id"]]
    assert len(replies) == 1
    assert replies[0]["repliedToUserId"] == str(other.uuid)


@pytest.mark.asyncio
async def test_first_direct_comment_notifies_transaction_owner(client_with_auth, db_session, test_user):
    """A first-level (root) comment notifies the transaction owner."""
    from app.models.shared_space import SharedSpace, SpaceMember, SpaceTransaction

    other = User(
        uuid=uuid4(),
        username="integration_tx_owner",
        email="tx-owner@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(other)
    await db_session.commit()

    tx = Transaction(
        uuid=uuid4(),
        user_uuid=other.uuid,
        type="EXPENSE",
        amount=Decimal("10.0"),
        amount_original=Decimal("10.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
    )
    db_session.add(tx)
    await db_session.commit()

    shared_space = SharedSpace(id=uuid4(), name="comment owner space", creator_uuid=other.uuid)
    db_session.add(shared_space)
    await db_session.commit()
    db_session.add(
        SpaceMember(
            space_id=shared_space.id,
            user_uuid=test_user.uuid,
            status="ACCEPTED",
        )
    )
    db_session.add(SpaceTransaction(space_id=shared_space.id, transaction_id=tx.uuid, added_by_user_uuid=other.uuid))
    await db_session.commit()

    response = client_with_auth.post(
        f"/api/v1/transactions/{tx.uuid}/comments",
        json={"comment_text": "first direct comment"},
    )
    assert response.status_code == 200, response.text

    rows = (
        (
            await db_session.execute(
                select(Notification).where(
                    Notification.user_uuid == other.uuid,
                    Notification.type == "bill_comment",
                )
            )
        )
        .scalars()
        .all()
    )
    assert len(rows) == 1
    assert rows[0].data.get("commentKind") == "owner"
    assert "integration_test_user" in rows[0].title


@pytest.mark.asyncio
async def test_direct_root_reply_keeps_replied_to_user_id_none(client_with_auth, db_session, test_user):
    """Direct root reply keeps repliedToUserId=None for clean UI rendering, while notifying root author."""
    tx = Transaction(
        uuid=uuid4(),
        user_uuid=test_user.uuid,
        type="EXPENSE",
        amount=Decimal("10.0"),
        amount_original=Decimal("10.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
    )
    db_session.add(tx)
    await db_session.commit()

    other = User(
        uuid=uuid4(),
        username="integration_parent_author",
        email="parent-author@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(other)
    await db_session.commit()

    root = TransactionComment(
        uuid=uuid4(),
        transaction_id=tx.uuid,
        user_uuid=other.uuid,
        comment_text="comment by the other user",
    )
    db_session.add(root)
    await db_session.commit()

    response = client_with_auth.post(
        f"/api/v1/transactions/{tx.uuid}/comments",
        json={"comment_text": "plain reply", "parent_comment_id": str(root.uuid)},
    )
    assert response.status_code == 200, response.text
    created = response.json()["data"]
    # Direct reply to 1st-level root comment leaves repliedToUserId None for clean UI
    assert created["repliedToUserId"] is None

    rows = (
        (
            await db_session.execute(
                select(Notification).where(
                    Notification.user_uuid == other.uuid,
                    Notification.type == "bill_comment",
                )
            )
        )
        .scalars()
        .all()
    )
    assert len(rows) == 1
    assert rows[0].data.get("commentKind") == "reply"
    assert "integration_test_user" in rows[0].title


@pytest.mark.asyncio
async def test_auto_extract_mention_in_comment_text(client_with_auth, db_session, test_user):
    """Writing @username in comment text automatically extracts mention and notifies user without polluting repliedToUserId."""
    tx = Transaction(
        uuid=uuid4(),
        user_uuid=test_user.uuid,
        type="EXPENSE",
        amount=Decimal("15.0"),
        amount_original=Decimal("15.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
    )
    db_session.add(tx)
    await db_session.commit()

    mentioned_target = User(
        uuid=uuid4(),
        username="integration_mention_target",
        email="mention-target@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(mentioned_target)
    await db_session.commit()

    response = client_with_auth.post(
        f"/api/v1/transactions/{tx.uuid}/comments",
        json={"comment_text": "@integration_mention_target look at this transaction"},
    )
    assert response.status_code == 200, response.text
    created = response.json()["data"]
    # Text mention does NOT set repliedToUserId (so UI doesn't render > mention_target)
    assert created["repliedToUserId"] is None

    rows = (
        (
            await db_session.execute(
                select(Notification).where(
                    Notification.user_uuid == mentioned_target.uuid,
                    Notification.type == "bill_comment",
                )
            )
        )
        .scalars()
        .all()
    )
    assert rows[0].data.get("commentKind") == "mention"
    assert "提到了你" in rows[0].title
