---
name: Protect Public Repo
description: Use when editing, staging, or documenting this public repository so secrets and local-only data stay out of git.
---

# Protect Public Repo

This repo is public. Review changes with that assumption.

## Watch For

- API keys, tokens, passwords, private URLs
- exported local state that was not meant for sharing
- user-specific filesystem paths
- shell commands or docs that accidentally expose private workspace details

Use `.gitignore` for local files and prefer portable examples in documentation.
