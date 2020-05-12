import ComposableArchitecture

public enum QuickTimerControlsAction: Equatable {
  case start
  case stop
  case pause
}

public struct QuickTimerControlsState: Equatable {
  var isRunning: Bool = false
  
  public init() {}
}

public struct QuickTimerControlsEnvironment: Equatable {
  public init() {}
}

public let quickTimerControlsReducer = Reducer<QuickTimerControlsState, QuickTimerControlsAction, QuickTimerControlsEnvironment> { state, action, _ in
  
  switch action {
  case .start:
    state.isRunning = true
    
  case .stop, .pause:
    state.isRunning = false
  }
  
  return .none
}
