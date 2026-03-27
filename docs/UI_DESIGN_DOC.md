# Mac Control Center UI Design Guidelines

## Overview
This document outlines the core UI/UX design decisions for the native Mac Control Center app. The app follows Apple's Human Interface Guidelines (HIG) to ensure it feels lightweight, native, and premium.

## Typography
- **Font Family**: system defaults (`SF Pro`).
- **Weight Consistency**: Avoid `.bold` or `.heavy` unless strictly necessary for top-level headers. Interactive elements (like Action Buttons) should use `.medium` or `.regular` weights.
- **Visual Hierarchy**: Rely on font size and color (primary vs secondary text colors) rather than heavy font weights.

## Iconography
- **SF Symbols Limitation**: Note that the local toolchain (Swift 5.2) does not support `Image(systemName:)` for macOS. Thus, we must rely on carefully styled text characters (`+`, `i`, `⚙`, `一`, `≡`) or provide our own custom assets if we need rich icons. 
- Ensure any text used as icons is explicitly sized and formatted to match expected system proportions.

## Layout & Materials
- **Paddings**: Use 16pt margins for main view boundaries and 8-12pt spacing between internal elements.
- **Forms**: Data entry views (like "Add Action") should utilize native `Form` containers wrapped in neat `VStack`s for standard alignment.
- **Backgrounds**: Use standard macOS window backgrounds and subtle vibrant grays (`Color.gray.opacity(0.15)`) for unhighlighted buttons. Primary actions should use `NSColor.systemBlue`.

Adhering to these guidelines prevents UI regression and ensures a professionally polished application.
