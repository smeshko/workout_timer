import Foundation
import DomainEntities
import ComposableArchitecture

public enum PreCountdownAction: Equatable {
    case onAppear
    case timerTicked
    case finished
}

public struct PreCountdownState: Equatable {
    var timeLeft: TimeInterval
    var workoutColor: WorkoutColor

    public init(timeLeft: TimeInterval = 3, workoutColor: WorkoutColor) {
        self.timeLeft = timeLeft
        self.workoutColor = workoutColor
    }
}

public struct PreCountdownEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        self.mainQueue = mainQueue
    }
}

public let preCountdownReducer = Reducer<PreCountdownState, PreCountdownAction, PreCountdownEnvironment> { state, action, environment in
    struct TimerId: Hashable {}

    switch action {
    case .onAppear:
        return Effect
            .timer(id: TimerId(), every: .seconds(1), tolerance: .zero, on: environment.mainQueue)
            .map { _ in PreCountdownAction.timerTicked }

    case .timerTicked:
        state.timeLeft -= 1
        if state.timeLeft <= 0 {
            return Effect(value: PreCountdownAction.finished)
        }

    case .finished:
        return Effect<PreCountdownAction, Never>.cancel(id: TimerId())
    }
    return .none
}
