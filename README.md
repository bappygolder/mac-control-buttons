# Mac Control Center

A blazing fast, native macOS menu bar app built with Swift and AppKit. 
(Replaces the old Python + rumps setup with pure Apple native code!)

## Setup & Compilation

You don't need Python or virtual environments anymore. To build the app yourself:

```bash
cd "/Users/bappygolder/Desktop/Projects/_1. Co-Work Projects/0A. Mac Control Centre copy"
chmod +x build.sh
./build.sh
```

This will create a `build/MacControlCenter.app` application bundle.

## How to Run the App

Whenever you restart your Mac or want to launch the app, simply run the compiled app:

```bash
open "/Users/bappygolder/Desktop/Projects/_1. Co-Work Projects/0A. Mac Control Centre copy/build/MacControlCenter.app"
```

*Alternatively, you can just double click `build/MacControlCenter.app` in Finder.* It will run silently in the background and show up in your menu bar.

## What to Expect

- A ⚡ icon appears in the macOS menu bar.
- Clicking it shows menu items like your custom actions:
  - Start My Day
  - Post The Next Comment
  - ⚙️ Settings
  - Quit
- Clicking "Settings" opens a native macOS unified settings window.
- In Settings, you can dynamically Add, Run, and Delete actions, as well as assign keyboard shortcuts!
- The configuration is saved automatically to `config.json`.
- Quit closes the app entirely.

## macOS Permissions

macOS may prompt to allow Notifications for the app. Allowing them enables the click notifications when an action runs.

## Roadmap & Future Features

- **Downloadable Installer:** Create a compiled `.dmg` or `.app.zip` release so non-developers can simply download and install the app without running terminal build scripts.
- **Automated CI/CD:** Set up GitHub Actions or a similar pipeline to automatically build and publish release binaries whenever new features are pushed.
- **System Integration:** Options to Launch at Login automatically and seamless installation into the `/Applications` folder.
