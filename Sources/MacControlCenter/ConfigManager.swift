import Foundation
import SwiftUI

struct ActionButton: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var key: String
    var actionType: String?
    var actionTarget: String?
    
    enum CodingKeys: String, CodingKey {
        case name, key, actionType, actionTarget
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
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let configDir = appSupportURL.appendingPathComponent("MacControlCenter")
        
        if !fileManager.fileExists(atPath: configDir.path) {
            try? fileManager.createDirectory(at: configDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        configURL = configDir.appendingPathComponent("config.json")
        load()
    }
    
    func load() {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            // Default config
            buttons = [
                ActionButton(name: "Start My Day", key: "s", actionType: "app", actionTarget: "/Users/bappygolder/Desktop/Projects/_1. Co-Work Projects/1. Start My Day/1. Start My Day.app"),
                ActionButton(name: "Post The Next Comment", key: "p", actionType: nil, actionTarget: nil),
                ActionButton(name: "New Chrome window", key: "c", actionType: "shell", actionTarget: "open -na 'Google Chrome'")
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
                    let actionType = dict["actionType"] as? String
                    let actionTarget = dict["actionTarget"] as? String
                    return ActionButton(name: name, key: key, actionType: actionType, actionTarget: actionTarget)
                }
            }
        } catch {
            print("Error loading config: \(error)")
        }
    }
    
    func performAction(for button: ActionButton) {
        ActivityHandler.shared.execute(button: button)
    }
    
    func save() {
        let dictArray = buttons.map { btn -> [String: String] in
            var dict = ["name": btn.name, "key": btn.key]
            if let type = btn.actionType { dict["actionType"] = type }
            if let target = btn.actionTarget { dict["actionTarget"] = target }
            return dict
        }
        let saveDict = ["buttons": dictArray]
        do {
            let data = try JSONSerialization.data(withJSONObject: saveDict, options: .prettyPrinted)
            try data.write(to: configURL)
        } catch {
            print("Error saving config: \(error)")
        }
    }
}
