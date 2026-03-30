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

private struct ActionConfigFile: Codable {
    var buttons: [ActionButton]
}

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    static let configDidChangeNotification = Notification.Name("MacControlCenterConfigDidChange")

    @Published var buttons: [ActionButton] = []

    private let configURL: URL

    init() {
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
            buttons = defaultButtons()
            save()
            return
        }

        do {
            let data = try Data(contentsOf: configURL)
            let config = try JSONDecoder().decode(ActionConfigFile.self, from: data)
            buttons = config.buttons.map(normalized(button:))
        } catch {
            print("Error loading config: \(error)")
            buttons = defaultButtons()
        }

        publishChange()
    }

    func performAction(for button: ActionButton) {
        ActivityHandler.shared.execute(button: button)
    }

    func save() {
        buttons = buttons.map(normalized(button:))
        let config = ActionConfigFile(buttons: buttons)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(config)
            try data.write(to: configURL, options: .atomic)
            publishChange()
        } catch {
            print("Error saving config: \(error)")
        }
    }

    private func defaultButtons() -> [ActionButton] {
        [
            ActionButton(name: "Open Safari", key: "s", actionType: "shell", actionTarget: "open -a Safari"),
            ActionButton(name: "Open Notes", key: "n", actionType: "shell", actionTarget: "open -a Notes"),
            ActionButton(name: "New Chrome Window", key: "c", actionType: "shell", actionTarget: "open -na 'Google Chrome'")
        ]
    }

    private func normalized(button: ActionButton) -> ActionButton {
        var cleanedButton = button
        cleanedButton.name = cleanedButton.name.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedButton.key = String(cleanedButton.key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().prefix(1))

        if let actionType = cleanedButton.actionType?.trimmingCharacters(in: .whitespacesAndNewlines),
           !actionType.isEmpty {
            cleanedButton.actionType = actionType
        } else {
            cleanedButton.actionType = nil
        }

        if let actionTarget = cleanedButton.actionTarget?.trimmingCharacters(in: .whitespacesAndNewlines),
           !actionTarget.isEmpty {
            cleanedButton.actionTarget = actionTarget
        } else {
            cleanedButton.actionTarget = nil
        }

        return cleanedButton
    }

    private func publishChange() {
        NotificationCenter.default.post(name: Self.configDidChangeNotification, object: self)
    }
}
