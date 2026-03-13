#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUCKET_NAME="${BUCKET_NAME:-lab-bucket}"
QUEUE_NAME="${QUEUE_NAME:-lab-queue}"
TOPIC_NAME="${TOPIC_NAME:-lab-topic}"
TABLE_NAME="${TABLE_NAME:-lab-table}"
AWS_ENDPOINT="${AWS_ENDPOINT:-http://localhost:4566}"
AWS_REGION="${AWS_REGION:-us-east-1}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="$AWS_REGION"

./scripts/up.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if aws_exec "$AWS_ENDPOINT" s3api head-bucket --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
  echo "bucket exists: $BUCKET_NAME"
else
  aws_exec "$AWS_ENDPOINT" s3api create-bucket --bucket "$BUCKET_NAME" >/dev/null
  echo "bucket created: $BUCKET_NAME"
fi

if aws_exec "$AWS_ENDPOINT" sqs get-queue-url --queue-name "$QUEUE_NAME" >/dev/null 2>&1; then
  echo "queue exists: $QUEUE_NAME"
else
  aws_exec "$AWS_ENDPOINT" sqs create-queue --queue-name "$QUEUE_NAME" >/dev/null
  echo "queue created: $QUEUE_NAME"
fi

if aws_exec "$AWS_ENDPOINT" sns create-topic --name "$TOPIC_NAME" >/dev/null 2>&1; then
  echo "topic ready: $TOPIC_NAME"
fi

if aws_exec "$AWS_ENDPOINT" dynamodb describe-table --table-name "$TABLE_NAME" >/dev/null 2>&1; then
  echo "table exists: $TABLE_NAME"
else
  aws_exec "$AWS_ENDPOINT" dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST >/dev/null
  aws_exec "$AWS_ENDPOINT" dynamodb wait table-exists --table-name "$TABLE_NAME"
  echo "table created: $TABLE_NAME"
fi
