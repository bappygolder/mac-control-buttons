# Security Policy

## Reporting a Vulnerability

Please report any security issues or vulnerabilities privately. Do not open a public issue.

## Preventing Secrets Leakage

This repository is **public**. It is strictly prohibited to commit private data, API keys, passwords, or personal credentials. 

### Guidelines for Development
1. **Never commit hardcoded secrets**: Store them utilizing `.env` files or secure keystores.
2. **Review `.gitignore`**: Ensure files containing local configuration or secrets are added to `.gitignore`.
3. **Be careful with user-specific paths**: Avoid committing files that accidentally reveal private or sensitive paths unless absolutely necessary for the application.

If an AI assistant or contributor attempts to push private data, please verify your changes before executing `git commit` or `git push`.
