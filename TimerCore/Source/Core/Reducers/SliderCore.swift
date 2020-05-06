import ComposableArchitecture

enum SliderAction: Equatable {
  
}

struct SliderState: Equatable {
  var isDragging: Bool = false
  var value: Int = 0
}

struct SliderEnvironment {}

let sliderReducer = Reducer<SliderState, SliderAction, SliderEnvironment> { state, action, _ in
  
  return .none
}
