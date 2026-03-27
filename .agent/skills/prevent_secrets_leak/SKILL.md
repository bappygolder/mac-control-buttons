---
name: Prevent Secrets Leak
description: Guidelines to prevent committing sensitive or private data to the public repository.
---

# Prevent Secrets Leak

This repository is **PUBLIC**. As an AI assistant, you must be extremely vigilant about preventing the exposure of the user's private data.

## Rules
1. **Never commit secrets**: Do not stage or commit any files containing API keys, passwords, personal tokens, or private URLs.
2. **Warn the user**: If the user asks you to add or commit a file that contains sensitive information, you MUST give them a heads-up and refuse to commit the file directly. Explain that it is a public repository and doing so breaches security. 
3. **Use `.env` files**: For configuration that requires secrets, instruct the user to use a `.env` file and ensure it is listed in `.gitignore`.
4. **Identify personal paths**: Be cautious of committing files that contain hardcoded absolute paths to the user's local machine (e.g., `/Users/bappygolder/...`) unless it is required and safe for public view.

**When in doubt, stop and ask the user for confirmation before proceeding with any `git add` or `git commit` commands.**
