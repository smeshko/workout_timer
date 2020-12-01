import ComposableArchitecture

public enum TimerControlsAction: Equatable {
    case start
    case pause
}

@dynamicMemberLookup
public struct TimerControlsState: Equatable {
    public enum TimerValue {
        case running
        case paused
        case finished

        var isRunning: Bool { self == .running }
        var isFinished: Bool { self == .finished }
        var isPaused: Bool { self == .paused }
    }

    var timerState: TimerValue = .finished

    subscript<T>(dynamicMember keyPath: KeyPath<TimerValue, T>) -> T {
        timerState[keyPath: keyPath]
    }
    
    public init() {}
    public init(timerState: TimerValue) {
        self.timerState = timerState
    }
}

public struct QuickTimerControlsEnvironment: Equatable {
    public init() {}
}

public let quickTimerControlsReducer = Reducer<TimerControlsState, TimerControlsAction, QuickTimerControlsEnvironment> { state, action, _ in
    
    switch action {
    case .start:
        state.timerState = .running
    case .pause:
        state.timerState = .paused
    }
    
    return .none
}
