# Mac Control Center Behaviors Documentation

This document explicitly outlines the interactions, functional behaviors, and UI/UX state management of the Mac Control Center application.

**Whenever a new functionality, interaction, or view state behavior is created or modified, this document MUST be updated.**

## 1. Application View Modes

The application supports three dynamically swappable View Modes:

### 1.1 Expanded View
- **Description:** The full, default mode. Displays the primary UI with an actions list, inline settings view, and full toolbars.
- **Window:** Standard rounded MacOS rectangular window.
- **Interactions:** User can drag the window via the title bar region. Supports reordering of tasks from the main list.

### 1.2 Mini View
- **Description:** A tightly condensed list form.
- **Window:** Resized significantly smaller.
- **Interactions:** The background of the Mini view features a global `WindowDragHandler` that intercepts clicks, allowing the user to click anywhere blank on the UI to drag the window natively.

### 1.3 Dot View
- **Description:** A highly condensed, floating dot interface intended for minimum destructibility.
- **Window:** Completely borderless, transparent, with zero shadow.
- **Interactions:** 
  - The window is forcibly squashed down to an 80x80 exact size to avoid visual artifacts.
  - Features an invisible, large hitobox layered over a smaller visible blue dot, allowing the user an easy target to interact with.
  - Clicking the dot transitions the app straight into Mini View.

## 2. Window Level State & Management

- **Window Traffic Lights:** Utilizes native macOS AppKit `.fullSizeContentView` and `.titlebarAppearsTransparent = true`. The standard Red/Yellow/Green window controls remain continually visible but smoothly integrate into the UI. Unfocused windows dim them to gray natively.
- **Always on Top:** Users can toggle this setting, raising the window's `.level` to `.floating`.
- **Show on All Desktops:** Allows the application to join all macOS spaces natively using `window.collectionBehavior.insert(.canJoinAllSpaces)`.
- **Opacity Settings:** Users can adjust window opacity from 20% to 100%.
- **Dock Presence:** The app runs as a regular macOS application and remains visible in the Dock while also exposing a persistent menu bar status item.

## 3. Inline Task & Action Management
- **Add / Edit Actions:** Rather than using floating modal sheets, actions are created and edited via an inline scrolling form layout to remain cleanly contained within the parent window's bounds.
- **Persistence:** App Actions and their configuration are stored reliably in `config.json` via a `ConfigManager`.
- **Live Menu Sync:** When actions are added, edited, deleted, or reordered, the menu bar menu is rebuilt so the status item stays in sync with the saved configuration.

## 4. Automatic Window Resizing
- **Dynamic Content Sizing:** The application dynamically calculates the target height of its window based on the active `ViewMode` and the underlying list. This prevents 'empty negative spacing' at the bottom of the list when only a few items are configured.
- **Focus Rings Disabled:** Custom `DragView` intercepts first responder status but purposefully overrides `focusRingType` to `.none` to prevent MacOS drawing an arbitrary blue Focus Ring outline in the center of the drag elements.
- **Shortcut Coverage:** `Ctrl + Cmd + L`, `M`, and `S` switch view modes, `Ctrl + Cmd + T` toggles Always on Top, `Ctrl + Cmd + D` toggles All Desktops, `Cmd + ,` toggles inline settings, and `Cmd + [Key]` runs a configured action while the app window is focused.

## 5. Quick Launch Dock
- **Integrated Dock Structure:** The bottom icon dock forces components together inside a slightly transparent pill container, utilizing 16px vertical semantic `Divider()` lines to visibly group the actions without padding separating the clickable icons.
- **Available Apps Only:** Quick Launch icons appear only for applications that can actually be resolved on the machine, and separators render only between the visible icons.

---
*Created as part of Stage 1 Implementation Plan.*
