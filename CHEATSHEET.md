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
```

## Run app locally
```bash
uvicorn app:app --host 0.0.0.0 --port 8000
curl -s http://localhost:8000/health
curl -s http://localhost:8000/version
```

## Docker local lifecycle
```bash
docker build -t ci-cd-docker-release:local .
docker run --rm -p 8000:8000 \
  -e APP_VERSION=local-dev \
  -e GIT_SHA=$(git rev-parse --short HEAD) \
  ci-cd-docker-release:local
```

## Docker smoke test (manual)
```bash
docker run -d --name smoke -p 8000:8000 ci-cd-docker-release:local
curl -fsS http://localhost:8000/health
docker logs smoke
docker rm -f smoke
```

## Tagging & release
```bash
git tag v0.1.0                 # Create semver tag
git push origin v0.1.0         # Trigger semver image publish
gh release create v0.1.0 --generate-notes
```

## GHCR auth and push (manual fallback)
```bash
echo "$GITHUB_TOKEN" | docker login ghcr.io -u <github-user> --password-stdin
docker tag ci-cd-docker-release:local ghcr.io/<owner>/<repo>:$(git rev-parse --short HEAD)
docker push ghcr.io/<owner>/<repo>:$(git rev-parse --short HEAD)
```

## Debugging CI quickly
```bash
git status
git log --oneline -n 5
git show --name-only
act -j tests                   # If using nektos/act locally
docker system df
```

## Useful one-liners
```bash
git rev-parse --short HEAD
git describe --tags --always
git tag --list 'v*'
```
