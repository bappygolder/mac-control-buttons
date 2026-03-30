# Security Policy

## Reporting

Please report vulnerabilities privately. Do not open a public issue for a live security problem.

## Public Repo Rules

This repository is public. Do not commit secrets, private tokens, local credentials, personal URLs, or machine-specific data.

## Development Guardrails

1. Use `.env` files or OS-level secure storage for secrets.
2. Keep local-only files out of git with `.gitignore`.
3. Avoid hardcoded personal filesystem paths in docs, scripts, or UI defaults when a portable path will work.
4. Treat exported task-tracker snapshots as reviewable content before sharing them online.
5. Review shell-command examples carefully because the app can run user-defined shell actions.

## Project-Specific Notes

- App action definitions live in a user-owned config file under `~/Library/Application Support/MacControlCenter/`.
- Browser edits inside `TaskTracker/` are local unless explicitly exported or committed.
- AI assistants should stop before staging anything that looks like private workspace state.
