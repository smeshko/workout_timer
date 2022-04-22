import Foundation
import ServiceRegistry

public class SettingsService: SettingsServiceProtocol {
    private let storage: LocalStorageProtocol

    public init() {
        self.storage = UserDefaults.standard
    }

    init(storage: LocalStorageProtocol) {
        self.storage = storage
    }

    public func value<V: Defaultable>(for key: Key) -> V {
        storage.value(for: key) ?? .default
    }

    public func set(_ key: Key, to value: Bool) {
        storage.set(value, for: key)
    }
}

protocol LocalStorageProtocol {
    func set(_ value: Bool, for key: SettingsClient.Key)
    func bool(for key: SettingsClient.Key) -> Bool
    func value<V: Defaultable>(for key: SettingsClient.Key) -> V?
}

extension UserDefaults: LocalStorageProtocol {
    func bool(for key: SettingsClient.Key) -> Bool {
        bool(forKey: key.rawValue)
    }

    func value<V: Defaultable>(for key: SettingsClient.Key) -> V? {
        value(forKey: key.rawValue) as? V
    }

    func set(_ value: Bool, for key: SettingsClient.Key) {
        set(value, forKey: key.rawValue)
    }
}
