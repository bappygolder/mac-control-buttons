# Mac Control Center

A native macOS control app built with SwiftUI and AppKit.
It presents a lightning button in the menu bar and a normal Dock app window, replacing the older Python + rumps setup with a single Apple-native bundle.

## Setup & Compilation

You don't need Python or virtual environments anymore. To build the app yourself:

```bash
cd "/Users/bappygolder/Desktop/Projects/_1. Co-Work Projects/0A. Mac Control Centre copy"
chmod +x build.sh
./build.sh
```

This will create a `build/MacControlCenter.app` application bundle.

If the build fails before compilation starts with an `xcrun` or Command Line Tools error, the issue is with the local macOS toolchain rather than the project source. Reinstall Command Line Tools or point `xcode-select` at a working Xcode installation, then rerun `./build.sh`.

## How to Run the App

Whenever you restart your Mac or want to launch the app, simply run the compiled app:

```bash
open "/Users/bappygolder/Desktop/Projects/_1. Co-Work Projects/0A. Mac Control Centre copy/build/MacControlCenter.app"
```

*Alternatively, you can just double click `build/MacControlCenter.app` in Finder.* The app opens a regular macOS window, appears in the Dock while running, and also adds a lightning button to the menu bar.

## What to Expect

- A template bolt icon appears in the macOS menu bar.
- The app also appears in the Dock while it is running.
- Clicking it shows menu items like your custom actions:
  - Open Control Center
  - Reset Window Size
  - Your configured actions
  - Quit
- Pressing `Cmd + [Key]` runs a configured action while the app window is focused.
- `Ctrl + Cmd + L`, `M`, and `S` switch between Expanded, Mini, and Dot view.
- `Ctrl + Cmd + T` toggles Always on Top, `Ctrl + Cmd + D` toggles Show on All Desktops, and `Cmd + ,` toggles inline settings.
- In Settings, you can dynamically add, run, edit, delete, and reorder actions.
- The configuration is saved automatically to `~/Library/Application Support/MacControlCenter/config.json`.
- Quit closes the app entirely.

## macOS Permissions

macOS may prompt to allow Notifications for the app. Allowing them enables the click notifications when an action runs.

## Roadmap & Future Features

- **Downloadable Installer:** Create a compiled `.dmg` or `.app.zip` release so non-developers can simply download and install the app without running terminal build scripts.
- **Automated CI/CD:** Set up GitHub Actions or a similar pipeline to automatically build and publish release binaries whenever new features are pushed.
- **System Integration:** Options to Launch at Login automatically and seamless installation into the `/Applications` folder.
