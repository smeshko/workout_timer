import ComposableArchitecture

public enum PickerAction: Equatable {
    case valueUpdated(Int)
    case stringValueUpdated(String)
}

struct PickerState: Equatable {
    var value: Int
    var allNumbers: [Int]

    var stringValue = ""

    public init(value: Int = 0, allNumbers: [Int] = Array(0...100)) {
        self.value = value
        self.stringValue = "\(value)"
        self.allNumbers = allNumbers
    }
}

struct PickerEnvironment {}

let pickerReducer = Reducer<PickerState, PickerAction, PickerEnvironment> { state, action, _ in

    switch action {
    case .valueUpdated(let value):
        state.stringValue = "\(value)"
        state.value = value

    case .stringValueUpdated(let value):
        state.stringValue = value
        state.value = Int(value) ?? 0
    }

    return .none
}
