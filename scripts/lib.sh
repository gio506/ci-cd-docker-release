#!/usr/bin/env bash
set -euo pipefail

aws_exec() {
  local endpoint="$1"
  shift

  if command -v aws >/dev/null 2>&1; then
    aws --endpoint-url "$endpoint" "$@"
  else
    docker compose run --rm --no-deps \
      -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}" \
      -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}" \
      -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}" \
      awslocal aws --endpoint-url "${endpoint/localhost/localstack}" "$@"
  fi
}
