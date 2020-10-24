import ComposableArchitecture

public enum PickerAction: Equatable {
    case valueUpdated(String)
}

struct PickerState: Equatable {
    var value: String = ""

    public init(value: Int = 0) {
        self.value = "\(value)"
    }
}

struct PickerEnvironment {}

let pickerReducer = Reducer<PickerState, PickerAction, PickerEnvironment> { state, action, _ in

    switch action {
    case .valueUpdated(let value):
        state.value = value
    }

    return .none
}
