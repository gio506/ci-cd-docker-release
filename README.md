# compose-localstack

Repeatable LocalStack lab for free-tier services: S3, SQS, SNS, DynamoDB, Secrets Manager, and SSM with idempotent scripts, Makefile wrappers, and CI smoke verification.

## Repo Map
- `docker-compose.yml` — LocalStack service (S3/SQS/SNS/DynamoDB/Secrets Manager/SSM) plus optional `awslocal` tools container profile.
- `scripts/up.sh` — starts LocalStack and waits for healthy status (idempotent).
- `scripts/seed.sh` — creates bucket, queue, topic, and DynamoDB table only if missing (idempotent).
- `scripts/smoke.sh` — verifies S3, SQS, SNS publish, and DynamoDB put/get.
- `scripts/down.sh` — tears down stack, with optional `--purge` volume cleanup.
- `Makefile` — concise wrappers for script workflow.
- `.github/workflows/ci-cd-docker-release.yml` — CI gating pipeline for lint/up/smoke+teardown.
- `.yamllint.yml` — YAML linting rules tuned for GitHub Actions files.
- `CHEATSHEET.md` — high-signal `awslocal`/AWS CLI commands for this lab.
- `FILES_EXPLAINED.md` — file-by-file explanation of repository contents.

## Quick Start
```bash
make up
make seed
make smoke
make down
```

## Local Steps
1. Ensure Docker and Docker Compose are available.
2. Ensure AWS CLI v2 is installed locally (`aws --version`).
3. Start LocalStack:
   ```bash
   make up
   ```
4. Seed resources:
   ```bash
   make seed
   ```
5. Run smoke checks:
   ```bash
   make smoke
   ```
6. Stop environment:
   ```bash
   make down
   ```

## Optional tools container usage
Start tools profile:
```bash
docker compose --profile tools up -d awslocal
```
Run AWS CLI against LocalStack inside container:
```bash
docker compose exec awslocal aws --endpoint-url http://localstack:4566 s3 ls
```

## CI gating (PR into `main`)
Pull requests targeting `main` must pass all 4 stages:
1. `shell-check` validates script syntax with `bash -n`.
2. `yamllint` for workflow + compose files.
3. `compose-up` starts LocalStack and waits for health.
4. `smoke` runs `scripts/smoke.sh` and always tears down (`scripts/down.sh --purge`).

This acts as PR gate before merge.

## Troubleshooting
- **`aws: command not found`**: install AWS CLI v2 locally or use the optional tools container.
- **Port 4566 in use**: stop conflicting service or remap ports in `docker-compose.yml`.
- **Health check timeout**: run `docker compose logs localstack` and verify Docker resources.
- **Stale state**: run `make clean` to remove containers and LocalStack data volume.

## Cleanup
- Standard stop:
  ```bash
  make down
  ```
- Full cleanup (remove volumes/state):
  ```bash
  make clean
  ```
