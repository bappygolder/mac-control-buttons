# Action System

## Data Model

Each action is represented by `ActionButton`:

- `id`: UUID generated locally
- `name`: visible label
- `key`: single-character shortcut
- `actionType`: `app`, `shell`, or empty
- `actionTarget`: application path or shell command

The config file format currently wraps the action list in:

```json
{
  "buttons": []
}
```

## Storage Location

Actions are persisted to:

`~/Library/Application Support/MacControlCenter/config.json`

## Execution Rules

- `app`: expects a valid `.app` path and launches with `NSWorkspace`
- `shell`: runs through `/bin/sh -c`
- empty or invalid action definitions trigger a user notification instead of a hard failure

## Current Risks

- Duplicate shortcuts are not prevented
- There is no import/export UI for action backup
- Shell commands can be powerful and should be treated as trusted local workflows
- There is no richer execution log beyond notifications

## Recommended Follow-Up

1. Add validation for duplicate shortcuts and blank names.
2. Add import/export/reset controls for the action config.
3. Add richer success/failure feedback in the UI.
4. Document trusted-command patterns for shell actions.
