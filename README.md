# Mac Control Center

Mac Control Center is a native macOS utility built with SwiftUI and AppKit. It gives you a menu bar entry, a normal Dock window, configurable action buttons, keyboard shortcuts, and lightweight window modes for quick access.

## Build

From the project root:

```bash
chmod +x build.sh
./build.sh
```

This creates `build/MacControlCenter.app`.

If the build fails before compilation starts with an `xcrun` or Command Line Tools error, the issue is usually local macOS tooling rather than project source. Point `xcode-select` at a working Xcode installation or reinstall Command Line Tools, then rerun `./build.sh`.

## Run

```bash
open "build/MacControlCenter.app"
```

You can also launch the built app from Finder.

## Core Behavior

- The app adds a lightning-button status item to the macOS menu bar.
- It also runs as a normal Dock app with a resizable control window.
- Actions can be added, edited, reordered, and run from the main window.
- `Cmd + [Key]` runs a configured action while the window is focused.
- `Ctrl + Cmd + L`, `M`, and `S` switch between Expanded, Mini, and Dot view.
- `Ctrl + Cmd + T` toggles Always on Top.
- `Ctrl + Cmd + D` toggles Show on All Desktops.
- `Cmd + ,` opens or closes inline settings.

## Persistence

- Action definitions are stored in `~/Library/Application Support/MacControlCenter/config.json`.
- Window and preference state are stored in macOS `UserDefaults`.
- The local task tracker lives in `TaskTracker/` and uses browser `localStorage` for personal edits unless you export and commit changes back into the repo.

## Project Docs

- Repo docs index: `docs/README.md`
- Behavior reference: `BEHAVIORS.md`
- Security policy: `SECURITY.md`
- Local task tracker: `TaskTracker/index.html`
- Local docs hub: `TaskTracker/docs.html`

## Current Release State

The project currently supports local builds through `build.sh`. It does not yet have a GitHub Actions release pipeline or a packaged `.dmg`/`.zip` distribution flow.
