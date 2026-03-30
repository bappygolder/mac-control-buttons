---
name: Build and Run App
description: Use when you need the canonical local build, install, or launch workflow for Mac Control Center.
---

# Build and Run App

Run these commands from the repo root.

## Building the App

```bash
./build.sh
```

## Installing the App

```bash
./build.sh --install
```

## Running the App

```bash
open "build/MacControlCenter.app"
```

## Toolchain Note

If `swift` or `swiftc` fail natively, `build.sh` already attempts a Rosetta fallback before failing.
