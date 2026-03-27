---
name: macOS Native UI Design Guidelines
description: Comprehensive instructions and best practices for creating a native macOS UI that mimics Apple's System Settings application using SwiftUI.
---

# macOS Native UI Design Guidelines

This skill provides comprehensive instructions on how to design and implement user interfaces in SwiftUI that look and feel exactly like native macOS applications, specifically mirroring the macOS "System Settings" (introduced in macOS Ventura).

## 1. application Architecture & Navigation
To mimic the System Settings app, use a two-pager or sidebar layout:
- **NavigationSplitView**: The root of the settings window should be a `NavigationSplitView`.
- **Sidebar**: The left pane should contain a `List` with the `.listStyle(.sidebar)` modifier.
- **Detail View**: The right pane should display the settings for the selected sidebar item.

```swift
NavigationSplitView {
    List(selection: $selectedItem) {
        // Sidebar items
    }
    .listStyle(.sidebar)
} detail: {
    // Detail view based on selection
}
```

## 2. Forms and Grouped Content
The core of the System Settings look is the grouped form style.
- ALWAYS use `Form` for the detail view.
- Apply the `.formStyle(.grouped)` modifier to the `Form`.
- Use `Section` to visually group related toggles and controls.
- Provide contextual text using Section headers and footers.

```swift
Form {
    Section {
        Toggle("Enable Feature", isOn: $isOn)
        Picker("Options", selection: $selectedOption) {
            Text("Option 1").tag(1)
            Text("Option 2").tag(2)
        }
    } header: {
        Text("General Settings")
    } footer: {
        Text("This feature allows you to customize the general behavior.")
    }
}
.formStyle(.grouped)
```

## 3. Sidebar Icons
System Settings sidebar icons have a distinctive look: a colored rounded rectangle containing a white SF Symbol.
Create a reusable modifier or view for this:

```swift
Image(systemName: "gearshape.fill")
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 14, height: 14)
    .foregroundColor(.white)
    .padding(4)
    .background(Color.gray)
    .cornerRadius(5)
```

## 4. Standard Controls
Always use native SwiftUI controls without trying to reinvent them:
- **Toggles**: Use native `Toggle`. They will automatically style as macOS switches.
- **Pickers**: Use standard `Picker`. For short lists, use `.pickerStyle(.radioGroup)` or `.pickerStyle(.segmented)`. For longer lists, default pop-up behavior is best.
- **Sliders**: Include minimum and maximum value labels using `Image(systemName:)`.
- **Buttons**: Use native `Button`. For primary actions, use `.buttonStyle(.borderedProminent)`.

## 5. Typography and Colors
- **Typography**: Rely on standard Font text styles (`.headline`, `.subheadline`, `.body`, `.caption`). Do not hardcode font sizes unless absolutely necessary.
- **Colors**: Use semantic system colors (`Color.secondary`, `Color.accentColor`) instead of hardcoded hex values to assure perfect support for both Light and Dark modes.

## 6. Window Configuration
Ensure the window behaves like a utility or settings window:
- Restrict resizing to sensible minimums and maximums using `.frame(minWidth: minHeight:)`.
- Use `.windowResizability(.contentSize)` if the window should wrap the content exactly.
- Omit unnecessary title bars if building a pure menu bar app popover, or use a standard title bar for floating windows.

## Rule of Thumb
If you ever need to add a new UI component to the Mac Control Center, consult this skill first. If it does not look like it belongs in Apple's System Settings, it needs to be rewritten using the constructs above.
