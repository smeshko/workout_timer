import Foundation
import TestUtilities
import ServiceRegistry

public class SettingsServiceMock<D: Defaultable>: MockBase, SettingsServiceProtocol {

    public var value: D?

    public func value<V>(for key: Key) -> V where V : Defaultable {
        track()
        return value as! V
    }

    public func set(_ key: Key, to value: Bool) {
        track()
    }
}
