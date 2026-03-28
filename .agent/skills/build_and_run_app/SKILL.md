---
name: Build and Run App
description: Instructions on how to compile, build, install, and run the Mac Control Center application natively.
---

# Build and Run App

This skill provides the steps on how to properly build and install the Mac Control Center app.

## Prerequisites
Make sure you are in the root directory of the project.

## Building the App
To build the application without installing it into the system Applications folder, run the following bash command:
```bash
./build.sh
```

## Installing the App
If you are ready to install the application system-wide (into `/Applications`), run the following command:
```bash
./build.sh --install
```

## Running the App
Once built (even without installing), you can open the locally built app bundle by using:
```bash
open "build/MacControlCenter.app"
```

## Development Workflow: Always Re-run
CRITICAL AI GUIDELINE: Every single time significant improvements or code updates are made, you **MUST** automatically close the existing running application, rebuild it, and re-run it. 
Do not develop in isolated phases without testing. Always perform the following cycle after making updates:
1. Kill the existing run: `pkill -f MacControlCenter` (or close it gracefully if possible).
2. Rebuild: `./build.sh`
3. Re-run: `open "build/MacControlCenter.app"`

This ensures that the app is constantly tested and verified. Make this a continuous and automatic habit during development.
