# ci-cd-docker-release

Tiny FastAPI app with a `/health` and `/version` endpoint plus a ready-to-use GitHub Actions pipeline for linting, testing, Docker build/smoke tests, version tagging, and GHCR publishing.

## App endpoints
- `GET /health` → basic status check.
- `GET /version` → app version + commit SHA sourced from environment variables.

## CI/CD stages
1. **lint**: runs `ruff check`.
2. **tests**: runs `pytest`.
3. **docker-build**: builds container image tarball.
4. **smoke-test**: runs container and validates `/health`.
5. **tag-version**: computes SHA tag and optional semver tag (`vX.Y.Z`).
6. **push-image**: pushes tags to GHCR when branch/tag rules are met.

## GHCR and required permissions/secrets
- Workflow uses `secrets.GITHUB_TOKEN` with `packages: write` permission.
- Ensure repository Actions permissions allow workflow to write packages.
- Optional: if org policy blocks `GITHUB_TOKEN` for GHCR, add `GHCR_PAT` secret (classic token with `write:packages`) and swap login password to `secrets.GHCR_PAT`.

## Release and tagging behavior
- Every eligible run gets a short-SHA tag: `ghcr.io/<owner>/<repo>:<sha7>`.
- If run is from semver Git tag (`v1.2.3`) or release event, image also gets semver tag.

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
├── .github/workflows/ci-cd-docker-release.yml  # 6-stage CI/CD workflow for lint/test/build/smoke/tag/push
├── app.py                                      # FastAPI app with /health and /version endpoints
├── CHANGELOG.md                                # Release history and notable changes
├── CHEATSHEET.md                               # Common local + CI/CD + Docker + release commands
├── Dockerfile                                  # Container build recipe for the app
├── RELEASE.md                                  # Practical release checklist and versioning flow
├── README.md                                   # Project overview, CI/CD behavior, and setup
├── requirements-dev.txt                        # Dev tooling dependencies (pytest, ruff, etc.)
├── requirements.txt                            # Runtime dependencies
└── tests/test_app.py                           # Endpoint tests
```
