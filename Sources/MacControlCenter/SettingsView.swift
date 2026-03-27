import SwiftUI
import Cocoa

// ... (AppSettings remains unchanged, inserting later)
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
    @Published var isMiniView: Bool {
        didSet {
            UserDefaults.standard.set(isMiniView, forKey: "isMiniView")
        }
    }
    
    init() {
        self.alwaysOnTop = UserDefaults.standard.bool(forKey: "alwaysOnTop")
        self.showOnAllDesktops = UserDefaults.standard.bool(forKey: "showOnAllDesktops")
        self.opacity = UserDefaults.standard.object(forKey: "opacity") as? Double ?? 1.0
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        self.isMiniView = UserDefaults.standard.bool(forKey: "isMiniView")
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
    func makeNSView(context: Context) -> NSView {
        let view = DragView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class DragView: NSView {
    override var acceptsFirstResponder: Bool { true }
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

struct SettingsHostingView: View {
    @EnvironmentObject var configManager: ConfigManager
    @ObservedObject var settings = AppSettings.shared
    
    enum ActiveSheet: Identifiable {
        case add
        var id: Int { hashValue }
    }
    
    @State private var isEditing = false
    @State private var activeSheet: ActiveSheet?
    @State private var showingInlineSettings = false
    
    var body: some View {
        ZStack {
            if settings.isMiniView {
                // TRUE MINI VIEW
                VStack(spacing: 0) {
                    // Header with Menu and Expand
                    HStack(alignment: .center, spacing: 6) {
                        Button(action: { 
                            self.toggleViewMode(toMini: false)
                        }) {
                            Text("Expand")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 10)
                                .frame(height: 24)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(6)
                        }.buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            self.settings.alwaysOnTop.toggle()
                        }) {
                            Text("Top")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(settings.alwaysOnTop ? .white : .primary)
                                .padding(.horizontal, 10)
                                .frame(height: 24)
                                .background(settings.alwaysOnTop ? Color.gray.opacity(0.6) : Color.gray.opacity(0.15))
                                .cornerRadius(6)
                        }.buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(WindowDragHandler())
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    Divider()
                    
                    VStack(spacing: 8) {
                        if showingInlineSettings {
                            InlineSettingsView(isMiniView: true)
                                .frame(maxHeight: 250)
                        } else {
                            ForEach(configManager.buttons.indices, id: \.self) { index in
                                Button(action: {
                                    self.configManager.performAction(for: self.configManager.buttons[index])
                                }) {
                                    HStack {
                                        Text(self.configManager.buttons[index].name
                                            .replacingOccurrences(of: "Post The Next Comment", with: "Post next comment")
                                            .uppercased())
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, minHeight: 30)
                                    .background(Color(NSColor.systemBlue))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 12)
                            }
                        }
                    } // closes the VStack
                    .padding(.vertical, 8)
                    .background(Color(NSColor.underPageBackgroundColor))
                    
                    Spacer().frame(height: 4) // Bottom padding
                }
                .frame(width: 180)
                .background(Color(NSColor.windowBackgroundColor))
                
            } else {
                // NORMAL NATIVE VIEW (Phase 2 style)
                VStack(spacing: 0) {
                    // Toolbar
                    HStack(spacing: 8) {
                        if !showingInlineSettings {
                            Button(action: { self.toggleViewMode(toMini: true) }) {
                                Text("Mini View")
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 10)
                                    .frame(height: 24)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation { self.showingInlineSettings.toggle() } }) {
                            Text(showingInlineSettings ? "Done" : "⚙")
                                .font(.system(size: 12, weight: .medium))
                                .frame(height: 24)
                                .padding(.horizontal, 10)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(6)
                        }.buttonStyle(PlainButtonStyle())
                        
                        if !showingInlineSettings {
                            Button(action: { self.isEditing.toggle() }) {
                                Text(isEditing ? "Done" : "Edit")
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(height: 24)
                                    .padding(.horizontal, 10)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                            }.buttonStyle(PlainButtonStyle())
                            
                            Button(action: { self.activeSheet = .add }) {
                                Text("+")
                                    .font(.system(size: 16, weight: .regular))
                                    .frame(width: 28, height: 24)
                                    .background(Color.gray.opacity(0.15))
                                    .foregroundColor(.primary)
                                    .cornerRadius(6)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    Divider()
                    
                    if showingInlineSettings {
                        InlineSettingsView(isMiniView: false)
                            .background(Color(NSColor.underPageBackgroundColor))
                    } else {
                        // List
                        List {
                            ForEach(configManager.buttons.indices, id: \.self) { index in
                                HStack(alignment: .center, spacing: 12) {
                                    if self.isEditing {
                                        Button(action: {
                                            self.configManager.buttons.remove(at: index)
                                            self.configManager.save()
                                        }) {
                                            Text("一")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 18, height: 18)
                                                .background(Color.red)
                                                .clipShape(Circle())
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
                                                .background(Color(NSColor.systemBlue))
                                                .cornerRadius(11)
                                        }.buttonStyle(PlainButtonStyle())
                                    } else {
                                        Text("≡").font(.system(size: 16)).foregroundColor(.gray)
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
                }
                .frame(minWidth: 300, idealWidth: 350, minHeight: 350, idealHeight: 450)
            }
        }
        .sheet(item: $activeSheet) { item in
            self.sheetView(for: item)
        }
    }
    
    private func sheetView(for item: ActiveSheet) -> AnyView {
        switch item {
        case .add:
            return AnyView(AddActionSheet(activeSheet: self.$activeSheet))
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
    
    private func toggleViewMode(toMini: Bool) {
        guard let window = NSApp.windows.first(where: { $0.title == "Mac Control Center" }) else {
            withAnimation { self.settings.isMiniView = toMini }
            return
        }
        
        let oldMaxX = window.frame.maxX
        let oldMinY = window.frame.minY
        
        withAnimation(.easeInOut(duration: 0.25)) {
            self.settings.isMiniView = toMini
        }
        
        let startTime = Date()
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed > 0.3 {
                timer.invalidate()
                self.keepWindowOnScreen()
                return
            }
            
            var currentFrame = window.frame
            currentFrame.origin.x = oldMaxX - currentFrame.width
            currentFrame.origin.y = oldMinY
            window.setFrame(currentFrame, display: true, animate: false)
        }
    }
}

struct InlineSettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    var isMiniView: Bool
    
    var body: some View {
        ScrollView {
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
        }
    }
}

struct AddActionSheet: View {
    @EnvironmentObject var configManager: ConfigManager
    @Binding var activeSheet: SettingsHostingView.ActiveSheet?
    
    @State private var newName = ""
    @State private var newKey = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Action")
                .font(.system(size: 14, weight: .semibold))
                .padding(.top, 4)
            
            Form {
                Section {
                    TextField("Action Name (e.g. Start My Day)", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        TextField("Shortcut Key", text: Binding<String>(
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
                        .frame(width: 100)
                        Text("Triggers via Cmd + [Key]")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                
                Button("Save Action") {
                    let btn = ActionButton(name: self.newName, key: self.newKey.lowercased())
                    self.configManager.buttons.append(btn)
                    self.configManager.save()
                    self.activeSheet = nil
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color(NSColor.systemBlue))
                .foregroundColor(.white)
                .cornerRadius(6)
                .disabled(newName.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
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


