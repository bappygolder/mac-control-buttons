---
name: macOS Native UI Design Guidelines
description: Use when designing or revising Mac Control Center UI so it stays native, compact, and aligned with macOS utility patterns.
---

# macOS Native UI Design Guidelines

Mac Control Center should feel like a real macOS utility, not a generic cross-platform panel.

## Principles

- Prefer native controls, semantic colors, and macOS spacing.
- Keep density appropriate to the mode: Expanded for management, Mini for quick execution, Dot for low footprint.
- Preserve immediate response for launch/run actions.
- Add tooltips for icon-only controls.
- Avoid hardcoded personal workflows in UI defaults.

## Interaction Rules

- Mode switches should feel anchored and predictable.
- Keyboard shortcuts should stay discoverable and stable.
- Inline settings and edit flows should not create avoidable modal churn.
- User-facing errors should tell the user what failed and what to try next.

## Documentation Pairing

Update `BEHAVIORS.md` and `docs/UI_AND_UX_GUIDELINES.md` when major interaction patterns change.
