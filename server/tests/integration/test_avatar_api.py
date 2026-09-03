"""Avatar HTTP endpoint tests (moved from unit/test_identicon.py).

HTTP-level tests are integration tests per the unit-testing guide (§2.1):
routers are covered for contracts here, logic stays in unit/.
"""

import io
from uuid import uuid4

from PIL import Image

from app.utils.identicon import render_identicon_png

USER_UUID = "0d9f5ee4-2c9b-4c62-9db5-8c2b0b3761ab"
ZERO_UUID = "00000000-0000-0000-0000-000000000000"


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
