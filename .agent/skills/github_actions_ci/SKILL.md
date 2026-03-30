---
name: GitHub Actions CI
description: Use when adding or updating GitHub Actions for Mac Control Center build verification or release automation.
---

# GitHub Actions CI

Prefer small, verifiable steps.

## Phase Order

1. Add a macOS runner that executes `./build.sh`.
2. Preserve build logs and artifacts.
3. Only then add packaging, release uploads, signing, or notarization.

Update `docs/RELEASE_AND_DEPLOYMENT.md` when the workflow changes.
