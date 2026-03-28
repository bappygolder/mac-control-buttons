import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var configManager = ConfigManager.shared
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "⚡"
        }
        
        constructMenu()
        openSettings(nil)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openSettings(nil)
        }
        return true
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        let startItem = NSMenuItem(title: "🚀 Start Application", action: #selector(startApplication(_:)), keyEquivalent: "s")
        startItem.target = self
        menu.addItem(startItem)
        
        let resetItem = NSMenuItem(title: "Reset Size (Debug)", action: #selector(resetSize(_:)), keyEquivalent: "r")
        resetItem.target = self
        menu.addItem(resetItem)
        
        menu.addItem(NSMenuItem.separator())
        
        for button in configManager.buttons {
            let item = NSMenuItem(title: button.name, action: #selector(runAction(_:)), keyEquivalent: button.key.lowercased())
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
            let contentView = SettingsHostingView().environmentObject(configManager)
            let window = BottomRightAnchoredWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 450),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.center()
            window.title = "Mac Control Center"
            window.contentView = NSHostingView(rootView: contentView.environmentObject(configManager))
            window.setFrameAutosaveName("MacControlCenterMainWindow")
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        AppSettings.shared.applyWindowSettings()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func reloadMenu() {
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
