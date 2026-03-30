# Mac Control Center Behaviors

This file is the fast-reference behavior log for the app. Update it whenever user-visible behavior or interaction rules change.

## View Modes

### Expanded

- Default working mode for the full action list.
- Shows toolbar controls, inline settings, add-action flow, edit mode, and the quick-launch dock.
- Uses a standard titled macOS window with transparent title bar styling.

### Mini

- Condensed control mode for quick access to actions.
- Shows the view mode picker, always-on-top toggle, compact action list, and quick-launch dock.
- Uses a drag handler so blank areas can still move the window naturally.

### Dot

- Minimal floating mode for reduced visual footprint.
- Switches the window to borderless, transparent, shadowless presentation.
- Forces the window to a small square hit area and returns to Mini mode on click.

## Window Behavior

- The app stays visible in the Dock and also exposes a menu bar status item.
- Window opacity can be adjusted from 20% to 100%.
- Always-on-top toggles the window level between `.normal` and `.floating`.
- Show-on-all-desktops toggles `.canJoinAllSpaces` on the main window.
- Window resizing tries to pin the bottom-right edge so mode switches feel anchored.
- A screen-bounds safety pass keeps the window visible after major size changes.

## Actions

- Actions are loaded from `~/Library/Application Support/MacControlCenter/config.json`.
- Adding, editing, deleting, or reordering actions saves immediately and rebuilds the menu bar menu.
- Action shortcuts run with `Cmd + [Key]` when the user is not editing a text field.
- `app` actions launch application bundles through `NSWorkspace`.
- `shell` actions run via `/bin/sh -c`.
- Empty or invalid actions fall back to a notification instead of crashing.

## Shortcuts

- `Ctrl + Cmd + L`: Expanded mode
- `Ctrl + Cmd + M`: Mini mode
- `Ctrl + Cmd + S`: Dot mode
- `Ctrl + Cmd + T`: Toggle Always on Top
- `Ctrl + Cmd + D`: Toggle Show on All Desktops
- `Cmd + ,`: Toggle inline settings

## Quick Launch Dock

- The dock currently attempts to resolve Google Chrome, ChatGPT, and Telegram.
- Only apps that can be found on the machine are shown.
- Dividers render only between visible dock items.
