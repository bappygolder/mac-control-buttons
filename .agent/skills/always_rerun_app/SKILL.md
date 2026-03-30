---
name: Post-Change Verification
description: Use when changing Mac Control Center code and you need the standard rebuild and relaunch loop after meaningful edits.
---

# Post-Change Verification

When app behavior changes, do not stop at editing files. Run the local verification loop.

## Default Loop

1. Close any running copy of `MacControlCenter` if needed.
2. Run `./build.sh`.
3. Launch with `open "build/MacControlCenter.app"` when interactive validation matters.
4. Re-check the git status so generated files are not accidentally staged.

If the work is docs-only or tracker-only, a rebuild is optional.
