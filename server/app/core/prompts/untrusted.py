"""Mark non-user-authored prompt content as data, never instructions."""

from __future__ import annotations

UNTRUSTED_TAG = "untrusted_data"


def wrap_untrusted(text: str, *, source: str) -> str:
    """Wrap third-party text in an untrusted_data block."""
    safe_text = text.replace(f"</{UNTRUSTED_TAG}>", f"<\\/{UNTRUSTED_TAG}>")
    clean_source = source.replace('"', "")
    return f'<{UNTRUSTED_TAG} source="{clean_source}">\n{safe_text}\n</{UNTRUSTED_TAG}>'
