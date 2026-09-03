"""Mark non-user-authored prompt content as data, never instructions."""

from __future__ import annotations

UNTRUSTED_TAG = "untrusted_data"


def wrap_untrusted(text: str, *, source: str) -> str:
    """Wrap third-party text in an untrusted_data block."""
    return f'<{UNTRUSTED_TAG} source="{source}">\n{text}\n</{UNTRUSTED_TAG}>'
