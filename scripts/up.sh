#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if docker compose ps localstack --status running >/dev/null 2>&1; then
  echo "localstack is already running"
else
  docker compose up -d localstack
fi

echo "waiting for localstack health..."
for _ in {1..40}; do
  status="$(docker inspect --format='{{json .State.Health.Status}}' localstack 2>/dev/null || true)"
  if [[ "$status" == '"healthy"' ]]; then
    echo "localstack is healthy"
    exit 0
  fi
  sleep 2
done

echo "localstack did not become healthy in time" >&2
exit 1
