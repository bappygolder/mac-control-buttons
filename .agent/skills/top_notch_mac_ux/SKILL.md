---
name: Top-Notch Mac Utility UX Guidelines
description: The ultimate User Experience (UX) principles for building a world-class, premium macOS modular utility app.
---

# Top-Notch Mac Utility UX Guidelines

Creating a "good" app is about features; creating a "top-notch" premium macOS application is all about **User Experience (UX)**. 
For a menu bar or system control utility like Mac Control Center, user expectations for polish, speed, and unobtrusiveness are remarkably high. 

Follow these absolute UX rules when designing, modifying, or planning any feature:

## 1. Zero-Friction & Instantaneous Response
Menu bar apps must feel like extensions of the operating system.
*   **Instant Load**: Actions triggered from the menu bar must appear instantly. Use background caching or lightweight initial views if heavy data loading is required.
*   **Optimistic UI**: If a user toggles a setting or clicks an action (e.g., "Start My Day"), update the UI state immediately before the backend process finishes.
*   **No Spinners for Micro-actions**: Avoid blocking the user's flow. Use subtle inline progress indicators instead of full-screen loading overlays.

## 2. Unobtrusive Yet Discoverable
The app should be invisible when not needed, but highly powerful when invoked.
*   **Quiet Background Operation**: Never steal window focus unexpectedly. If an automation finishes, use a standard macOS Notification or a subtle change to the menu bar icon (e.g., changing color or adding a dot).
*   **Tooltips Everywhere**: Every icon-only button must have a concise, descriptive tooltip. 
*   **Keyboard First**: Provide global shortcut support (Hotkeys) for primary actions. Users should be able to trigger core workflows without touching the mouse.

## 3. Micro-Interactions & Premium Feel
Native macOS apps are defined by their subtle animations and feedback forms.
*   **Hover States**: Buttons and interactive lists should have subtle hover backgrounds (usually `Color.secondary.opacity(0.1)`).
*   **Haptic Feedback**: Use `NSHapticFeedbackManager` for significant state changes (e.g., when a running task completes or an error occurs).
*   **Spring Animations**: When expanding a view (like transitioning from Mini View to Expanded View), use `.spring()` or `.bouncy` animations rather than linear ones. This makes the UI feel alive.

## 4. State Preservation (Contextual Memory)
A premium app never makes the user repeat themselves.
*   **Remember Everything**: The app must remember its last physical screen position, its expanded/mini state, and the last selected tab in the sidebar.
*   **Persistent Inputs**: If a user partially fills out a form and closes the popover, those inputs should remain when they reopen it.

## 5. Forgiving & Empowering Error Recovery
Errors will happen (e.g., a script fails, a file is missing), but the UX must handle them gracefully.
*   **Never Just Say "Error"**: Always provide an actionable recovery step. (e.g., "Failed to launch Chrome. [Retry] [Check Path]")
*   **Destructive Actions**: Any action that deletes data or quits multiple apps without saving must require a confirmation dialog. 

## 6. Accessibility (a11y) is Mandatory
A top-notch app works for everyone.
*   **VoiceOver**: Ensure all custom controls have an `.accessibilityLabel()` and appropriate `.accessibilityTraits()`.
*   **Contrast & Scaling**: Rely on native text styles (`.headline`, `.body`) so they scale with system UI preferences. Ensure text has sufficient contrast in both Light and Dark modes.

## Application of this Skill
Before committing ANY new UI component or workflow, ask:
1. *Is it instant?*
2. *Does it look like an Apple engineer designed it?*
3. *Is the user confused about what will happen if they click this?*

If it fails any of these, rethink the design.
