import Foundation
import Cocoa
import UserNotifications

class ActivityHandler {
    static let shared = ActivityHandler()

    private init() {}

    func execute(button: ActionButton) {
        let actionType = button.actionType?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let actionTarget = button.actionTarget?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !actionType.isEmpty, !actionTarget.isEmpty else {
            showNotification(title: "Action Not Configured", text: "'\(button.name)' does not have a target yet.")
            return
        }

        switch actionType {
        case "app":
            launchApplication(at: actionTarget, buttonName: button.name)
        case "shell":
            runShellCommand(actionTarget, buttonName: button.name)
        default:
            showNotification(title: "Unknown Action Type", text: "'\(actionType)' for '\(button.name)'")
        }
    }

    private func launchApplication(at path: String, buttonName: String) {
        let appURL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: appURL.path) else {
            showNotification(title: "App Not Found", text: "'\(buttonName)' points to a missing app.")
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = true

        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
            if let error = error {
                self.showNotification(title: "Could Not Open App", text: error.localizedDescription)
            }
        }
    }

    private func runShellCommand(_ command: String, buttonName: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]

        do {
            try process.run()
        } catch {
            showNotification(title: "Command Failed", text: "'\(buttonName)' could not be started.")
        }
    }

    private func showNotification(title: String, text: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = text
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request, withCompletionHandler: nil)
        }
    }
}
