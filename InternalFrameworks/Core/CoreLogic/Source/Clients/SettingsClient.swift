import Foundation

public struct SettingsClient {
    enum Key: String {
        case iCloud
        case sound
        case screen
    }

    private let storage: LocalStorage
    private init(storage: LocalStorage) {
        self.storage = storage
    }

    public var iCloudEnabled: Bool {
        storage.bool(for: .iCloud)
    }

    public var soundEnabled: Bool {
        storage.bool(for: .sound)
    }

    public var keepScreenOn: Bool {
        storage.bool(for: .screen)
    }

    public func setiCloudSync(to value: Bool) {
        storage.set(value, for: .iCloud)
    }

    public func setSoundEnabled(to value: Bool) {
        storage.set(value, for: .sound)
    }

    public func setKeepScreenOn(to value: Bool) {
        storage.set(value, for: .screen)
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

private struct MockLocalStorage: LocalStorage {
    func set(_ value: Bool, for key: SettingsClient.Key) {}
    func bool(for key: SettingsClient.Key) -> Bool { false }
    func value(for key: SettingsClient.Key) -> Any? { nil }
}
