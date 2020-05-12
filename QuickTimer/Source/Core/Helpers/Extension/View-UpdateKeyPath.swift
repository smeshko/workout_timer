import SwiftUI

extension View {
    func update<T>(_ keyPath: WritableKeyPath<Self, T>, value: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
