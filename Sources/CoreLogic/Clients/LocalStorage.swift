import Foundation

protocol LocalStorage {
    func set(_ value: Bool, for key: SettingsClient.Key)
    func bool(for key: SettingsClient.Key) -> Bool
    func value<V: Defaultable>(for key: SettingsClient.Key) -> V?
}

extension UserDefaults: LocalStorage {
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
