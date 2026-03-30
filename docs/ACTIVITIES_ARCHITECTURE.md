# Activities Architecture

The Mac Control Centre application was intentionally designed to compartmentalize the "activities" from the core UI execution code.

## Decoupling the App from the Actions
The actual application merely acts as a dashboard or a host for buttons. No specific action logic (such as launching "Start My Day" or opening "Chrome") should be hardcoded within the user interface views or configuration loader.

### Configuration Model
Activities are defined in user configuration (`config.json`, located in `~/Library/Application Support/MacControlCenter/`) using the `ActionButton` structure:
- **`name`**: The display name of the button.
- **`key`**: The keyboard shortcut.
- **`actionType`**: Defines the type of executor required (e.g., `app` or `shell`).
- **`actionTarget`**: Defines the specific target value (e.g., full absolute path to an `.app` like `/Applications/Safari.app`, or a literal shell script line).

### Activity Execution (`ActivityHandler.swift`)
All actions are routed through `ActivityHandler.shared.execute(button:)`. This prevents the UI threads or `ConfigManager` from getting bloated with system launch logic, and it keeps action execution dependent on saved config instead of hardcoded personal paths.
- `app` targets are launched through `NSWorkspace.OpenConfiguration`, preserving native app activation and new-instance launching.
- `shell` targets are triggered directly via `/bin/sh -c ...`.

## Future Scope
In subsequent iterations, opening and closing apps across macOS is intended to be a ubiquitous, reusable small feature. Users should be able to:
- Easily assign applications to buttons globally via the UI without diving into the codebase.
- Manage custom scripts securely within a dedicated `Activities/` folder so that user-defined workflows stay separate from the primary Swift app bundle.
- Protect user data: User tasks, layouts, and mappings are compartmentalized within the `config.json`, keeping their private workspace entirely separate from the application infrastructure.
