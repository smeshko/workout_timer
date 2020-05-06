import ComposableArchitecture

public enum PickerAction: Equatable {
  case valueUpdated(Int)
  case togglePickerVisibility
}

public struct PickerState: Equatable {
  var isShowingPicker: Bool = false
  var value: Int = 0
  
  public init(
    isShowingPicker: Bool = false,
    value: Int = 0
  ) {
    self.isShowingPicker = isShowingPicker
    self.value = value
  }
}

public struct PickerEnvironment {}

public let pickerReducer = Reducer<PickerState, PickerAction, PickerEnvironment> { state, action, _ in
  
  switch action {
  case .valueUpdated(let value):
    state.value = value
    
  case .togglePickerVisibility:
    state.isShowingPicker.toggle()
  }
  
  return .none
}
