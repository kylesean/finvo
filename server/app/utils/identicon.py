"""Deterministic GitHub-style identicon generation.

Generates a unique 5x5 mirrored pixel avatar from a seed (the user's UUID),
in the style of GitHub's classic identicons:

- ``SHA-256(seed)`` produces the digest.
- Byte 0 selects the hue (0-360 degrees), so every user gets a distinct base color.
- The next 15 bits fill the left three columns of a 5x5 grid; the right two
  columns mirror them, producing a symmetric, badge-like shape.
- Pixels are drawn in an HSV color derived from the hash over a light
  gray-white background.

The bit layout and color formula are intentionally bit-compatible with the
Flutter client widget (``client/lib/shared/widgets/identicon_avatar.dart``),
so the same user renders an identical pattern on the server and on-device.

The seed is the user's UUID (not their email): it is always present (email is
optional for mobile registrations), immutable, and available on the client in
every context — including offline fallbacks — so the pattern never diverges.
"""

from __future__ import annotations

import colorsys
import hashlib
import io
from uuid import UUID

from PIL import Image

GRID_SIZE = 5
MIRROR_COLS = (GRID_SIZE + 1) // 2  # independent columns before mirroring
CELL_COUNT = GRID_SIZE * MIRROR_COLS  # bits consumed from the digest

# Classic identicon gray-white background.
DEFAULT_BACKGROUND: tuple[int, int, int] = (240, 240, 240)

# Foreground saturation/value tuned for contrast on the light background.
# The client widget uses the same values for light themes.
FOREGROUND_SATURATION = 0.60
FOREGROUND_VALUE = 0.55


def identicon_digest(seed: str) -> bytes:
    """Return the SHA-256 digest of the seed (32 bytes)."""
    return hashlib.sha256(seed.encode("utf-8")).digest()


def identicon_hue(seed: str) -> float:
    """Return the hue (0-360 degrees) assigned to the seed."""
    return identicon_digest(seed)[0] / 255.0 * 360.0


def identicon_matrix(seed: str) -> list[list[bool]]:
    """Return the mirrored 5x5 pixel matrix (True = filled) for the seed."""
    digest = identicon_digest(seed)
    matrix: list[list[bool]] = []
    for row in range(GRID_SIZE):
        line = [False] * GRID_SIZE
        for col in range(MIRROR_COLS):
            index = row * MIRROR_COLS + col
            filled = (digest[1 + index // 8] >> (index % 8)) & 1 == 1
            line[col] = filled
            line[GRID_SIZE - 1 - col] = filled
        matrix.append(line)
    return matrix


def identicon_foreground_rgb(seed: str) -> tuple[int, int, int]:
    """Return the foreground (r, g, b) color assigned to the seed."""
    hue = identicon_hue(seed)
    red, green, blue = colorsys.hsv_to_rgb(hue / 360.0, FOREGROUND_SATURATION, FOREGROUND_VALUE)
    return round(red * 255), round(green * 255), round(blue * 255)


def render_identicon_png(
    seed: str,
    size: int = 256,
    background: tuple[int, int, int] = DEFAULT_BACKGROUND,
) -> bytes:
    """Render the seed's identicon as square PNG bytes.

    Args:
        seed: The value to hash (a user's UUID string).
        size: Output width/height in pixels.
        background: Background (r, g, b) color.
    """
    size = max(1, int(size))
    image = Image.new("RGB", (GRID_SIZE, GRID_SIZE), background)
    foreground = identicon_foreground_rgb(seed)
    for row, line in enumerate(identicon_matrix(seed)):
        for col, filled in enumerate(line):
            if filled:
                image.putpixel((col, row), foreground)
    image = image.resize((size, size), Image.Resampling.NEAREST)
    buffer = io.BytesIO()
    image.save(buffer, format="PNG", optimize=True)
    return buffer.getvalue()


def _hex_color(rgb: tuple[int, int, int]) -> str:
    red, green, blue = rgb
    return f"#{red:02x}{green:02x}{blue:02x}"


def render_identicon_svg(seed: str, cell_size: int = 40) -> str:
    """Render the seed's identicon as an SVG document string."""
    foreground = _hex_color(identicon_foreground_rgb(seed))
    background = _hex_color(DEFAULT_BACKGROUND)
    dimension = GRID_SIZE * cell_size
    rects: list[str] = []
    for row, line in enumerate(identicon_matrix(seed)):
        for col, filled in enumerate(line):
            if filled:
                rects.append(
                    f'<rect x="{col * cell_size}" y="{row * cell_size}" width="{cell_size}" height="{cell_size}"/>'
                )
    body = "\n    ".join(rects)
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{dimension}" height="{dimension}" '
        f'viewBox="0 0 {dimension} {dimension}">\n'
        f'  <rect width="{dimension}" height="{dimension}" fill="{background}"/>\n'
        f'  <g fill="{foreground}">\n    {body}\n  </g>\n'
        "</svg>\n"
    )


def default_avatar_url(user_uuid: UUID | str) -> str:
    """Return the server-relative public avatar URL for a user.

    The unified ``/avatars/{uuid}`` endpoint returns the uploaded avatar if the
    user has one, otherwise the generated identicon. The path is relative to the
    API root (``settings.API_V1_STR``), so clients prefix it with their
    configured base URL (which already ends in ``/api/v1``).
    """
    return f"/avatars/{user_uuid}"
