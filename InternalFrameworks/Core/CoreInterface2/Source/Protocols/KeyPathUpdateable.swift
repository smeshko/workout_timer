import Foundation

public protocol KeyPathUpdateable {
    func update<T>(_ keyPath: WritableKeyPath<Self, T>, value: T) -> Self
}

public extension KeyPathUpdateable {
    func update<T>(_ keyPath: WritableKeyPath<Self, T>, value: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
