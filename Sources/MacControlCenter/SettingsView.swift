import SwiftUI
import Cocoa

// ... (AppSettings remains unchanged, inserting later)
enum ViewMode: String {
    case expanded, mini, dot
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var alwaysOnTop: Bool {
        didSet {
            UserDefaults.standard.set(alwaysOnTop, forKey: "alwaysOnTop")
            applyWindowSettings()
        }
    }
    @Published var showOnAllDesktops: Bool {
        didSet {
            UserDefaults.standard.set(showOnAllDesktops, forKey: "showOnAllDesktops")
            applyWindowSettings()
        }
    }
    @Published var opacity: Double {
        didSet {
            UserDefaults.standard.set(opacity, forKey: "opacity")
            applyWindowSettings()
        }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            toggleLaunchAtLogin(launchAtLogin)
        }
    }
    @Published var viewMode: ViewMode {
        didSet {
            UserDefaults.standard.set(viewMode.rawValue, forKey: "viewModeApp")
        }
    }
    
    init() {
        self.alwaysOnTop = UserDefaults.standard.bool(forKey: "alwaysOnTop")
        self.showOnAllDesktops = UserDefaults.standard.bool(forKey: "showOnAllDesktops")
        self.opacity = UserDefaults.standard.object(forKey: "opacity") as? Double ?? 1.0
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        
        if let modeStr = UserDefaults.standard.string(forKey: "viewModeApp"), let mode = ViewMode(rawValue: modeStr) {
            self.viewMode = mode
        } else {
            let oldIsMini = UserDefaults.standard.bool(forKey: "isMiniView")
            self.viewMode = oldIsMini ? .mini : .expanded
        }
    }
    
    func applyWindowSettings() {
        DispatchQueue.main.async {
            guard let window = NSApp.windows.first(where: { $0.title == "Mac Control Center" }) else { return }
            
            window.level = self.alwaysOnTop ? .floating : .normal
            window.alphaValue = CGFloat(self.opacity)
            
            if self.showOnAllDesktops {
                window.collectionBehavior.insert(.canJoinAllSpaces)
            } else {
                window.collectionBehavior.remove(.canJoinAllSpaces)
            }
        }
    }
    
    private func toggleLaunchAtLogin(_ enable: Bool) {
        let appPath = Bundle.main.bundlePath
        let script: String
        if enable {
            script = "tell application \"System Events\" to make login item at end with properties {path:\"\(appPath)\", hidden:false}"
        } else {
            script = "tell application \"System Events\" to delete login item \"Mac Control Center\""
        }
        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", script]
        process.launch()
    }
}

// Global Drag handler overlay for Mini View
struct WindowDragHandler: NSViewRepresentable {
    var onClick: (() -> Void)? = nil
    var interceptsHits: Bool = false
    
    func makeNSView(context: Context) -> NSView {
        let view = DragView()
        view.onClick = onClick
        view.interceptsHits = interceptsHits
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let dragView = nsView as? DragView {
            dragView.onClick = onClick
            dragView.interceptsHits = interceptsHits
        }
    }
}

class DragView: NSView {
    var onClick: (() -> Void)?
    var dragStarted = false
    var interceptsHits = false
    var mouseDownPoint: NSPoint = .zero
    override var acceptsFirstResponder: Bool { true }
    override var focusRingType: NSFocusRingType {
        get { .none }
        set {}
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        if interceptsHits {
            return self
        }
        return super.hitTest(point)
    }
    
    override func mouseDown(with event: NSEvent) {
        dragStarted = false
        mouseDownPoint = event.locationInWindow
    }
    override func mouseDragged(with event: NSEvent) {
        if !dragStarted {
            let dx = event.locationInWindow.x - mouseDownPoint.x
            let dy = event.locationInWindow.y - mouseDownPoint.y
            if dx*dx + dy*dy > 9 { // 3 pixels squared
                dragStarted = true
            }
        }
        if dragStarted {
            window?.performDrag(with: event)
        }
    }
    override func mouseUp(with event: NSEvent) {
        if !dragStarted {
            DispatchQueue.main.async {
                self.onClick?()
            }
        }
    }
}

struct ViewModePicker: View {
    @ObservedObject var settings = AppSettings.shared
    var action: (ViewMode) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Button(action: { self.action(.expanded) }) {
                Text("□")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(settings.viewMode == .expanded ? .white : .secondary)
                    .frame(width: 30, height: 26)
                    .background(settings.viewMode == .expanded ? Color.gray.opacity(0.4) : Color.clear)
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            .background(TooltipView(text: "Expanded View"))
            
            Button(action: { self.action(.mini) }) {
                Text("⧉")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(settings.viewMode == .mini ? .white : .secondary)
                    .frame(width: 30, height: 26)
                    .background(settings.viewMode == .mini ? Color.gray.opacity(0.4) : Color.clear)
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            .background(TooltipView(text: "Mini View"))
            
            Button(action: { self.action(.dot) }) {
                Text("●")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(settings.viewMode == .dot ? .white : .secondary)
                    .frame(width: 30, height: 26)
                    .background(settings.viewMode == .dot ? Color.gray.opacity(0.4) : Color.clear)
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            .background(TooltipView(text: "Dot View"))
        }
        .padding(4)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
    }
}

struct SettingsHostingView: View {
    @EnvironmentObject var configManager: ConfigManager
    @ObservedObject var settings = AppSettings.shared
    
    @State private var isEditing = false
    @State private var activeSheet: ActiveSheet?
    @State private var showingInlineSettings = false
    @State private var isAddingAction = false
    @State private var isHoveringDot = false
    @State private var ignoreHoverUntilExit = false
    
    @State private var localKeyMonitor: Any?
    
    var effectiveViewMode: ViewMode {
        return settings.viewMode
    }
    
    private func applyWindowDecorations() {
        guard let window = NSApp.windows.first(where: { $0.title == "Mac Control Center" }) else { return }
        let shouldBeBorderless = (effectiveViewMode == .dot)
        
        if shouldBeBorderless {
            window.styleMask = .borderless
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            
            // Crush window frame mechanically down to the exact dot boundaries!
            let targetSize = CGSize(width: 80, height: 80)
            if window.frame.width > 100 {
                let newFrame = NSRect(x: window.frame.maxX - targetSize.width, 
                                      y: window.frame.minY, 
                                      width: targetSize.width, 
                                      height: targetSize.height)
                window.setFrame(newFrame, display: true, animate: false)
            }
            
        } else {
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isOpaque = true
            window.backgroundColor = NSColor.windowBackgroundColor
            window.hasShadow = true
            
            // Restore window bounds explicitly for Expanded/Mini
            var targetHeight: CGFloat = 450
            let buttonCount = configManager.buttons.count
            
            if effectiveViewMode == .mini {
                let listH = CGFloat(buttonCount * 40)
                targetHeight = showingInlineSettings ? 330 : max(150, min(75 + listH + 50, 280))
            } else {
                let listH = CGFloat(buttonCount * 40)
                targetHeight = (showingInlineSettings || isAddingAction || isEditing) ? 450 : max(200, min(75 + listH + 60, 600))
            }
            
            let targetWidth: CGFloat = (effectiveViewMode == .mini) ? 180 : 350
            
            // Adjust frame using custom pinning if possible to prevent jumping
            if let anchoredWin = window as? BottomRightAnchoredWindow {
                anchoredWin.targetMaxX = window.frame.maxX
                anchoredWin.targetMinY = window.frame.minY
                anchoredWin.isPinningToBottomRight = true
            }

            let newFrame = NSRect(x: window.frame.maxX - targetWidth, 
                                  y: window.frame.maxY - targetHeight, // Origin Y recalculation to pin to top left or bottom? Actually bottom right is pinned. So maxY should change? Wait, BottomRightAnchoredWindow pins based on setFrame logic.
                                  width: targetWidth, 
                                  height: targetHeight)
            window.setFrame(newFrame, display: true, animate: true)
            
            if let anchoredWin = window as? BottomRightAnchoredWindow {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    anchoredWin.isPinningToBottomRight = false
                    self.keepWindowOnScreen()
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            if effectiveViewMode == .dot {
                // DOT VIEW
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.001)) // Invisible hit box that routes correctly
                        .frame(width: 80, height: 80)     // Large tap target around dot
                        
                    Circle()
                        .fill(Color(NSColor.systemBlue).opacity(0.9))
                        .frame(width: 16, height: 16)
                }
                .background(WindowDragHandler(onClick: {
                    self.toggleViewMode(to: .mini)
                }, interceptsHits: true))
                .onTapGesture {
                    self.toggleViewMode(to: .mini)
                }
                
            } else if effectiveViewMode == .mini {
                // TRUE MINI VIEW
                VStack(spacing: 0) {
                    // Header with Menu and Expand
                    HStack(alignment: .center, spacing: 6) {
                        // Left side Top button group
                        HStack(spacing: 4) {
                            Button(action: { self.settings.alwaysOnTop.toggle() }) {
                                Text("Top")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(settings.alwaysOnTop ? .white : .primary)
                                    .frame(width: 36, height: 26)
                                    .background(settings.alwaysOnTop ? Color.gray.opacity(0.5) : Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(TooltipView(text: "Always on Top"))
                        }
                        .padding(4)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        // Right-side View Mode Picker
                        ViewModePicker { mode in
                            self.toggleViewMode(to: mode)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(WindowDragHandler())
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    Divider()
                    
                    VStack(spacing: 8) {
                        if showingInlineSettings {
                            InlineSettingsView(isMiniView: true)
                                .frame(maxHeight: 250)
                        } else {
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(configManager.buttons.indices, id: \.self) { index in
                                        HStack(alignment: .center, spacing: 8) {
                                            Text(self.configManager.buttons[index].name)
                                                .font(.system(size: 11, weight: .regular))
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .background(TooltipView(text: self.configManager.buttons[index].name))
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                self.configManager.performAction(for: self.configManager.buttons[index])
                                            }) {
                                                Text("Run")
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .frame(width: 44, height: 20)
                                                    .background(Color.gray.opacity(0.4))
                                                    .cornerRadius(10)
                                            }.buttonStyle(PlainButtonStyle())
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
                                        .padding(.horizontal, 12)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } // closes the VStack
                    .padding(.vertical, 8)
                    .background(Color(NSColor.underPageBackgroundColor))
                    
                    if !showingInlineSettings {
                        QuickLaunchDockView()
                    }
                    
                    Spacer().frame(height: 4) // Bottom padding
                }
                .frame(width: 180)
                .background(Color(NSColor.windowBackgroundColor))
                .onHover { hovering in
                    if self.settings.viewMode == .dot {
                        self.setHoveringDot(hovering)
                    }
                }
                
            } else {
                // NORMAL NATIVE VIEW (Phase 2 style)
                VStack(spacing: 0) {
                    // Toolbar
                    HStack(spacing: 6) {
                        // Left-side Settings Buttons
                        // If we are in editing/settings, only show Done to save space
                        if showingInlineSettings {
                            Button(action: { withAnimation { self.showingInlineSettings.toggle(); self.applyWindowDecorations() } }) {
                                Text("Done")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 50, height: 26)
                                    .background(Color.gray.opacity(0.4))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else if isAddingAction {
                            Button(action: { withAnimation { self.isAddingAction.toggle(); self.applyWindowDecorations() } }) {
                                Text("Done")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 50, height: 26)
                                    .background(Color.gray.opacity(0.4))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else if isEditing {
                            Spacer() // Empty space on the left when editing
                        } else {
                            HStack(spacing: 4) {
                                Button(action: { withAnimation { self.isAddingAction.toggle(); self.applyWindowDecorations() } }) {
                                    Text("+")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.primary)
                                        .frame(width: 28, height: 26)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(TooltipView(text: "Add Action"))
                                
                                Button(action: { withAnimation { self.showingInlineSettings.toggle(); self.applyWindowDecorations() } }) {
                                    Text("⚙")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.primary)
                                        .frame(width: 28, height: 26)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(TooltipView(text: "Settings"))
                                
                                Button(action: { self.isEditing.toggle(); self.applyWindowDecorations() }) {
                                    Text("Edit")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.primary)
                                        .frame(width: 36, height: 26)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(TooltipView(text: "Edit Actions"))
                                
                                Button(action: { self.settings.alwaysOnTop.toggle() }) {
                                    Text("Top")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(settings.alwaysOnTop ? .white : .primary)
                                        .frame(width: 36, height: 26)
                                        .background(settings.alwaysOnTop ? Color.gray.opacity(0.5) : Color.gray.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(TooltipView(text: "Always on Top"))
                            }
                            .padding(4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                        }
                        
                        // Right side elements
                        if !isEditing { Spacer() }
                        
                        if !showingInlineSettings && !isAddingAction && !isEditing {
                            ViewModePicker { mode in
                                self.toggleViewMode(to: mode)
                            }
                        } else if isEditing {
                            Button(action: { self.isEditing.toggle(); self.applyWindowDecorations() }) {
                                Text("Done")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 50, height: 26)
                                    .background(Color.gray.opacity(0.4))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    Divider()
                    
                    if showingInlineSettings {
                        InlineSettingsView(isMiniView: false)
                            .background(Color(NSColor.underPageBackgroundColor))
                    } else if isAddingAction {
                        InlineAddActionView(isAddingAction: $isAddingAction)
                            .background(Color(NSColor.underPageBackgroundColor))
                    } else {
                        // List
                        List {
                            ForEach(configManager.buttons.indices, id: \.self) { index in
                                HStack(alignment: .center, spacing: 8) {
                                    if self.isEditing {
                                        Text("≡")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                            .frame(width: 22, height: 22, alignment: .center)
                                            
                                        Button(action: {
                                            self.activeSheet = .edit(index)
                                        }) {
                                            Text("✎")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                                .frame(width: 22, height: 22, alignment: .center)
                                        }.buttonStyle(PlainButtonStyle())
                                            
                                        Button(action: {
                                            self.configManager.buttons.remove(at: index)
                                            self.configManager.save()
                                        }) {
                                            Text("✕")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.red)
                                                .frame(width: 22, height: 22, alignment: .center)
                                        }.buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    Text(self.configManager.buttons[index].name)
                                        .font(.system(size: 13, weight: .regular))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .background(TooltipView(text: self.configManager.buttons[index].name))
                                    
                                    Spacer()
                                    
                                    if self.configManager.buttons[index].key != "" {
                                        Text("Cmd + \(self.configManager.buttons[index].key.uppercased())")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if !self.isEditing {
                                        Button(action: {
                                            self.configManager.performAction(for: self.configManager.buttons[index])
                                        }) {
                                            Text("Run")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                                .frame(width: 50, height: 22)
                                                .background(Color.gray.opacity(0.4))
                                                .cornerRadius(11)
                                        }.buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onMove { source, destination in
                                self.configManager.buttons.move(fromOffsets: source, toOffset: destination)
                                self.configManager.save()
                            }
                        }
                        .background(Color(NSColor.underPageBackgroundColor))
                    }
                    
                    if !showingInlineSettings && !isAddingAction {
                        QuickLaunchDockView()
                    }
                }
                .frame(minWidth: 300, idealWidth: 350)
                .onHover { hovering in
                    if self.settings.viewMode == .dot {
                        self.setHoveringDot(hovering)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.applyWindowDecorations()
            }
            
            if self.localKeyMonitor == nil {
                self.localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if event.modifierFlags.contains([.command, .control]) {
                        if event.charactersIgnoringModifiers?.lowercased() == "l" {
                            self.toggleViewMode(to: .expanded)
                            return nil // Handled
                        } else if event.charactersIgnoringModifiers?.lowercased() == "m" {
                            self.toggleViewMode(to: .mini)
                            return nil // Handled
                        } else if event.charactersIgnoringModifiers?.lowercased() == "s" {
                            self.toggleViewMode(to: .dot)
                            return nil
                        }
                    }
                    return event
                }
            }
        }
        .onReceive(configManager.$buttons) { _ in
            DispatchQueue.main.async { self.applyWindowDecorations() }
        }
        .sheet(item: $activeSheet) { item in
            self.sheetView(for: item)
        }
    }
    
    enum ActiveSheet: Identifiable {
        case edit(Int)
        var id: Int {
            switch self {
            case .edit(let idx): return idx
            }
        }
    }
    
    private func sheetView(for item: ActiveSheet) -> AnyView {
        switch item {
        case .edit(let index):
            return AnyView(EditActionSheet(activeSheet: self.$activeSheet, index: index))
        }
    }
    
    private func keepWindowOnScreen() {
        guard let window = NSApp.windows.first(where: { $0.title == "Mac Control Center" }),
              let screen = window.screen else { return }
        
        let visibleFrame = screen.visibleFrame
        var currentFrame = window.frame
        var originChanged = false
        
        if currentFrame.maxX > visibleFrame.maxX {
            currentFrame.origin.x = visibleFrame.maxX - currentFrame.width - 20
            originChanged = true
        }
        if currentFrame.maxY > visibleFrame.maxY {
            currentFrame.origin.y = visibleFrame.maxY - currentFrame.height - 40
            originChanged = true
        }
        if currentFrame.minX < visibleFrame.minX {
            currentFrame.origin.x = visibleFrame.minX + 20
            originChanged = true
        }
        if currentFrame.minY < visibleFrame.minY {
            currentFrame.origin.y = visibleFrame.minY + 40
            originChanged = true
        }
        
        if originChanged {
            window.setFrame(currentFrame, display: true, animate: true)
        }
    }
    
    private func setHoveringDot(_ hovering: Bool) {
        // Redundant with the pulse animation now, but keeping for structural safety
    }
    
    private func toggleViewMode(to mode: ViewMode) {
        if mode == .dot {
            self.ignoreHoverUntilExit = true
            self.isHoveringDot = false
        }
        
        guard let window = NSApp.windows.first(where: { $0.title == "Mac Control Center" }) as? BottomRightAnchoredWindow else {
            withAnimation { self.settings.viewMode = mode }
            return
        }
        
        let oldMaxX = window.frame.maxX
        let oldMinY = window.frame.minY
        
        // Enable pinning the origin to bottom-right during resize
        window.targetMaxX = oldMaxX
        window.targetMinY = oldMinY
        window.isPinningToBottomRight = true
        
        withAnimation(.easeInOut(duration: 0.2)) {
            self.settings.viewMode = mode
            self.applyWindowDecorations()
        }
        
        // Disable pinning after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            window.isPinningToBottomRight = false
            self.keepWindowOnScreen()
        }
    }
}

enum SettingsTab: String, CaseIterable {
    case general = "General"
    case shortcuts = "Shortcuts"
}

struct InlineSettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    var isMiniView: Bool
    @State private var selectedTab: SettingsTab = .general
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 6)
            
            Divider()
            
            ScrollView {
                if selectedTab == .general {
                    VStack(alignment: .leading, spacing: isMiniView ? 14 : 20) {
                        // Preferences section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preferences").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                            
                            Toggle("Always on Top", isOn: $settings.alwaysOnTop)
                            Toggle("Show on All Desktops", isOn: $settings.showOnAllDesktops)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Opacity: \(Int(settings.opacity * 100))%")
                                Slider(value: $settings.opacity, in: 0.2...1.0)
                            }
                            
                            Toggle("Launch on Startup", isOn: $settings.launchAtLogin)
                        }
                        .font(.system(size: 13))
                        
                        Divider()
                        
                        // About section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                            Text("⚡ Mac Control Center").font(.system(size: 14, weight: .bold))
                            Text("Version 2.0 (Native Swift)").font(.system(size: 11)).foregroundColor(.secondary)
                            Text("Built by Bappy Golder").font(.system(size: 11))
                        }
                    }
                    .padding(isMiniView ? 12 : 20)
                } else {
                    // Shortcuts Tab
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Keyboard Navigation").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack { Text("Ctrl + Cmd + L").bold(); Spacer(); Text("Expanded View") }
                            HStack { Text("Ctrl + Cmd + M").bold(); Spacer(); Text("Mini View") }
                            HStack { Text("Ctrl + Cmd + S").bold(); Spacer(); Text("Dot View") }
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("Window Toggles").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack { Text("Ctrl + Cmd + T").bold(); Spacer(); Text("Toggle Always on Top") }
                            HStack { Text("Ctrl + Cmd + D").bold(); Spacer(); Text("Toggle All Desktops") }
                            HStack { Text("Cmd + ,").bold(); Spacer(); Text("Toggle Settings Menu") }
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                    }
                    .padding(isMiniView ? 12 : 20)
                }
            }
        }
    }
}

struct InlineAddActionView: View {
    @EnvironmentObject var configManager: ConfigManager
    @Binding var isAddingAction: Bool
    
    @State private var newName = ""
    @State private var newKey = ""
    @State private var actionType = "app"
    @State private var actionTarget = ""
    
    let types = ["app", "shell", "none"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Create New Action")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Action Name").font(.caption).foregroundColor(.secondary)
                        TextField("e.g. Start My Day", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Shortcut Key").font(.caption).foregroundColor(.secondary)
                            TextField("Key", text: Binding<String>(
                                get: { self.newKey },
                                set: { newValue in
                                    if newValue.count > 1 {
                                        self.newKey = String(newValue.suffix(1)).lowercased()
                                    } else {
                                        self.newKey = newValue.lowercased()
                                    }
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        }
                        
                        Text("Triggers via Cmd + [Key]")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                            
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Action Type").font(.caption).foregroundColor(.secondary)
                        Picker("", selection: $actionType) {
                            Text("App").tag("app")
                            Text("Script").tag("shell")
                            Text("None").tag("none")
                        }
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    if actionType != "none" {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(actionType == "app" ? "App Path" : "Shell Command").font(.caption).foregroundColor(.secondary)
                            
                            HStack {
                                TextField(actionType == "app" ? "/Applications/Google Chrome.app" : "echo 'Hello'", text: $actionTarget)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                if actionType == "app" {
                                    Button("Browse...") {
                                        let panel = NSOpenPanel()
                                        panel.canChooseFiles = true
                                        panel.canChooseDirectories = false
                                        panel.allowsMultipleSelection = false
                                        panel.allowedFileTypes = ["app"]
                                        if panel.runModal() == .OK {
                                            self.actionTarget = panel.url?.path ?? ""
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                HStack {
                    Button("Cancel") { withAnimation { self.isAddingAction = false } }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Button("Save Action") {
                        let typeToSave = self.actionType == "none" ? nil : self.actionType
                        let targetToSave = self.actionType == "none" ? nil : self.actionTarget
                        let btn = ActionButton(name: self.newName, key: self.newKey.lowercased(), actionType: typeToSave, actionTarget: targetToSave)
                        self.configManager.buttons.append(btn)
                        self.configManager.save()
                        withAnimation { self.isAddingAction = false }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .disabled(newName.isEmpty || (actionType != "none" && actionTarget.isEmpty))
                }
            }
            .padding(16)
        }
    }
}

struct TooltipView: NSViewRepresentable {
    let text: String
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.toolTip = text
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.toolTip = text
    }
}

struct EditActionSheet: View {
    @EnvironmentObject var configManager: ConfigManager
    @Binding var activeSheet: SettingsHostingView.ActiveSheet?
    let index: Int
    
    @State private var editName = ""
    @State private var editKey = ""
    @State private var actionType = "app"
    @State private var actionTarget = ""
    
    let types = ["app", "shell", "none"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Action")
                .font(.system(size: 14, weight: .semibold))
                .padding(.top, 4)
            
            Form {
                Section {
                    TextField("Action Name", text: $editName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        TextField("Shortcut Key", text: Binding<String>(
                            get: { self.editKey },
                            set: { newValue in
                                if newValue.count > 1 {
                                    self.editKey = String(newValue.suffix(1)).lowercased()
                                } else {
                                    self.editKey = newValue.lowercased()
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                        Text("Triggers via Cmd + [Key]")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Action Type", selection: $actionType) {
                        Text("Application").tag("app")
                        Text("Command / Script").tag("shell")
                        Text("No Action").tag("none")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if actionType != "none" {
                        HStack {
                            TextField(actionType == "app" ? "App Path" : "Shell Command", text: $actionTarget)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if actionType == "app" {
                                Button("Browse...") {
                                    let panel = NSOpenPanel()
                                    panel.canChooseFiles = true
                                    panel.canChooseDirectories = false
                                    panel.allowsMultipleSelection = false
                                    panel.allowedFileTypes = ["app"]
                                    if panel.runModal() == .OK {
                                        self.actionTarget = panel.url?.path ?? ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            
            HStack {
                Button("Cancel") { self.activeSheet = nil }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
                
                Spacer()
                
                Button("Save Changes") {
                    let typeToSave = self.actionType == "none" ? nil : self.actionType
                    let targetToSave = self.actionType == "none" ? nil : self.actionTarget
                    var btn = self.configManager.buttons[self.index]
                    btn.name = self.editName
                    btn.key = self.editKey.lowercased()
                    btn.actionType = typeToSave
                    btn.actionTarget = targetToSave
                    self.configManager.buttons[self.index] = btn
                    self.configManager.save()
                    self.activeSheet = nil
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(6)
                .disabled(editName.isEmpty || (actionType != "none" && actionTarget.isEmpty))
            }
        }
        .padding(20)
        .frame(width: 380)
        .onAppear {
            let btn = self.configManager.buttons[self.index]
            self.editName = btn.name
            self.editKey = btn.key
            self.actionType = btn.actionType ?? "none"
            self.actionTarget = btn.actionTarget ?? ""
        }
    }
}

struct QuickLaunchDockView: View {
    let apps = [
        ("Google Chrome", "com.google.Chrome", "/Applications/Google Chrome.app"),
        ("ChatGPT", "com.openai.chat", "/Applications/ChatGPT.app"),
        ("Telegram", "ru.keepcoder.Telegram", "/Applications/Telegram.app")
    ]
    
    func getAppURL(for app: (name: String, bundleId: String, defaultPath: String)) -> URL? {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleId) {
            return url
        }
        let defaultURL = URL(fileURLWithPath: app.defaultPath)
        if FileManager.default.fileExists(atPath: defaultURL.path) {
            return defaultURL
        }
        return nil
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(apps.indices, id: \.self) { index in
                Group {
                    if self.getAppURL(for: (self.apps[index].0, self.apps[index].1, self.apps[index].2)) != nil {
                        Button(action: {
                            if let url = self.getAppURL(for: (self.apps[index].0, self.apps[index].1, self.apps[index].2)) {
                                let config = NSWorkspace.OpenConfiguration()
                                NSWorkspace.shared.openApplication(at: url, configuration: config, completionHandler: nil)
                            }
                        }) {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: self.getAppURL(for: (self.apps[index].0, self.apps[index].1, self.apps[index].2))!.path))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .saturation(0.0) // Black and white (grayscale)
                                .opacity(0.8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(TooltipView(text: self.apps[index].0))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        if index < self.apps.count - 1 {
                            Divider().frame(height: 16)
                        }
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
        .padding(.vertical, 8)
    }
}
