#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ "${1:-}" == "--purge" ]]; then
  docker compose down -v --remove-orphans
  echo "stack stopped and volumes removed"
else
  docker compose down --remove-orphans
  echo "stack stopped"
fi
