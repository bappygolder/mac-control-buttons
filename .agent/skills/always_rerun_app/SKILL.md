---
name: Always Re-run Application
description: Guidelines emphasizing continuous testing and automatic relaunching of the application after every major change.
---

# Continuous Rebuild & Relaunch Workflow

## Overview
This skill acts as an absolute AI guideline: Do not develop the Mac Control Center app in phases without testing! Every single time a code update or a significant improvement is made, you **MUST** automatically close the existing app, rebuild it, and launch it again. 

## The Re-Run Cycle
Perform the following sequence immediately after any updates:
1. **Kill the App:** Use `pkill -f MacControlCenter` or close it gracefully so the port/resources are freed.
2. **Rebuild:** Execute `./build.sh` at the root directory.
3. **Re-run:** Launch the new build automatically using `open "build/MacControlCenter.app"`.

This guarantees that the app is consistently verified and you get immediate feedback.
