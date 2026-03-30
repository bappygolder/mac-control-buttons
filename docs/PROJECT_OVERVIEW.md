# Project Overview

## What This App Is

Mac Control Center is a native macOS utility that gives the user a compact control hub for launching apps, running shell commands, and switching between multiple window modes. It replaces an older Python-based setup with a SwiftUI and AppKit app bundle.

## Current Capabilities

- Menu bar status item with a quick access menu
- Main Dock window for managing actions
- Expanded, Mini, and Dot display modes
- Inline settings and inline action creation
- Editable action list with reorder support
- Local persistence for action configuration and window preferences
- Quick-launch dock for a few frequently used apps

## Repo Layout

- `Sources/MacControlCenter/`: Swift source for app startup, settings UI, config persistence, and action execution
- `Resources/`: app icon and bundle assets
- `build.sh`: local build and optional install script
- `TaskTracker/`: local-first task tracker and documentation hub
- `docs/`: markdown documentation for product, architecture, persistence, release, and workflow
- `BEHAVIORS.md`: compact behavior log for user-visible interactions

## Current Constraints

- No automated tests yet
- No packaged release workflow yet
- No GitHub Actions CI/CD yet
- Launch-at-login currently uses AppleScript login items instead of a modern service-management API
- TaskTracker is local-first and browser-persistent, not automatically synced online

## Working Assumption

The repo is the durable project record. The browser-based tracker is a fast local workspace layered on top of repo-owned seed data.
