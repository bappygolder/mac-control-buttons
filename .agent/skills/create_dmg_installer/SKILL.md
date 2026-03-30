---
name: Release Packaging Plan
description: Use when planning or implementing a user-facing packaged release for Mac Control Center.
---

# Release Packaging Plan

This repo does not yet ship a packaged installer. Use this checklist when moving from local builds to distributable artifacts.

## Checklist

1. Make sure `./build.sh` produces a stable app bundle.
2. Decide whether the first release artifact is `.zip` or `.dmg`.
3. Add a repeatable packaging script before publishing manually built artifacts.
4. Document signing and notarization requirements separately from local packaging.
5. Update `docs/RELEASE_AND_DEPLOYMENT.md` when the packaging flow changes.
