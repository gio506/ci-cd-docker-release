# Changelog

All notable changes to this project are documented in this file.

## [0.1.1] - 2026-02-19
### Changed
- Hardened GitHub Actions workflow with top-level permissions, concurrency, pip caching, and job timeouts.
- Upgraded tag generation to `docker/metadata-action` for SHA + semver/release tags.
- Expanded smoke test to validate both `/health` and `/version`.
- Improved Dockerfile security/runtime defaults (non-root user and container healthcheck).
- Updated project docs to explain event-driven push behavior and stage responsibilities.

## [0.1.0] - 2026-02-19
### Added
- FastAPI sample app with `/health` and `/version` endpoints.
- Pytest tests and Ruff lint configuration.
- Dockerfile for containerized app execution.
- 6-stage GitHub Actions CI/CD workflow to lint, test, build, smoke test, tag, and publish to GHCR.
- `RELEASE.md` and `CHEATSHEET.md` operational documentation.
