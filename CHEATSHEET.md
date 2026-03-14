# LocalStack S3 + SQS Cheatsheet

## Defaults used by scripts

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT=http://localhost:4566
```

## S3 (LocalStack)

```bash
aws --endpoint-url "$AWS_ENDPOINT" s3api create-bucket --bucket lab-bucket
aws --endpoint-url "$AWS_ENDPOINT" s3 ls
aws --endpoint-url "$AWS_ENDPOINT" s3 cp ./file.txt s3://lab-bucket/file.txt
aws --endpoint-url "$AWS_ENDPOINT" s3 cp s3://lab-bucket/file.txt ./file.out.txt
```

## SQS (LocalStack)

```bash
aws --endpoint-url "$AWS_ENDPOINT" sqs create-queue --queue-name lab-queue
aws --endpoint-url "$AWS_ENDPOINT" sqs get-queue-url --queue-name lab-queue
QUEUE_URL=$(aws --endpoint-url "$AWS_ENDPOINT" sqs get-queue-url --queue-name lab-queue --query 'QueueUrl' --output text)
aws --endpoint-url "$AWS_ENDPOINT" sqs send-message --queue-url "$QUEUE_URL" --message-body "hello"
aws --endpoint-url "$AWS_ENDPOINT" sqs receive-message --queue-url "$QUEUE_URL" --max-number-of-messages 1
```

## Optional tools container

```bash
docker compose --profile tools up -d awslocal
docker compose exec awslocal aws --endpoint-url http://localstack:4566 s3 ls
```

## SNS + DynamoDB

```bash
aws --endpoint-url "$AWS_ENDPOINT" sns create-topic --name lab-topic
TOPIC_ARN=$(aws --endpoint-url "$AWS_ENDPOINT" sns create-topic --name lab-topic --query 'TopicArn' --output text)
aws --endpoint-url "$AWS_ENDPOINT" sns publish --topic-arn "$TOPIC_ARN" --message "hello"

aws --endpoint-url "$AWS_ENDPOINT" dynamodb create-table \
  --table-name lab-table \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
aws --endpoint-url "$AWS_ENDPOINT" dynamodb put-item --table-name lab-table --item '{"id":{"S":"1"},"value":{"S":"ok"}}'
aws --endpoint-url "$AWS_ENDPOINT" dynamodb get-item --table-name lab-table --key '{"id":{"S":"1"}}'
```
