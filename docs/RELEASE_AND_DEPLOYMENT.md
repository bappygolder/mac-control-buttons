# Release and Deployment

## Current State

The project supports local builds with `build.sh`.

Current release process:

1. Run `./build.sh`
2. Open `build/MacControlCenter.app`
3. Optionally install with `./build.sh --install`

## What Does Not Exist Yet

- GitHub Actions build pipeline
- packaged `.dmg` or `.zip`
- automated versioning
- notarization / formal signing flow
- GitHub Release publishing

## Recommended Release Plan

### Phase 1

- Add a GitHub Actions workflow that runs `./build.sh` on macOS
- Publish build logs and archive the app bundle as an artifact

### Phase 2

- Package `.app` into `.zip` or `.dmg`
- Add versioning discipline
- Publish GitHub Releases from tags

### Phase 3

- Add formal signing and notarization if distribution expands beyond local or trusted users

## "Push Live" Clarification

At the moment, pushing to GitHub updates the codebase, but it does not deploy a hosted app or release artifact. A real "live release" will require the release work above.
