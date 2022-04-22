import Foundation

public struct Content {
    public let title: String
    public let message: String

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

public struct Trigger {
    public let timeInterval: TimeInterval
    public let repeats: Bool

    public static let immediately = Trigger(timeInterval: 1, repeats: false)

    public init(timeInterval: TimeInterval, repeats: Bool) {
        self.timeInterval = timeInterval
        self.repeats = repeats
    }
}

public protocol LocalNotificationServiceProtocol {
    func requestAuthorisation() async throws -> Bool
    func scheduleLocalNotification(content: Content, trigger: Trigger) async throws -> Bool
}
