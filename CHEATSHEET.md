# CI/CD + Docker Release Cheatsheet

## Python environment
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
```

## Local quality
```bash
ruff check .                    # Lint and import ordering
pytest -q                       # Run test suite
python -m compileall app.py tests
```

## Run app locally
```bash
uvicorn app:app --host 0.0.0.0 --port 8000
curl -s http://localhost:8000/health
curl -s http://localhost:8000/version
```

## Docker lifecycle (local)
```bash
docker build -t ci-cd-docker-release:local .
docker run --rm -p 8000:8000 \
  -e APP_VERSION=local-dev \
  -e GIT_SHA=$(git rev-parse --short HEAD) \
  ci-cd-docker-release:local
```

## Docker smoke test (local)
```bash
docker run -d --name smoke -p 8000:8000 \
  -e APP_VERSION=smoke \
  -e GIT_SHA=smoke-sha \
  ci-cd-docker-release:local
curl -fsS http://localhost:8000/health
curl -fsS http://localhost:8000/version
docker logs smoke
docker rm -f smoke
```

## Tagging & release
```bash
git tag v0.1.0                 # Create semver tag
git push origin v0.1.0         # Trigger semver publish
gh release create v0.1.0 --generate-notes
```

## GHCR auth and manual push fallback
```bash
echo "$GITHUB_TOKEN" | docker login ghcr.io -u <github-user> --password-stdin
docker tag ci-cd-docker-release:local ghcr.io/<owner>/<repo>:$(git rev-parse --short HEAD)
docker push ghcr.io/<owner>/<repo>:$(git rev-parse --short HEAD)
```

## Actions troubleshooting
```bash
# Why was push-image skipped?
# Because event/ref didn't match: main push, semver tag, or release.

git status
git log --oneline -n 5
git show --name-only
```

## Useful one-liners
```bash
git rev-parse --short HEAD
git describe --tags --always
git tag --list 'v*'
```
