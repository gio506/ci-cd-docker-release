# Release Guide

## Versioning policy
- Use semantic versioning tags: `vMAJOR.MINOR.PATCH`.
- Example: `v1.4.2`.

## Pre-release checklist
1. Verify local quality checks:
   - `ruff check .`
   - `pytest -q`
2. Confirm `CHANGELOG.md` has an entry for the upcoming version.
3. Merge changes into `main`.

## Create a release
```bash
git checkout main
git pull origin main
git tag v0.1.0
git push origin v0.1.0
```

## What happens in CI/CD
- Pipeline runs lint → tests → docker-build → smoke-test → tag-version → push-image.
- Image is always tagged with short SHA (`:<sha7>`).
- For semver tags/releases, image also gets semver tag (`:vX.Y.Z`).
- Image destination: `ghcr.io/<owner>/<repo>`.

## Rollback quick note
- Re-deploy a previous known-good GHCR image tag (`sha` or semver).
- Create follow-up patch release if needed (`vX.Y.(Z+1)`).
