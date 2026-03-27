import Foundation
import Cocoa

class ActivityHandler {
    static let shared = ActivityHandler()
    
    private init() {}
    
    func execute(button: ActionButton) {
        guard let actionType = button.actionType, let actionTarget = button.actionTarget else {
            // Default fallback if no specific type/target is set
            if button.name.lowercased() == "start my day" {
                let appPath = "/Users/bappygolder/Desktop/Projects/_1. Co-Work Projects/1. Start My Day/1. Start My Day.app"
                let process = Process()
                process.launchPath = "/usr/bin/open"
                process.arguments = ["-n", appPath]
                process.launch()
                return
            }
            
            showNotification(title: "Action Triggered", text: "'\(button.name)'")
            return
        }
        
        switch actionType {
        case "app":
            let process = Process()
            process.launchPath = "/usr/bin/open"
            // Use -n to open a new instance and interpret as path rather than app name 
            process.arguments = ["-n", actionTarget]
            process.launch()
        case "shell":
            let process = Process()
            process.launchPath = "/bin/sh"
            process.arguments = ["-c", actionTarget]
            process.launch()
        default:
            showNotification(title: "Unknown Action Type", text: "'\(actionType)' for '\(button.name)'")
        }
    }
    
    private func showNotification(title: String, text: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = text
        NSUserNotificationCenter.default.deliver(notification)
    }
}
