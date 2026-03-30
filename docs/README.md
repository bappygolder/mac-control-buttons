# Documentation Index

This folder is the project documentation home for Mac Control Center.

## Core Docs

- `PROJECT_OVERVIEW.md`: Product summary, repo layout, and current scope.
- `PROJECT_AUDIT.md`: Current-state audit and recommended next steps.
- `APP_ARCHITECTURE.md`: High-level code architecture and runtime flow.
- `ACTION_SYSTEM.md`: How actions are modeled, persisted, and executed.
- `PERSISTENCE_AND_STATE.md`: What data lives where and how it survives restarts.
- `LOCAL_PROJECT_SYSTEM.md`: How the local tracker, docs hub, and online sync model should work.
- `RELEASE_AND_DEPLOYMENT.md`: Current release process and future packaging/CI plan.
- `UI_AND_UX_GUIDELINES.md`: Native macOS design and interaction rules for this app.

## Root-Level Reference Files

- `../README.md`: Quick start and repo-level overview.
- `../BEHAVIORS.md`: User-visible behavior log.
- `../SECURITY.md`: Public repo and secrets guidance.

## Maintenance Rule

When product behavior changes, update the architecture or behavior docs in the same pass. When project-management workflow changes, update `LOCAL_PROJECT_SYSTEM.md` and the TaskTracker pages together.
