import ComposableArchitecture

private struct Constants {
    static let maxLength = 3
}

public enum PickerAction: Equatable {
    case valueUpdated(String)
}

public struct PickerState: Equatable {
    var value: String = "" {
        didSet {
            if value.count > Constants.maxLength && oldValue.count <= Constants.maxLength {
                value = oldValue
            }
        }
    }

    public init(value: Int = 0) {
        self.value = "\(value)"
    }
}

public struct PickerEnvironment {}

public let pickerReducer = Reducer<PickerState, PickerAction, PickerEnvironment> { state, action, _ in

    switch action {
    case .valueUpdated(let value):
        if value.count <= Constants.maxLength {
            state.value = value
        }
    }

    return .none
}
