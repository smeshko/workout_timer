import ComposableArchitecture

public enum PickerAction: Equatable {
  case valueUpdated(Int)
  case togglePickerVisibility
}

public struct PickerState: Equatable {
  var isShowingPicker: Bool = false
  var value: Int = 0
  var isInteractionDisabled: Bool = false
  
  public init(
    isShowingPicker: Bool = false,
    value: Int = 0,
    isInteractionDisabled: Bool = false
  ) {
    self.isShowingPicker = isShowingPicker
    self.value = value
    self.isInteractionDisabled = isInteractionDisabled
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
