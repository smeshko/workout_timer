import Foundation

public enum Key: String {
    case sound
    case screen
    case appStarted
    case onboardingShown
}

public protocol SettingsServiceProtocol {
    func value<V: Defaultable>(for key: Key) -> V
    func set(_ key: Key, to value: Bool)
}

public protocol Defaultable {
    static var `default`: Self { get }
}
