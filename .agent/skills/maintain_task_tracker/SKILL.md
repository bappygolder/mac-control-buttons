---
name: Maintain Task Tracker
description: Use when updating the local TaskTracker workspace, project docs index, or repo-owned backlog for Mac Control Center.
---

# Maintain Task Tracker

Use this skill when changing `TaskTracker/` or project-management docs.

## Rules

1. Keep repo-owned seed data in `TaskTracker/project-data.js`.
2. Treat browser edits as local working state, not automatic repo updates.
3. Mark AI-suggested backlog items with `source: recommended` and `recommendedBy: Codex (GPT-5)`.
4. If docs structure changes, update both `TaskTracker/docs.html` and `docs/README.md`.
5. If persistence behavior changes, update `docs/PERSISTENCE_AND_STATE.md`.
