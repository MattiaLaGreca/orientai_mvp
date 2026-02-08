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
- **Refactoring:**
  - Refactored `OrientAIService` and `DatabaseService` for better testability (Dependency Injection).
  - Standardized error handling with `OrientAIException` and user-friendly messages.

### Fixed
- Addressed potential PII leaks in logs using `SecureLogger`.
