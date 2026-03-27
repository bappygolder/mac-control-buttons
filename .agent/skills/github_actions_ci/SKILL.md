---
name: GitHub Actions CI/CD Setup
description: [DRAFT] Instructions and guidelines on how to structure GitHub Actions for CI/CD of our macOS app.
---

# GitHub Actions CI/CD Setup (Work in Progress)

This skill will contain the standard operating procedures for setting up our automated release pipeline on GitHub. 

### Future Subtasks:
- Define a macOS-latest runner configuration.
- Automate Xcodebuild or the `build.sh` script.
- Automate code signing with Apple Developer certificates stored in GitHub Secrets.
- Package the `.app` into a `.zip` or `.dmg` and publish it as a GitHub Release whenever a new tag is pushed.
