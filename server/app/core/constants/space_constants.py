"""Shared-space status vocabulary.

Single source of truth for ``SharedSpace.status``. Lowercase by convention
(matching the API schema pattern); the DB CHECK enforces the same set.
"""

from enum import Enum


class SpaceStatus(str, Enum):
    """Lifecycle states of a shared space."""

    ACTIVE = "active"
    ARCHIVED = "archived"
