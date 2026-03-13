# FILES_EXPLAINED

- `docker-compose.yml`: defines LocalStack with S3/SQS and optional AWS CLI helper container.
- `scripts/up.sh`: idempotent startup and health wait.
- `scripts/seed.sh`: idempotent creation of bucket/queue.
- `scripts/smoke.sh`: integration smoke checks for S3 and SQS.
- `scripts/down.sh`: stop stack, optional purge mode.
- `Makefile`: command wrappers for local workflow.
- `.github/workflows/ci-cd-docker-release.yml`: CI stages for lint, compose health, and smoke+teardown.
- `.yamllint.yml`: YAML linting configuration used locally and in CI.
- `README.md`: usage, repo map, troubleshooting, cleanup, and PR gate notes.
- `CHEATSHEET.md`: copy/paste AWS CLI commands for LocalStack.
- `FILES_EXPLAINED.md`: concise inventory for all important files.
