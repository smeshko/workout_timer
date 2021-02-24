import ComposableArchitecture
import SwiftUI

public extension ViewStore {
    func binding<LocalState>(
        get: @escaping (State) -> LocalState
    ) -> Binding<LocalState> {
        Binding(
            get: { get(self.state) },
            set: { _ in }
        )
    }
}
