"""Artifact URL signing and endpoint access tests (M1 fix).

Locks the hardening: artifacts are no longer served by an anonymous
StaticFiles mount. Access requires either a signed capability URL (bound to
user + path, short-lived) or the owner's Bearer token, and responses carry a
sandbox CSP so injected HTML cannot execute scripts in the app's origin.
"""

from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from jose import jwt

from app.core.config import settings
from app.main import app
from app.utils.artifact_signing import sign_artifact_url, verify_artifact_token

_USER_ID = "11111111-1111-4111-8111-111111111111"
_OTHER_USER = "22222222-2222-4222-8222-222222222222"
_ARTIFACT_PATH = "reports/report.html"


@pytest.fixture()
def artifact_file(tmp_path: Path, monkeypatch) -> Path:
    """Materialize an artifact file in the configured artifacts dir.

    The endpoint resolves against app.main._artifacts_dir; point it at a
    temp dir for the test.
    """
    import app.main as main_module

    monkeypatch.setattr(main_module, "_artifacts_dir", tmp_path)
    target = tmp_path / _USER_ID / _ARTIFACT_PATH
    target.parent.mkdir(parents=True)
    target.write_text("<html>report</html>", encoding="utf-8")
    return target


class TestSigning:
    def test_sign_verify_roundtrip(self) -> None:
        token = sign_artifact_url(_USER_ID, _ARTIFACT_PATH)
        assert verify_artifact_token(token) == (_USER_ID, _ARTIFACT_PATH)

    def test_token_bound_to_user(self) -> None:
        token = sign_artifact_url(_USER_ID, _ARTIFACT_PATH)
        assert verify_artifact_token(token) == (_USER_ID, _ARTIFACT_PATH)
        # Same token must not authorize a different user.
        assert verify_artifact_token(token) != (_OTHER_USER, _ARTIFACT_PATH)

    def test_tampered_token_rejected(self) -> None:
        token = sign_artifact_url(_USER_ID, _ARTIFACT_PATH)
        assert verify_artifact_token(token[:-4] + "xxxx") is None

    def test_expired_token_rejected(self) -> None:
        payload = {
            "type": "artifact",
            "user_id": _USER_ID,
            "path": _ARTIFACT_PATH,
            "exp": datetime.now(UTC) - timedelta(minutes=1),
            "iat": datetime.now(UTC) - timedelta(hours=2),
        }
        token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        assert verify_artifact_token(token) is None

    def test_wrong_token_type_rejected(self) -> None:
        payload = {
            "type": "refresh",  # not an artifact capability
            "user_id": _USER_ID,
            "path": _ARTIFACT_PATH,
            "exp": datetime.now(UTC) + timedelta(minutes=5),
            "iat": datetime.now(UTC),
        }
        token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        assert verify_artifact_token(token) is None


class TestArtifactEndpoint:
    def test_anonymous_access_rejected(self, artifact_file: Path) -> None:
        with TestClient(app) as client:
            response = client.get(f"/artifacts/{_USER_ID}/{_ARTIFACT_PATH}")
        assert response.status_code == 401

    def test_signed_url_serves_file(self, artifact_file: Path) -> None:
        url = f"/artifacts/{_USER_ID}/{_ARTIFACT_PATH}?token={sign_artifact_url(_USER_ID, _ARTIFACT_PATH)}"
        with TestClient(app) as client:
            response = client.get(url)
        assert response.status_code == 200
        assert response.text == "<html>report</html>"
        assert "sandbox" in response.headers["content-security-policy"]

    def test_signed_url_bound_to_other_user_rejected(self, artifact_file: Path) -> None:
        # Token signed for _OTHER_USER cannot read _USER_ID's file.
        url = f"/artifacts/{_USER_ID}/{_ARTIFACT_PATH}?token={sign_artifact_url(_OTHER_USER, _ARTIFACT_PATH)}"
        with TestClient(app) as client:
            response = client.get(url)
        assert response.status_code == 401

    def test_signed_url_path_mismatch_rejected(self, artifact_file: Path) -> None:
        # Token bound to a different path cannot read this file.
        url = f"/artifacts/{_USER_ID}/{_ARTIFACT_PATH}?token={sign_artifact_url(_USER_ID, 'other/file.txt')}"
        with TestClient(app) as client:
            response = client.get(url)
        assert response.status_code == 401

    def test_expired_signed_url_rejected(self, artifact_file: Path) -> None:
        payload = {
            "type": "artifact",
            "user_id": _USER_ID,
            "path": _ARTIFACT_PATH,
            "exp": datetime.now(UTC) - timedelta(minutes=1),
            "iat": datetime.now(UTC) - timedelta(hours=2),
        }
        expired = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        with TestClient(app) as client:
            response = client.get(f"/artifacts/{_USER_ID}/{_ARTIFACT_PATH}?token={expired}")
        assert response.status_code == 401

    def test_path_traversal_rejected(self, artifact_file: Path) -> None:
        token = sign_artifact_url(_USER_ID, "reports/report.html")
        with TestClient(app) as client:
            response = client.get(f"/artifacts/{_USER_ID}/../{_OTHER_USER}/x?token={token}")
        # Starlette normalizes the `..` segment before routing, so user_id
        # becomes _OTHER_USER and the _USER_ID-bound token fails (401);
        # URL-encoded traversal (%2e%2e) survives routing and is blocked by
        # the resolve/is_relative_to guard (404). Either rejection is fine.
        assert response.status_code in (401, 404)

    def test_missing_file_returns_404(self, artifact_file: Path) -> None:
        token = sign_artifact_url(_USER_ID, "nope.txt")
        with TestClient(app) as client:
            response = client.get(f"/artifacts/{_USER_ID}/nope.txt?token={token}")
        assert response.status_code == 404
