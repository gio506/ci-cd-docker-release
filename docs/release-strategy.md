# CI/CD Docker Release — Release Strategy

This document explains the branching and release strategy for this project.

## Branch Model

```text
main         ← stable, tagged releases only
  └── dev    ← integration — all PRs merge here first
        └── feat/* hotfix/* ← short-lived work branches
```

### Why dev → main (not feature → main)?

Merging directly to main means every merge is a release candidate. `dev` acts as a staging area:
- Multiple features accumulate without individual releases
- Integration bugs surface before tagging
- `main` always represents a release-quality commit

---

## Release Flow

```text
1. Features merged to dev
2. QA/smoke tests pass on dev
3. PR: dev → main (requires 1 reviewer approval)
4. Tag: git tag -a v1.2.0 -m "Release v1.2.0"
5. GitHub Actions builds image, pushes to registry
6. CHANGELOG updated
```

---

## Semantic Versioning

Format: `MAJOR.MINOR.PATCH`

| Part | When to increment | Example |
|---|---|---|
| MAJOR | Breaking change in API/behavior | `1.0.0 → 2.0.0` |
| MINOR | New feature, backward-compatible | `1.0.0 → 1.1.0` |
| PATCH | Bug fix, backward-compatible | `1.0.0 → 1.0.1` |

**Pre-release suffix**: Use `-dev`, `-rc1` etc. for non-stable tags: `1.2.0-rc1`

---

## Docker Registry Strategy

Tags pushed on each release:
- `image:1.2.0` — immutable, pinned version
- `image:1.2` — minor version float
- `image:latest` — most recent stable (avoid in production deployments)

**Why not just `latest`?** `latest` is a moving target. Pinning `1.2.0` in production means rollbacks are deterministic.

---

## Rollback Procedure

If a release breaks production:

```bash
# Roll back the deployment to previous image
docker service update --image myapp:1.1.3 myservice

# Or revert in Kubernetes
kubectl rollout undo deployment/myapp

# Tag the bad release with -broken suffix in git for tracking
git tag -a v1.2.0-broken -m "Do not use — caused 503s in prod"
git push origin v1.2.0-broken
```
