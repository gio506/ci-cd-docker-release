#!/usr/bin/env bash
# Purpose: Tag and trigger a semantic release
# Usage: bash scripts/tag-release.sh <major|minor|patch> "Release message"
#
# Prerequisites: git, clean working tree, on main branch

set -euo pipefail

BUMP="${1:-patch}"
MESSAGE="${2:-Release $(date +%Y-%m-%d)}"

# Ensure we're on main
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "ERROR: Must be on main branch (currently on: $CURRENT_BRANCH)"
  exit 1
fi

# Ensure working tree is clean
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: Working tree is not clean. Commit or stash changes first."
  git status --short
  exit 1
fi

# Get latest tag or default to v0.0.0
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Latest tag: $LATEST_TAG"

# Parse major.minor.patch
VERSION=${LATEST_TAG#v}
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
PATCH=$(echo "$VERSION" | cut -d. -f3)

# Bump the requested component
case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *) echo "Usage: $0 <major|minor|patch>"; exit 1 ;;
esac

NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
echo "New tag: $NEW_TAG"
echo ""

read -r -p "Create and push tag $NEW_TAG? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

git tag -a "$NEW_TAG" -m "$MESSAGE"
git push origin "$NEW_TAG"

echo ""
echo "Tag $NEW_TAG pushed. GitHub Actions will start the release pipeline."
