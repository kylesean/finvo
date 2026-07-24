"""Tests for the identicon generation module."""

import io
from uuid import uuid4

from PIL import Image

from app.utils.identicon import (
    GRID_SIZE,
    default_avatar_url,
    identicon_foreground_rgb,
    identicon_hue,
    identicon_matrix,
    render_identicon_png,
    render_identicon_svg,
)

SAMPLE_SEEDS = [
    "0d9f5ee4-2c9b-4c62-9db5-8c2b0b3761ab",
    "7e6b2c1e-4f8a-4d3c-9e21-1a5c8f7b3d90",
    "user-without-email-42",
    "kylesean@example.com",
    "中文用户名种子",
]


class TestIdenticonMatrix:
    def test_matrix_shape(self):
        for seed in SAMPLE_SEEDS:
            matrix = identicon_matrix(seed)
            assert len(matrix) == GRID_SIZE
            assert all(len(row) == GRID_SIZE for row in matrix)

    def test_matrix_is_deterministic(self):
        for seed in SAMPLE_SEEDS:
            assert identicon_matrix(seed) == identicon_matrix(seed)

    def test_matrix_is_horizontally_mirrored(self):
        for seed in SAMPLE_SEEDS:
            matrix = identicon_matrix(seed)
            for row in matrix:
                assert row[0] == row[GRID_SIZE - 1]
                assert row[1] == row[GRID_SIZE - 2]

    def test_distinct_seeds_diverge(self):
        seeds = [f"3f2a9c01-0000-4000-8000-{i:012d}" for i in range(200)]
        unique = {str(identicon_matrix(seed)) for seed in seeds}
        # 2^15 possible patterns; 200 random seeds should nearly all differ.
        assert len(unique) > 180

    def test_matrix_is_not_degenerate(self):
        # A matrix that is entirely empty or full would be a broken pattern.
        for seed in SAMPLE_SEEDS:
            filled = sum(cell for row in identicon_matrix(seed) for cell in row)
            assert 0 < filled < GRID_SIZE * GRID_SIZE


class TestIdenticonColor:
    def test_hue_in_range(self):
        for seed in SAMPLE_SEEDS:
            assert 0.0 <= identicon_hue(seed) < 360.0

    def test_hue_is_deterministic(self):
        for seed in SAMPLE_SEEDS:
            assert identicon_hue(seed) == identicon_hue(seed)

    def test_foreground_rgb_in_range(self):
        for seed in SAMPLE_SEEDS:
            rgb = identicon_foreground_rgb(seed)
            assert len(rgb) == 3
            assert all(0 <= channel <= 255 for channel in rgb)


class TestRenderPng:
    def test_returns_valid_png(self):
        data = render_identicon_png(SAMPLE_SEEDS[0])
        assert data[:8] == b"\x89PNG\r\n\x1a\n"
        image = Image.open(io.BytesIO(data))
        assert image.format == "PNG"
        assert image.size == (256, 256)

    def test_respects_requested_size(self):
        image = Image.open(io.BytesIO(render_identicon_png(SAMPLE_SEEDS[1], size=128)))
        assert image.size == (128, 128)

    def test_pixels_are_deterministic(self):
        assert render_identicon_png(SAMPLE_SEEDS[2], size=64) == render_identicon_png(SAMPLE_SEEDS[2], size=64)

    def test_background_and_foreground_colors_present(self):
        image = Image.open(io.BytesIO(render_identicon_png(SAMPLE_SEEDS[3], size=64))).convert("RGB")
        colors = {color for _, color in image.getcolors(maxcolors=256) or []}
        # Exactly two colors: the gray-white background and the hashed foreground.
        assert len(colors) == 2
        assert (240, 240, 240) in colors
        assert identicon_foreground_rgb(SAMPLE_SEEDS[3]) in colors


class TestRenderSvg:
    def test_svg_is_well_formed(self):
        svg = render_identicon_svg(SAMPLE_SEEDS[0])
        assert svg.startswith("<svg")
        assert 'xmlns="http://www.w3.org/2000/svg"' in svg
        assert "<rect" in svg
        assert svg.rstrip().endswith("</svg>")

    def test_svg_is_deterministic(self):
        assert render_identicon_svg(SAMPLE_SEEDS[1]) == render_identicon_svg(SAMPLE_SEEDS[1])


class TestDefaultAvatarUrl:
    def test_url_shape(self):
        uuid = "0d9f5ee4-2c9b-4c62-9db5-8c2b0b3761ab"
        assert default_avatar_url(uuid) == f"/avatars/{uuid}"


USER_UUID = "0d9f5ee4-2c9b-4c62-9db5-8c2b0b3761ab"


class TestIdenticonEndpoint:
    def test_png_endpoint_is_public_and_deterministic(self, client):
        response = client.get(f"/api/v1/avatars/identicon/{USER_UUID}.png")
        assert response.status_code == 200
        assert response.headers["content-type"] == "image/png"
        assert "immutable" in response.headers.get("cache-control", "")
        assert response.content == render_identicon_png(USER_UUID)

    def test_png_endpoint_respects_size(self, client):
        image = Image.open(io.BytesIO(client.get(f"/api/v1/avatars/identicon/{USER_UUID}.png?size=128").content))
        assert image.size == (128, 128)

    def test_svg_endpoint(self, client):
        response = client.get(f"/api/v1/avatars/identicon/{USER_UUID}.svg")
        assert response.status_code == 200
        assert response.headers["content-type"].startswith("image/svg+xml")
        assert response.text.startswith("<svg")

    def test_rejects_invalid_uuid(self, client):
        assert client.get("/api/v1/avatars/identicon/not-a-uuid.png").status_code == 422

    def test_rejects_out_of_range_size(self, client):
        assert client.get(f"/api/v1/avatars/identicon/{USER_UUID}.png?size=9999").status_code == 422


ZERO_UUID = "00000000-0000-0000-0000-000000000000"


class TestUnifiedAvatarEndpoint:
    async def test_no_upload_returns_identicon(self, client_with_auth, test_user):
        response = client_with_auth.get(f"/api/v1/avatars/{test_user.uuid}")
        assert response.status_code == 200
        assert response.headers["content-type"] == "image/png"
        assert "immutable" in response.headers.get("cache-control", "")
        assert response.content == render_identicon_png(str(test_user.uuid))

    async def test_size_query_applies_to_identicon(self, client_with_auth, test_user):
        image = Image.open(io.BytesIO(client_with_auth.get(f"/api/v1/avatars/{test_user.uuid}?size=96").content))
        assert image.size == (96, 96)

    async def test_unknown_user_is_404(self, client_with_auth):
        assert client_with_auth.get(f"/api/v1/avatars/{uuid4()}").status_code == 404

    async def test_missing_upload_falls_back_to_identicon(self, client_with_auth, test_user, db_session):
        # avatar_url points to a non-existent attachment: serve the identicon
        # instead of erroring, so a broken upload never breaks the avatar slot.
        test_user.avatar_url = f"/api/v1/files/view/{ZERO_UUID}"
        await db_session.commit()

        response = client_with_auth.get(f"/api/v1/avatars/{test_user.uuid}")
        assert response.status_code == 200
        assert response.headers["content-type"] == "image/png"
        assert response.content == render_identicon_png(str(test_user.uuid))
