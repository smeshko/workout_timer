import ComposableArchitecture

public enum TimerControlsAction: Equatable {
  case start
  case stop
  case pause
}

public struct TimerControlsState: Equatable {
  var isRunning: Bool = false
  
  public init() {}
}

public struct TimerControlsEnvironment: Equatable {
  public init() {}
}

public let timerControlsReducer = Reducer<TimerControlsState, TimerControlsAction, TimerControlsEnvironment> { state, action, _ in
  
  switch action {
  case .start:
    state.isRunning = true
    
  case .stop, .pause:
    state.isRunning = false
  }
  
  return .none
}
