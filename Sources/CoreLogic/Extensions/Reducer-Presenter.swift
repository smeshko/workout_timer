import ComposableArchitecture

public enum PresenterAction: Equatable {
    case present
    case dismiss
}

public extension Reducer {
    /// A reducer that handles presentation logic.
    /// - Parameters:
    ///   - keyPath: a boolean flag that handles the presentation
    ///   - presenterAction: the action that is sent for presenting/dismissing
    /// - Returns: a reducer
    func presenter(
        keyPath: WritableKeyPath<State, Bool>,
        action presenterAction: CasePath<Action, PresenterAction>
    ) -> Self {
        Self { state, action, env in
            guard let extractedAction = presenterAction.extract(from: action) else {
                return run(&state, action, env)
            }

            switch extractedAction {
            case .present:
                state[keyPath: keyPath] = true
            case .dismiss:
                state[keyPath: keyPath] = false
            }
            return run(&state, action, env)
        }
    }
}
