"""Error code consistency tests.

Guards the contract between domain error code enums (app.core.exceptions) and
the integer error code map consumed by the API response layer
(app.core.responses.ERROR_CODE_MAP).

Every domain enum member's string value MUST have a corresponding int entry in
ERROR_CODE_MAP; otherwise the exception handler would fall back to 500 and the
frontend (which keys translations off the int code) could not localize it.

The cross-language contract with the Flutter client (client/lib/core/constants/
error_codes.dart) is intentionally NOT asserted here — Dart and Python cannot
share a source of truth, so it is guarded by integration tests and the
ErrorCodes int-value stability convention instead.
"""

from __future__ import annotations

from enum import StrEnum

from app.core import exceptions
from app.core.responses import ERROR_CODE_MAP


def _domain_error_enum_classes() -> list[type[StrEnum]]:
    """Discover all domain error code enum classes defined in exceptions.py.

    These are the StrEnum subclasses that produce member names as their values
    via the shared _AutoName base. _AutoName itself is excluded (it is the
    shared base, not a domain enum).
    """
    classes: list[type[StrEnum]] = []
    for name, obj in vars(exceptions).items():
        if (
            isinstance(obj, type)
            and issubclass(obj, StrEnum)
            and obj is not StrEnum
            and obj.__module__ == exceptions.__name__
            and not name.startswith("_")
        ):
            classes.append(obj)
    return classes


def _all_enum_member_values() -> set[str]:
    """Collect the string values of every domain error code enum member."""
    values: set[str] = set()
    for enum_cls in _domain_error_enum_classes():
        for member in enum_cls:
            values.add(member.value)
    return values


class TestErrorCodeConsistency:
    """Assert ERROR_CODE_MAP stays in sync with domain error code enums."""

    def test_every_enum_member_has_int_mapping(self) -> None:
        """Each domain enum member value must exist in ERROR_CODE_MAP.

        A missing entry means the exception handler would return the default
        500 code, breaking frontend translation lookups.
        """
        enum_values = _all_enum_member_values()
        map_keys = set(ERROR_CODE_MAP.keys())

        missing = enum_values - map_keys
        assert not missing, (
            f"Domain enum members without an int mapping in ERROR_CODE_MAP: {sorted(missing)}. "
            "Add them to app.core.responses.ERROR_CODE_MAP."
        )

    def test_error_code_map_keys_are_known_enum_members(self) -> None:
        """ERROR_CODE_MAP keys must correspond to a domain enum member.

        Unknown keys are Legacy aliases that should be removed to keep the
        error code surface area single-sourced from the domain enums.
        """
        enum_values = _all_enum_member_values()
        map_keys = set(ERROR_CODE_MAP.keys())

        # Keys present in ERROR_CODE_MAP that are not domain enum members.
        # These are Legacy aliases pending cleanup; asserting they are empty
        # drives the Legacy removal to completion.
        legacy_aliases = map_keys - enum_values
        assert not legacy_aliases, (
            f"ERROR_CODE_MAP contains keys that are not domain enum members: {sorted(legacy_aliases)}. "
            "These are Legacy aliases — remove them once callers migrate to domain enums."
        )

    def test_int_code_values_match_frontend_contract_ranges(self) -> None:
        """Int codes must stay within their documented domain ranges.

        The frontend (client/lib/core/constants/error_codes.dart) keys its
        ErrorTranslator switch off these int values, so each domain owns a
        non-overlapping range. Multiple backend string codes MAY map to the same
        int (semantic folding, e.g. SERVER_ERROR and INTERNAL_ERROR both -> 500
        surface as "server error" on the client) — that is allowed and not
        asserted against here.
        """
        # Range table: (low, high, domain_label). Verified non-overlapping.
        ranges = [
            (0, 0, "success"),
            (400, 409, "http-aligned generic"),
            (500, 599, "server"),
            (999, 999, "validation"),
            (1000, 1012, "auth"),
            (3000, 3018, "transaction"),
            (3100, 3118, "shared space"),
            (3200, 3218, "recurring"),
            (4001, 4017, "file upload"),
            (4500, 4599, "storage config"),
            (9000, 9099, "ai/llm"),
        ]
        for member_name, int_value in ERROR_CODE_MAP.items():
            in_some_range = any(low <= int_value <= high for low, high, _ in ranges)
            assert in_some_range, (
                f"Error code '{member_name}'={int_value} falls outside all documented "
                "domain ranges; update the range table or remap the code."
            )
