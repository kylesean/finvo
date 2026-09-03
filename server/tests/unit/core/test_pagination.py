"""Unit tests for the single pagination contract. [P1-4]"""

import pytest

from app.core.pagination import payload


class TestPayload:
    @pytest.mark.parametrize(
        ("total", "page", "page_size", "expected_pages", "expected_has_more"),
        [
            (0, 1, 20, 0, False),
            (20, 1, 20, 1, False),
            (21, 1, 20, 2, True),
            (40, 1, 20, 2, True),
            (40, 2, 20, 2, False),
        ],
    )
    def test_pages_and_has_more_math(self, total, page, page_size, expected_pages, expected_has_more) -> None:
        # Arrange / Act
        result = payload([], page, page_size, total)
        # Assert
        assert result["pages"] == expected_pages
        assert result["hasMore"] is expected_has_more

    def test_envelope_keys(self) -> None:
        # Arrange
        items = [{"id": 1}]
        # Act
        result = payload(items, page=2, page_size=10, total=25)
        # Assert
        assert result == {
            "items": items,
            "page": 2,
            "page_size": 10,
            "total": 25,
            "pages": 3,
            "hasMore": True,
        }

    def test_last_page_has_more_false(self) -> None:
        # Arrange / Act
        result = payload([], page=3, page_size=10, total=25)
        # Assert
        assert result["hasMore"] is False
