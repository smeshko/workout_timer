import Foundation

protocol LocalStorage {
    func set(_ value: Bool, for key: SettingsClient.Key)
    func bool(for key: SettingsClient.Key) -> Bool
    func value(for key: SettingsClient.Key) -> Any?
}

extension UserDefaults: LocalStorage {
    func bool(for key: SettingsClient.Key) -> Bool {
        bool(forKey: key.rawValue)
    }

    func value(for key: SettingsClient.Key) -> Any? {
        value(forKey: key.rawValue)
    }

    func set(_ value: Bool, for key: SettingsClient.Key) {
        set(value, forKey: key.rawValue)
    }
}
