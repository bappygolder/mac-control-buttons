import Foundation
import SwiftUI

struct ActionButton: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var key: String
    
    enum CodingKeys: String, CodingKey {
        case name, key
    }
}

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var buttons: [ActionButton] = []
    
    private let configURL: URL
    
    init() {
        // Look for config.json in the same folder as the app executable or a specific path
        // For menu bar apps, it's often in App Support, but let's keep it next to the app for now
        // Assuming we run it from the project directory and config.json is there.
        // Actually, we can use the user's home directory or the path where config.json was.
        let fileManager = FileManager.default
        let currentDir = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        configURL = currentDir.appendingPathComponent("config.json")
        load()
    }
    
    func load() {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            // Default config
            buttons = [
                ActionButton(name: "Start My Day", key: "s"),
                ActionButton(name: "Post The Next Comment", key: "p")
            ]
            save()
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let buttonsArray = json?["buttons"] as? [[String: Any]] {
                self.buttons = buttonsArray.compactMap { dict in
                    guard let name = dict["name"] as? String else { return nil }
                    let key = dict["key"] as? String ?? ""
                    return ActionButton(name: name, key: key)
                }
            }
        } catch {
            print("Error loading config: \(error)")
        }
    }
    
    func performAction(for button: ActionButton) {
        if button.name.lowercased() == "start my day" {
            let appPath = "/Users/bappygolder/Desktop/Projects/_1. Co-Work Projects/1. Start My Day/1. Start My Day.app"
            let process = Process()
            process.launchPath = "/usr/bin/open"
            process.arguments = ["-a", appPath]
            process.launch()
            return
        }
        
        let notification = NSUserNotification()
        notification.title = "Action Triggered"
        notification.informativeText = "'\(button.name)'"
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func save() {
        let dictArray = buttons.map { ["name": $0.name, "key": $0.key] }
        let saveDict = ["buttons": dictArray]
        do {
            let data = try JSONSerialization.data(withJSONObject: saveDict, options: .prettyPrinted)
            try data.write(to: configURL)
        } catch {
            print("Error saving config: \(error)")
        }
    }
}
