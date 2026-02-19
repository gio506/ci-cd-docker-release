# ci-cd-docker-release

Tiny FastAPI app with `/health` and `/version` endpoints plus a production-minded GitHub Actions pipeline for linting, tests, Docker build/smoke checks, tag resolution, and GHCR publishing.

## App endpoints
- `GET /health` → basic status check.
- `GET /version` → app version + commit SHA sourced from environment variables.

## CI/CD stages (6 jobs)
1. **lint**: runs `ruff check .`.
2. **tests**: runs `pytest -q`.
3. **docker-build**: builds a Docker image archive for CI validation.
4. **smoke-test**: runs container and validates both `/health` and `/version`.
5. **tag-version**: generates Docker tags (SHA + optional semver/release tag) and resolves `APP_VERSION`.
6. **push-image**: pushes tags to GHCR only on `main`, semver tags, or release events.

## Workflow best-practice details
- Uses job-level `timeout-minutes` to prevent hanging runs.
- Uses `actions/setup-python` pip cache for faster Python stages.
- Uses top-level `permissions: contents: read` and only elevates `packages: write` in push job.
- Uses workflow `concurrency` to cancel stale duplicate runs on same ref.
- Uses `docker/metadata-action` for robust OCI tag generation.

## Why `push-image` can show as **skipped**
This is expected on pull requests. Push is intentionally guarded to avoid publishing unmerged PR images:
- allowed: `push` to `main`, semver tag `vX.Y.Z`, or `release` event.
- skipped: `pull_request` runs.

## GHCR permissions/secrets
- Default setup uses `secrets.GITHUB_TOKEN` with `packages: write` permission in `push-image`.
- Ensure repository/org Actions settings allow package write.
- If org policy blocks `GITHUB_TOKEN` for packages, use a PAT (`write:packages`) and swap the login password secret.

## Local run
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
uvicorn app:app --reload
```

## Repository tree
```text
.
├── .github/workflows/ci-cd-docker-release.yml  # 6-stage CI/CD pipeline (lint/test/build/smoke/tag/push)
├── app.py                                      # FastAPI service (/health, /version)
├── tests/test_app.py                           # API tests
├── tests/conftest.py                           # Pytest import-path guard for CI consistency
├── Dockerfile                                  # Container build recipe (non-root + healthcheck)
├── requirements.txt                            # Runtime deps
├── requirements-dev.txt                        # Dev/test/lint deps
├── pyproject.toml                              # Ruff configuration
├── CHANGELOG.md                                # Release history
├── RELEASE.md                                  # Release process/checklist
├── CHEATSHEET.md                               # High-value command reference
└── README.md                                   # Project overview
```
