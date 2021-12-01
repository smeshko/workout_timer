import Foundation

public struct SettingsClient {
    public enum Key: String {
        case sound
        case screen
        case appStarted
        case onboardingShown
    }

    private let storage: LocalStorage
    private init(storage: LocalStorage) {
        self.storage = storage
    }
    
    public func value<V: Defaultable>(for key: Key) -> V {
        storage.value(for: key) ?? .default
    }
    
    public func set(_ key: Key, to value: Bool) {
        storage.set(value, for: key)
    }
}

public extension SettingsClient {
    static let live: SettingsClient = {
        let client = SettingsClient(storage: UserDefaults.standard)
        return client
    }()

    static let mock: SettingsClient = {
        let client = SettingsClient(storage: MockLocalStorage())
        return client
    }()
}

public protocol Defaultable {
    static var `default`: Self { get }
}

extension Bool: Defaultable {
    public static var `default`: Bool { false }
}

private struct MockLocalStorage: LocalStorage {
    func set(_ value: Bool, for key: SettingsClient.Key) {}
    func bool(for key: SettingsClient.Key) -> Bool { false }
    func value<V>(for key: SettingsClient.Key) -> V? { nil }
}
