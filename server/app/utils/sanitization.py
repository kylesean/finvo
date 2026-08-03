"""This file contains the sanitization utilities for the application."""

from __future__ import annotations

import html
import re


def sanitize_string(value: str) -> str:
    """Sanitize a string to prevent XSS and other injection attacks.

    Args:
        value: The string to sanitize

    Returns:
        str: The sanitized string
    """
    # Convert to string if not already
    if not isinstance(value, str):
        value = str(value)

    # HTML escape to prevent XSS
    value = html.escape(value)

    # Remove any script tags that might have been escaped
    value = re.sub(r"&lt;script.*?&gt;.*?&lt;/script&gt;", "", value, flags=re.DOTALL)

    # Remove null bytes
    value = value.replace("\0", "")

    return value


def sanitize_email(email: str) -> str:
    """Validate and normalize an email address.

    Only format validation + lowercase normalization. Input-side HTML escaping
    is deliberately NOT applied: escaping belongs at the render/output layer,
    and applying it here would corrupt legitimate addresses containing special
    characters and double-escape later.

    Args:
        email: The email address to validate

    Returns:
        str: The normalized (trimmed, lowercased) email address

    Raises:
        ValueError: If the email format is invalid
    """
    if not isinstance(email, str):
        raise ValueError("Invalid email format")

    email = email.strip().lower()

    if not re.match(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", email):
        raise ValueError("Invalid email format")

    return email
