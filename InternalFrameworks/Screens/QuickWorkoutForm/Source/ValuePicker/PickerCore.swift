import ComposableArchitecture

public enum PickerAction: Equatable {
    case valueUpdated(Int)
}

struct PickerState: Equatable {
    var value: Int
    var allNumbers: [Int]

    public init(value: Int = 0, allNumbers: [Int] = Array(0...100)) {
        self.value = value
        self.allNumbers = allNumbers
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
