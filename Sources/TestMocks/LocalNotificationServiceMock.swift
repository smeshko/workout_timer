import Foundation
import TestUtilities
import ServiceRegistry

public class LocalNotificationServiceMock: MockBase, LocalNotificationServiceProtocol {
    public func requestAuthorisation() async throws -> Bool {
        track()
        return true
    }
    
    public func scheduleLocalNotification(content: Content, trigger: Trigger) async throws -> Bool {
        track()
        return true
    }
}
