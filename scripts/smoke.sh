#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUCKET_NAME="${BUCKET_NAME:-lab-bucket}"
QUEUE_NAME="${QUEUE_NAME:-lab-queue}"
TOPIC_NAME="${TOPIC_NAME:-lab-topic}"
TABLE_NAME="${TABLE_NAME:-lab-table}"
SECRET_NAME="${SECRET_NAME:-lab-secret}"
PARAMETER_NAME="${PARAMETER_NAME:-/lab/app/config}"
AWS_ENDPOINT="${AWS_ENDPOINT:-http://localhost:4566}"
AWS_REGION="${AWS_REGION:-us-east-1}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="$AWS_REGION"

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
./scripts/seed.sh

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "smoke-object-content" > "$tmp_dir/object.txt"
aws_exec "$AWS_ENDPOINT" s3 cp "$tmp_dir/object.txt" "s3://${BUCKET_NAME}/object.txt" >/dev/null
aws_exec "$AWS_ENDPOINT" s3 cp "s3://${BUCKET_NAME}/object.txt" "$tmp_dir/object.out" >/dev/null
grep -q "smoke-object-content" "$tmp_dir/object.out"
echo "s3 put/get smoke passed"

QUEUE_URL="$(aws_exec "$AWS_ENDPOINT" sqs get-queue-url --queue-name "$QUEUE_NAME" --query 'QueueUrl' --output text)"
aws_exec "$AWS_ENDPOINT" sqs send-message --queue-url "$QUEUE_URL" --message-body "smoke-message" >/dev/null
MESSAGE_BODY="$(aws_exec "$AWS_ENDPOINT" sqs receive-message --queue-url "$QUEUE_URL" --max-number-of-messages 1 --wait-time-seconds 1 --query 'Messages[0].Body' --output text)"
[[ "$MESSAGE_BODY" == "smoke-message" ]]
echo "sqs send/receive smoke passed"

TOPIC_ARN="$(aws_exec "$AWS_ENDPOINT" sns create-topic --name "$TOPIC_NAME" --query 'TopicArn' --output text)"
MSG_ID="$(aws_exec "$AWS_ENDPOINT" sns publish --topic-arn "$TOPIC_ARN" --message 'smoke-topic-message' --query 'MessageId' --output text)"
[[ "$MSG_ID" != "None" ]]
echo "sns publish smoke passed"

aws_exec "$AWS_ENDPOINT" dynamodb put-item --table-name "$TABLE_NAME" --item '{"id":{"S":"smoke"},"value":{"S":"ok"}}' >/dev/null
DDB_VALUE="$(aws_exec "$AWS_ENDPOINT" dynamodb get-item --table-name "$TABLE_NAME" --key '{"id":{"S":"smoke"}}' --query 'Item.value.S' --output text)"
[[ "$DDB_VALUE" == "ok" ]]
echo "dynamodb put/get smoke passed"

aws_exec "$AWS_ENDPOINT" secretsmanager create-secret \
  --name "$SECRET_NAME" \
  --secret-string 'smoke-secret-value' >/dev/null 2>&1 || \
aws_exec "$AWS_ENDPOINT" secretsmanager put-secret-value \
  --secret-id "$SECRET_NAME" \
  --secret-string 'smoke-secret-value' >/dev/null
SECRET_VALUE="$(aws_exec "$AWS_ENDPOINT" secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text)"
[[ "$SECRET_VALUE" == "smoke-secret-value" ]]
echo "secretsmanager put/get smoke passed"

aws_exec "$AWS_ENDPOINT" ssm put-parameter \
  --name "$PARAMETER_NAME" \
  --type String \
  --value 'smoke-parameter-value' \
  --overwrite >/dev/null
PARAMETER_VALUE="$(aws_exec "$AWS_ENDPOINT" ssm get-parameter --name "$PARAMETER_NAME" --query 'Parameter.Value' --output text)"
[[ "$PARAMETER_VALUE" == "smoke-parameter-value" ]]
echo "ssm put/get smoke passed"

echo "all smoke checks passed"
