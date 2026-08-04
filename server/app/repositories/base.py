"""Generic async repository base class.

Repositories encapsulate data access for an aggregate root bound to a single
async session. They are request-scoped (constructed per request via FastAPI
dependencies or service constructors) and NEVER commit — transaction
boundaries stay with the caller (Unit of Work).
"""

from __future__ import annotations

from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession


class BaseRepository[ModelT]:
    """Generic CRUD operations for a SQLAlchemy model.

    Subclasses must set the ``model`` class attribute and may add
    aggregate-specific query methods.
    """

    model: type[ModelT]

    def __init__(self, db: AsyncSession):
        """Initialize with the shared async session."""
        self.db = db

    async def list(self, *criteria: Any, order_by: Any | None = None) -> list[ModelT]:
        """List records matching criteria (all records if no criteria given)."""
        query = select(self.model)
        if criteria:
            query = query.where(*criteria)
        if order_by is not None:
            query = query.order_by(order_by)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def add(self, instance: ModelT) -> ModelT:
        """Add a record to the session (no commit)."""
        self.db.add(instance)
        await self.db.flush()
        await self.db.refresh(instance)
        return instance

    async def delete(self, instance: ModelT) -> None:
        """Mark a record for deletion (no commit)."""
        await self.db.delete(instance)
