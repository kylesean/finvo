"""Single pagination contract for all list endpoints. [P1-4]"""

from __future__ import annotations

from collections.abc import Callable
from typing import Annotated, Any

from fastapi import Depends, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession


class PageParams:
    """Query params shared by every list endpoint. [P1-4]"""

    def __init__(
        self,
        page: int = Query(default=1, ge=1),
        page_size: int = Query(default=20, ge=1, le=100),
    ) -> None:
        self.page = page
        self.page_size = page_size


Paging = Annotated[PageParams, Depends()]


def payload(items: list[Any], page: int, page_size: int, total: int) -> dict[str, Any]:
    """Canonical page envelope. [P1-4]"""
    pages = (total + page_size - 1) // page_size if total > 0 else 0
    return {
        "items": items,
        "page": page,
        "page_size": page_size,
        "total": total,
        "pages": pages,
        "hasMore": page < pages if pages else False,
    }


async def paginate(
    db: AsyncSession,
    stmt: Any,
    paging: PageParams,
    transformer: Callable[[list[Any]], list[Any]] | None = None,
) -> dict[str, Any]:
    """Run count + page fetch for a select statement. [P1-4]"""
    count_stmt = select(func.count()).select_from(stmt.order_by(None).subquery())
    total = (await db.execute(count_stmt)).scalar() or 0
    rows = (
        (await db.execute(stmt.offset((paging.page - 1) * paging.page_size).limit(paging.page_size))).scalars().all()
    )
    items = list(rows)
    if transformer is not None:
        items = transformer(items)
    return payload(items, paging.page, paging.page_size, total)
