# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0+1] - 2026-02-07

### Added
- **Security:**
  - Input sanitization (`Validators.cleanMessage`) to remove invisible control characters.
  - URL whitelist (`http`/`https`) for Markdown links to prevent XSS.
  - Unit tests for URL security (`URL Security Tests`).
  - Android Manifest configurations with explicit `INTERNET` permission, `usesCleartextTraffic="false"`, and `<queries>` tag.
- **Release Engineering:**
  - Configured R8 Obfuscation and Resource Shrinking for release builds.
  - Added signing configuration support via `key.properties`.
- **Documentation:**
  - Added `docs/MANUALE_RILASCIO.md` (Release Manual).
  - Added `docs/STRATEGIA_SOSTENIBILITA.md` (Sustainability Strategy).
  - Added Privacy Policy link in Profile Screen.

### Changed
- **Performance:**
  - Optimized Chat Screen rendering with cached Markdown stylesheets.
  - Improved Stream initialization to prevent redundant rebuilds.
  - Concurrent writes to optimize latency for AI requests and DB operations.
  - Fire-and-forget logic for asynchronous history reading.
  - Optimistic UI on Chat Screen with immediate input reset and indicator typing.
  - AI streaming rendering optimization leveraging `ListView(reverse: true)`.
  - Batch chat deletion optimization (`limit(500)`).
- **Refactoring:**
  - Refactored `OrientAIService` and `DatabaseService` for better testability (Dependency Injection).
  - Standardized error handling with `OrientAIException` and user-friendly messages.

### Fixed
- Addressed potential PII leaks in logs using `SecureLogger`.
