import Foundation
import ComposableArchitecture
import UserNotifications

public struct LocalNotificationClient {
    public struct Content {
        let title: String
        let message: String

        public init(title: String, message: String) {
            self.title = title
            self.message = message
        }
    }

    public struct Trigger {
        let timeInterval: TimeInterval
        let repeats: Bool

        public static let immediately = Trigger(timeInterval: 1, repeats: false)

        public init(timeInterval: TimeInterval, repeats: Bool) {
            self.timeInterval = timeInterval
            self.repeats = repeats
        }
    }

    public var requestAuthorisation: () -> Effect<Bool, Error>
    public var scheduleLocalNotification: (Content, Trigger) -> Effect<Bool, Never>
}

public extension LocalNotificationClient {
    static let live: LocalNotificationClient = LocalNotificationClient(
        requestAuthorisation: {
            Effect<Bool, Error>.future { result in
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            result(.success(true))
                        } else if let error = error {
                            result(.failure(error))
                        } else {
                            result(.success(false))
                        }
                    }
                }

            }
        },
        scheduleLocalNotification: { content, trigger in
            Effect<Bool, Never>.future { future in
                let request = UNNotificationRequest(content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            future(.success(false))
                        } else {
                            future(.success(true))
                        }
                    }
                }
            }
        }
    )

    static let mock: LocalNotificationClient = LocalNotificationClient(
        requestAuthorisation: {
            Effect(value: true)
        },
        scheduleLocalNotification: { _, _ in
            Effect.fireAndForget {}
        }
    )
}

private extension UNMutableNotificationContent {
    convenience init(content: LocalNotificationClient.Content) {
        self.init()
        self.title = content.title
        self.body = content.message
    }
}

private extension UNTimeIntervalNotificationTrigger {
    convenience init(trigger: LocalNotificationClient.Trigger) {
        self.init(timeInterval: trigger.timeInterval, repeats: trigger.repeats)
    }
}

private extension UNNotificationRequest {
    convenience init(content: LocalNotificationClient.Content, trigger: LocalNotificationClient.Trigger) {
        self.init(identifier: UUID().uuidString,
                  content: UNMutableNotificationContent(content: content),
                  trigger: UNTimeIntervalNotificationTrigger(trigger: trigger))
    }
}
