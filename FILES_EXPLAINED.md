# FILES_EXPLAINED

- `docker-compose.yml`: defines LocalStack with free-tier services (S3, SQS, SNS, DynamoDB, Secrets Manager, SSM) and optional AWS CLI helper container.
- `scripts/up.sh`: idempotent startup and health wait.
- `scripts/seed.sh`: idempotent creation of bucket/queue/topic/table.
- `scripts/smoke.sh`: integration smoke checks for S3, SQS, SNS, and DynamoDB.
- `scripts/down.sh`: stop stack, optional purge mode.
- `scripts/pipeline-local.sh`: local CI-equivalent stage runner with environment-aware skips.
- `Makefile`: command wrappers for local workflow.
- `.github/workflows/ci-cd-docker-release.yml`: CI stages for shell syntax checks, YAML lint, compose health, and smoke+teardown.
- `.yamllint.yml`: YAML linting configuration used locally and in CI.
- `README.md`: usage, repo map, troubleshooting, cleanup, and PR gate notes.
- `CHEATSHEET.md`: copy/paste AWS CLI commands for LocalStack.
- `FILES_EXPLAINED.md`: concise inventory for all important files.
