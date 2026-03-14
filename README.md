# ci-cd-docker-release

Repeatable LocalStack lab for free-tier services: S3, SQS, SNS, DynamoDB,
Secrets Manager, and SSM with idempotent scripts, Makefile wrappers, and CI
smoke verification.

## What this repo is for

Use this repo to practice a local infrastructure validation flow:

- start a LocalStack environment
- seed common AWS-style resources safely
- run smoke checks against S3, SQS, SNS, and DynamoDB
- understand how shell-based CI can gate infrastructure labs

## Repo Map

- `docker-compose.yml` - LocalStack service plus optional helper profile.
- `scripts/up.sh` - starts LocalStack and waits for health.
- `scripts/seed.sh` - idempotently creates sample resources.
- `scripts/smoke.sh` - verifies S3, SQS, SNS publish, and DynamoDB put/get.
- `scripts/down.sh` - tears down the stack, with optional purge mode.
- `scripts/pipeline-local.sh` - local CI-equivalent stage runner.
- `Makefile` - concise wrappers for the script workflow.
- `.github/workflows/ci-cd-docker-release.yml` - CI gating pipeline.
- `.yamllint.yml` - YAML linting rules.
- `CHEATSHEET.md` - high-signal AWS CLI commands for this lab.
- `FILES_EXPLAINED.md` - file-by-file explanation of repository contents.

## Quick Start

```bash
make up
make seed
make smoke
make down
```

## Local Steps

1. Ensure Docker and Docker Compose are available.
2. Ensure AWS CLI v2 is installed locally.
3. Start LocalStack with `make up`.
4. Seed resources with `make seed`.
5. Run smoke checks with `make smoke`.
6. Stop the environment with `make down`.

## Optional tools container usage

```bash
docker compose --profile tools up -d awslocal
docker compose exec awslocal aws --endpoint-url http://localstack:4566 s3 ls
```

## Run pipeline locally

```bash
make pipeline
```

## CI gating

The workflow keeps these stages separate:

1. `shell-check`
2. `yamllint`
3. `compose-up`
4. `smoke`

## Troubleshooting

- `aws: command not found`: install AWS CLI or use the optional tools container.
- Port `4566` in use: stop the conflicting service or remap ports.
- Health timeout: inspect `docker compose logs localstack`.
- Stale state: run `make clean`.

## Cleanup

```bash
make down
make clean
```
