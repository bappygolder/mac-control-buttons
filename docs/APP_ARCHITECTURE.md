# App Architecture

## Runtime Entry Point

`Sources/MacControlCenter/main.swift` starts the app, creates the status-item menu, opens the main window, and keeps the menu synchronized with configuration changes.

## Main Components

### `AppDelegate`

- Creates the menu bar status item
- Builds the status menu from saved actions
- Opens and restores the main window
- Rebuilds the menu when configuration changes

### `ConfigManager`

- Owns the action list
- Loads and saves `config.json`
- Normalizes action data before persistence
- Publishes change notifications so the UI and menu stay in sync

### `ActivityHandler`

- Receives an `ActionButton`
- Validates `actionType` and `actionTarget`
- Launches applications with `NSWorkspace` or shell commands with `/bin/sh -c`
- Shows notifications on invalid or failed actions

### `SettingsHostingView`

- Renders the main SwiftUI interface
- Owns view-mode transitions and inline settings/edit/add flows
- Applies window decoration changes based on the active mode
- Registers a local key monitor for app shortcuts

### `AppSettings`

- Stores UI preference state in `UserDefaults`
- Applies window-level side effects such as opacity, topmost level, all-desktops behavior, and launch-at-login

## Window Model

The app uses one primary `NSWindow` with multiple presentations:

- Expanded: full action manager
- Mini: compact quick-run view
- Dot: borderless click target

The window attempts to stay anchored while changing size so mode switches feel stable rather than jumpy.

## Menu Model

The status bar menu is generated from the saved action list. This means action changes in the main app window immediately affect the menu bar surface after `ConfigManager.save()`.

## Recommended Architectural Direction

- Keep action execution isolated from UI state
- Keep persistence rules centralized in `ConfigManager` and `AppSettings`
- Avoid hardcoding machine-specific apps or personal workflows into source
- Treat `TaskTracker/` and `docs/` as project-operating artifacts, not runtime app assets
