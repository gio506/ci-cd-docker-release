#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

stage() {
  local name="$1"
  shift
  echo
  echo "==> ${name}"
  "$@"
}

warn_missing() {
  local tool="$1"
  echo "[WARN] ${tool} not installed; stage skipped in local runner"
}

stage "shell-check" bash -n scripts/*.sh

if command -v yamllint >/dev/null 2>&1; then
  stage "yamllint" yamllint -c .yamllint.yml docker-compose.yml .github/workflows/ci-cd-docker-release.yml .yamllint.yml
else
  warn_missing "yamllint"
fi

if command -v docker >/dev/null 2>&1; then
  stage "compose-up" ./scripts/up.sh
  stage "health" curl -fsS http://localhost:4566/_localstack/health

  if command -v aws >/dev/null 2>&1; then
    stage "smoke" ./scripts/smoke.sh
  else
    echo "[INFO] aws cli not found; smoke will use awslocal helper container"
    stage "smoke" ./scripts/smoke.sh
  fi

  stage "teardown" ./scripts/down.sh --purge
else
  warn_missing "docker"
fi

echo

echo "Local pipeline runner finished."
