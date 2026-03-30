# UI and UX Guidelines

## Product Direction

Mac Control Center should feel like a polished macOS utility, not a web app transplanted into SwiftUI.

## Design Principles

### Native First

- Prefer native controls and semantic macOS colors
- Keep interactions lightweight and immediate
- Let macOS window chrome do as much work as possible

### Compact But Legible

- Expanded view is for management
- Mini view is for quick utility access
- Dot view is for minimum screen footprint
- Each mode should have a clear job and distinct density

### Low Friction

- User actions should be available in one or two clicks
- Window transitions should preserve position and feel anchored
- Keyboard shortcuts should remain memorable and consistent

### Safety

- Destructive actions should require confidence or confirmation
- Shell-command workflows should communicate risk clearly
- Errors should explain what failed and what the user can do next

## Current UI Debt

- Quick-launch dock is hardcoded rather than user-managed
- Action feedback is heavier on notifications than inline clarity
- There is no validation UI for conflicting shortcuts

## Update Rule

If a change affects layout, interaction model, density, shortcut behavior, or system feel, update this file and `BEHAVIORS.md` together.
