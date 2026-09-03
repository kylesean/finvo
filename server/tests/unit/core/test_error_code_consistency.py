"""Error code consistency tests.

Guards the single-source invariant for error codes: ``ERROR_CODE_MAP`` is
derived from the domain error code enums in ``app.core.exceptions``, so the
string code (enum member name) and integer code (enum member value) can never
drift apart. Adding an enum member is the only change needed to register a
new code.

The int-value range contract with the Flutter client
(client/lib/core/constants/error_codes.dart) is asserted here because Dart
and Python cannot share a source of truth — the int values are a stable
cross-language contract that must not silently move outside its documented
domain range.
"""

from __future__ import annotations

import re
from pathlib import Path

from app.core import exceptions
from app.core.exceptions import ERROR_CODE_MAP


def _domain_error_enum_classes() -> list[type[exceptions._ErrorCode]]:
    """Discover all domain error code enum classes defined in exceptions.py.

    A domain enum is an ``_ErrorCode`` subclass defined in this module
    (excluding the shared ``_ErrorCode`` base itself).
    """
    base = exceptions._ErrorCode
    classes: list[type[exceptions._ErrorCode]] = []
    for name, obj in vars(exceptions).items():
        if (
            isinstance(obj, type)
            and issubclass(obj, base)
            and obj is not base
            and obj.__module__ == exceptions.__name__
            and not name.startswith("_")
        ):
            classes.append(obj)
    return classes


def _all_enum_members() -> list[tuple[str, int]]:
    """Collect (name, int_value) for every domain error code enum member."""
    members: list[tuple[str, int]] = []
    for enum_cls in _domain_error_enum_classes():
        for member in enum_cls:
            members.append((member.name, member.int_code))
    return members


class TestErrorCodeConsistency:
    """Assert ERROR_CODE_MAP stays the single-source derivation of the enums."""

    def test_error_code_map_is_derived_from_enums(self) -> None:
        """ERROR_CODE_MAP must equal {member.name: member.value} over all enums.

        This is the single-source invariant: the map is derived, not
        hand-maintained. A mismatch means someone hand-edited the map or
        bypassed the enum registration.
        """
        expected = {member_name: member_value for member_name, member_value in _all_enum_members()}
        assert ERROR_CODE_MAP == expected, (
            "ERROR_CODE_MAP is not in sync with the domain error code enums. "
            "The map must be derived from the enums via _ALL_ERROR_CODE_ENUMS."
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
            (400, 429, "http-aligned generic"),
            (500, 599, "server"),
            (999, 999, "validation"),
            (1000, 1013, "auth"),
            (3000, 3018, "transaction"),
            (3100, 3118, "shared space"),
            (3200, 3218, "recurring"),
            (3300, 3312, "financial account lifecycle"),
            (4001, 4022, "file upload"),
            (4500, 4599, "storage config"),
            (9000, 9099, "ai/llm"),
        ]
        for member_name, int_value in _all_enum_members():
            in_some_range = any(low <= int_value <= high for low, high, _ in ranges)
            assert in_some_range, (
                f"Error code '{member_name}'={int_value} falls outside all documented "
                "domain ranges; update the range table or remap the code."
            )

    def test_frontend_int_codes_are_backend_subset(self) -> None:
        """Every int in Flutter `error_codes.dart` must exist in the backend map.

        Dart and Python cannot share a source file, so this file-system
        contract test is the drift guard: a frontend int with no backend
        producer means a renamed/remapped code that the client still switches
        on (silent mis-translation). Backend MAY own more codes than the
        frontend (new codes roll out backend-first).
        """
        dart_path = (
            Path(__file__).resolve().parents[4]
            / "client"
            / "lib"
            / "core"
            / "constants"
            / "error_codes.dart"
        )
        assert dart_path.is_file(), f"frontend contract file missing: {dart_path}"
        dart_ints = {
            int(m.group(1))
            for m in re.finditer(r"static const int \w+ = (\d+);", dart_path.read_text())
        }
        assert dart_ints, f"no error codes parsed from {dart_path}"
        backend_ints = set(ERROR_CODE_MAP.values())
        unknown = sorted(dart_ints - backend_ints)
        assert not unknown, (
            f"frontend error ints with no backend producer: {unknown}. "
            "Add the enum member in app/core/exceptions.py or remove the stale Dart const."
        )
