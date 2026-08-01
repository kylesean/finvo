"""App version API endpoints."""

from fastapi import APIRouter
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from app.core.config import settings
from app.core.responses import success_response


class DownloadUrlsSchema(BaseModel):
    """Download URLs schema for different platforms."""

    androidApk: str = Field(default="", description="Android APK download URL")
    iosTestFlight: str = Field(default="", description="iOS TestFlight public link")
    webUrl: str = Field(default="", description="Web App URL")


class VersionCheckResponseSchema(BaseModel):
    """Version check response payload schema."""

    latestVersion: str = Field(..., description="Latest released version string")
    minSupportedVersion: str = Field(..., description="Minimum supported client version string")
    forceUpdate: bool = Field(default=False, description="Whether client must force update")
    releaseDate: str = Field(..., description="Release date string YYYY-MM-DD")
    changelog: str = Field(..., description="Changelog description text")
    downloadUrls: DownloadUrlsSchema = Field(..., description="Download URLs per platform")


router = APIRouter(prefix="/version", tags=["version"])


@router.get("/check")
async def check_version() -> JSONResponse:
    """Check latest app version and return update instructions.

    Returns:
        JSONResponse with version details wrapped in unified response envelope.
    """
    version_data = VersionCheckResponseSchema(
        latestVersion=settings.VERSION,
        minSupportedVersion=settings.MIN_SUPPORTED_CLIENT_VERSION,
        forceUpdate=False,
        releaseDate="2026-07-27",
        changelog="1. Added automatic app version check and update support\n2. Optimized shared space interaction logic\n3. Improved network connectivity and service stability",
        downloadUrls=DownloadUrlsSchema(
            androidApk="https://github.com/Finvo-ai/Finvo/releases/latest",
            iosTestFlight="https://testflight.apple.com/join/Finvo",
            webUrl="https://app.Finvo.ai",
        ),
    )
    return success_response(
        data=version_data,
        message="Version check completed successfully",
    )
