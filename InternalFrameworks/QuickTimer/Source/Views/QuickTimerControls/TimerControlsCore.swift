import ComposableArchitecture

public enum TimerState {
    case running
    case paused
    case finished
}

public enum QuickTimerControlsAction: Equatable {
    case start
    case stop
    case pause
}

public struct QuickTimerControlsState: Equatable {
    var timerState: TimerState = .finished
    
    public init() {}
}

public struct QuickTimerControlsEnvironment: Equatable {
    public init() {}
}

public let quickTimerControlsReducer = Reducer<QuickTimerControlsState, QuickTimerControlsAction, QuickTimerControlsEnvironment> { state, action, _ in
    
    switch action {
    case .start:
        state.timerState = .running
    case .stop:
        state.timerState = .finished
    case .pause:
        state.timerState = .paused
    }
    
    return .none
}
