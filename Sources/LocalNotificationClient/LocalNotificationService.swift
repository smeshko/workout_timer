import Foundation
import ServiceRegistry
import UserNotifications

public class LocalNotificationService: LocalNotificationServiceProtocol {
    public func requestAuthorisation() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                DispatchQueue.main.async {
                    if success {
                        continuation.resume(returning: true)
                    } else if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }

    public func scheduleLocalNotification(content: Content, trigger: Trigger) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            let request = UNNotificationRequest(content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: true)
                    }
                }
            }
        }
    }
}

private extension UNMutableNotificationContent {
    convenience init(content: Content) {
        self.init()
        self.title = content.title
        self.body = content.message
    }
}

private extension UNTimeIntervalNotificationTrigger {
    convenience init(trigger: Trigger) {
        self.init(timeInterval: trigger.timeInterval, repeats: trigger.repeats)
    }
}

private extension UNNotificationRequest {
    convenience init(content: Content, trigger: Trigger) {
        self.init(identifier: UUID().uuidString,
                  content: UNMutableNotificationContent(content: content),
                  trigger: UNTimeIntervalNotificationTrigger(trigger: trigger))
    }
}
