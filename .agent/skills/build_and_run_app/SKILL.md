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

Whenever you are instructed to verify the app or test changes, you should compile the source files using the bash script above.
