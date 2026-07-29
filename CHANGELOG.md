# Changelog

All notable changes to **Finvo** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note**: During alpha development, this changelog is updated only at version releases.
> For detailed changes between releases, see the [Git commit history](https://github.com/kylesean/Finvo/commits/main).

## [0.2.2-alpha] - 2026-07-29

### Added
- Real-time comment WebSocket synchronization (`comment_updated`) across shared space members for live creation & deletion updates.
- Interactive PhotoView gallery (`PhotoViewGallery`) for transaction image attachments with swipe gestures, pinch-to-zoom, and index count indicator (`1 / N`).
- Progressive blur loading placeholder effect (`ImageFilter.blur`) for transaction image thumbnails and full-screen view.
- Distinct badge for transaction recorder/creator in `@` mention selection popover.

### Changed
- **UI/UX**: Redesigned comment reply banner to compact left-anchored Reply Chip Badge, eliminating misclick issues.
- **UI/UX**: Simplified AI Chat drawer bottom user profile widget to clean avatar + username layout, matching Shared Space drawer.
- **UI/UX**: Updated Server Settings page save action to clear auth session and redirect to Login screen with full i18n support across 5 languages.
- **Design System Alignment**: Replaced delete confirmation modal with Forui `showFDialog` + `FDialog` and upgraded action sheets to `ActionBottomSheet`.

### Fixed
- Fixed permission isolation issue where shared space members could not access or view transaction image attachments.
- Fixed notification deep-linking to transaction detail with 600ms smooth scroll & highlight animation.
- Guarded self-reply interactions in comment threads and optimized 2-tier sub-reply expand/collapse touch targets.

## [0.2.1-alpha] - 2026-07-28

### Added
- Multi-OEM speech engine auto-selector for Android natively matching Xiaomi, Huawei, Honor, OPPO, Vivo, iFlytek, and Google engines.
- Tactile haptic feedback (`HapticFeedback.lightImpact()`) upon initiating voice recognition sessions.
- `GenUiNumUtils` utility for robust string-to-number parsing across GenUI component cards.

### Fixed
- Fixed SSE chat request missing `Accept-Language` headers and `app_language` parameters, ensuring correct locale responses.
- Fixed GenUI component layout and type-casting exceptions (`BudgetStatusCard`, `BudgetAnalysisCard`, `ExpenseSummaryCard`) by wrapping rendering in `GenUiErrorBoundary`.
- Fixed Docker runtime image missing `uv` package manager binary causing skill script execution loops.
- Fixed LangGraph `InvalidUpdateError` for `active_skill` concurrent updates in single execution step via `_take_last_skill` reducer.

## [0.2.0-alpha] - 2026-07-27

### Added
- App version update checker with in-app update prompt (Android & iOS).
- Registration now works out-of-box without an email server: verification code
  check is skipped when `EMAIL_PROVIDER`/`SMS_PROVIDER` is `mock` (default).
- i18n-friendly username generation derived from email local-part or mobile
  tail digits (inspired by GitLab/Grafana/Discourse), replacing random
  `user_XXXXXX` names.
- Animated BrandHeader on auth screens.

### Changed
- **Breaking**: Project renamed from *Augo* to **Finvo** — package identifiers,
  Docker image names, and CI references updated accordingly.
- Unified default currency to CNY via `PROJECT_DEFAULT_CURRENCY` constant
  (single source of truth across model, inference, and service layers).
- Upgraded CI/CD pipelines: hardened security scanning, improved versioning
  and Docker deployment configuration.
- Docker image names lowercased (`finvo-api`) to comply with OCI spec.

### Fixed
- Removed redundant and sensitive console logging in the client.
- Fixed Docker Compose `invalid reference format` caused by uppercase image name.
- Handled native Android speech recognition restrictions gracefully.

## [0.1.2-alpha] - 2026-01-15

### Changed
- Security hardening and dependency upgrades.
- Improved configuration management for versioning and Docker deployments.

## [0.1.1-alpha] - 2025-12-28

### Fixed
- **Critical**: Fixed application crash on first launch when server URL is not configured. Previously required `--dart-define=API_BASE_URL=xxx` to start the app; now the app gracefully shows the server configuration page.
- **Critical**: Fixed crash when opening Speech Settings page without `--dart-define=SPEECH_WS_HOST=xxx`. Users can now configure WebSocket host directly in the settings UI.
- Added `ConfigurationCheckInterceptor` to validate server configuration before making network requests.
- Added `ServerNotConfiguredException` for clearer error handling when server is not configured.

## [0.1.0-alpha] - 2025-12-27

### Added
- Initial alpha release of **Finvo**, the privacy-first AI financial assistant.
- Core FastAPI backend with LangGraph agent support.
- Flutter mobile client with GenUI (Server-driven UI) capabilities.
- Transaction management, budget analysis, and financial forecasting features.
- Integration with Langfuse for AI observability.
- Docker and Docker Compose support for easy deployment.
- Comprehensive [Self-Hosting](docs/SELF_HOSTING.md) and [Architecture](docs/ARCHITECTURE.md) guides.
- Detailed `.env.example` with categorized configurations for easy setup.

### Changed
- Transitioned AI skills to a more robust script-based execution model for improved security and performance.
- Centralized project versioning with a root `VERSION` file.
- Improved color system consistency across the mobile client.
- Optimized Docker builds using multi-stage builds.

### Fixed
- **Security**: Fixed critical shell injection vulnerability in filesystem tools.
- **Security**: Removed hardcoded API keys from binary and source code.
- Fixed AI streaming timeout issues on the client side.
- Resolved various UI rendering inconsistencies.
- Fixed Docker entrypoint path issues for Python module loading.
- Fixed 24+ failing unit and integration tests to ensure 100% test pass rate.
