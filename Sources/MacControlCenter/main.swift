import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var configManager = ConfigManager.shared
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.regular)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.toolTip = "Mac Control Center"
            button.title = "⚡"
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleConfigDidChange(_:)),
            name: ConfigManager.configDidChangeNotification,
            object: configManager
        )

        constructMenu()
        openSettings(nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openSettings(nil)
        }
        return true
    }
    
    func constructMenu() {
        let menu = NSMenu()

        let startItem = NSMenuItem(title: "Open Control Center", action: #selector(startApplication(_:)), keyEquivalent: "")
        startItem.target = self
        menu.addItem(startItem)

        let resetItem = NSMenuItem(title: "Reset Window Size", action: #selector(resetSize(_:)), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)

        menu.addItem(NSMenuItem.separator())

        if configManager.buttons.isEmpty {
            let emptyItem = NSMenuItem(title: "No actions configured yet", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        }

        for button in configManager.buttons {
            let keyEquivalent = button.key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let item = NSMenuItem(title: button.name, action: #selector(runAction(_:)), keyEquivalent: keyEquivalent)
            item.target = self
            item.representedObject = button
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
    
    @objc func startApplication(_ sender: Any?) {
        openSettings(sender) // Starts the app view explicitly
    }
    
    @objc func runAction(_ sender: NSMenuItem) {
        guard let button = sender.representedObject as? ActionButton else { return }
        
        configManager.performAction(for: button)
    }
    
    @objc func resetSize(_ sender: Any?) {
        AppSettings.shared.viewMode = .expanded
        if let window = settingsWindow {
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.isOpaque = true
            window.hasShadow = true
            if window.frame.width < 150 {
                let newFrame = NSRect(x: window.frame.maxX - 350, y: window.frame.minY, width: 350, height: 450)
                window.setFrame(newFrame, display: true, animate: true)
            }
        }
        openSettings(nil)
    }
    
    @objc func openSettings(_ sender: Any?) {
        if settingsWindow == nil {
            let window = BottomRightAnchoredWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 450),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.center()
            window.title = "Mac Control Center"
            window.contentView = NSHostingView(rootView: SettingsHostingView().environmentObject(configManager))
            window.setFrameAutosaveName("MacControlCenterMainWindow")
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        AppSettings.shared.applyWindowSettings()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func handleConfigDidChange(_ notification: Notification) {
        reloadMenu()
    }

    private func reloadMenu() {
        constructMenu()
    }
}

class BottomRightAnchoredWindow: NSWindow {
    var isPinningToBottomRight = false
    var targetMaxX: CGFloat = 0
    var targetMinY: CGFloat = 0
    
    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
        var newRect = frameRect
        if isPinningToBottomRight {
            newRect.origin.x = targetMaxX - newRect.width
            newRect.origin.y = targetMinY
        }
        super.setFrame(newRect, display: flag)
    }
    
    override func setFrame(_ frameRect: NSRect, display displayFlag: Bool, animate animateFlag: Bool) {
        var newRect = frameRect
        if isPinningToBottomRight {
            newRect.origin.x = targetMaxX - newRect.width
            newRect.origin.y = targetMinY
        }
        super.setFrame(newRect, display: displayFlag, animate: animateFlag)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
