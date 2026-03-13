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
