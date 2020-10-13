import ComposableArchitecture

public enum PickerAction: Equatable {
    case valueUpdated(String)
}

public struct PickerState: Equatable {
    var value: String = ""

    public init(value: Int = 0) {
        self.value = "\(value)"
    }
}

public struct PickerEnvironment {}

public let pickerReducer = Reducer<PickerState, PickerAction, PickerEnvironment> { state, action, _ in

    switch action {
    case .valueUpdated(let value):
        state.value = value
    }

    return .none
}
