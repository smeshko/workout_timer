import ComposableArchitecture

public enum TimerState {
    case running
    case paused
    case finished
    
    var isRunning: Bool { self == .running }
    var isFinished: Bool { self == .finished }
    var isPaused: Bool { self == .paused }
}

public enum QuickTimerControlsAction: Equatable {
    case start
    case stop
    case pause
}

public struct QuickTimerControlsState: Equatable {
    var timerState: TimerState = .finished
    
    public init() {}
    public init(timerState: TimerState) {
        self.timerState = timerState
    }
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
