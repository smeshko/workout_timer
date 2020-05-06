import ComposableArchitecture

enum PickerAction: Equatable {
  case valueUpdated(Int)
  case togglePickerVisibility
}

struct PickerState: Equatable {
  var isShowingPicker: Bool = false
  var value: Int = 0
}

struct PickerEnvironment {}

let pickerReducer = Reducer<PickerState, PickerAction, PickerEnvironment> { state, action, _ in
  
  switch action {
  case .valueUpdated(let value):
    state.value = value
    
  case .togglePickerVisibility:
    state.isShowingPicker.toggle()
  }
  
  return .none
}
