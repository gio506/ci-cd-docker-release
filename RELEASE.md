# Release Guide

## Versioning policy
- Use semantic versioning tags: `vMAJOR.MINOR.PATCH`.
- Example: `v1.4.2`.

## Pre-release checklist
1. Confirm local quality gates:
   - `ruff check .`
   - `pytest -q`
2. Confirm `CHANGELOG.md` includes release notes.
3. Merge approved PR into `main`.

## Create a release
```bash
git checkout main
git pull origin main
git tag v0.1.0
git push origin v0.1.0
# Optional GitHub release object
# gh release create v0.1.0 --generate-notes
```

## CI/CD behavior by event
- **pull_request**: runs full validation (`lint` → `tests` → `docker-build` → `smoke-test` → `tag-version`), **skips push-image** by design.
- **push to main**: runs full pipeline and publishes SHA-tagged image.
- **push tag vX.Y.Z**: runs full pipeline and publishes SHA + semver tags.
- **release published**: runs full pipeline and publishes SHA + release tag.

## Image tag strategy
- Always includes short SHA tag from `docker/metadata-action`.
- Adds semver/release tag when the ref/event provides one.
- Build args propagate metadata into runtime endpoint:
  - `APP_VERSION`
  - `GIT_SHA`

## Rollback quick note
- Re-deploy a previous known-good GHCR tag (`sha` or semver).
- If needed, publish a patch release (`vX.Y.(Z+1)`).
