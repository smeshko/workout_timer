import DomainEntities
import CoreLogic
import ComposableArchitecture

public enum CountdownAction: Equatable {
    case start
    case timerTicked
    case finished
    case skip
}

public struct CountdownState: Equatable {
    var timeLeft: Int
    var workoutColor: WorkoutColor

    public init(timeLeft: TimeInterval = 3, workoutColor: WorkoutColor = .empty) {
        self.timeLeft = Int(timeLeft)
        self.workoutColor = workoutColor
    }
}

public struct CountdownEnvironment {
    public init() {}
}

public extension SystemEnvironment where Environment == CountdownEnvironment {
    static let preview = SystemEnvironment.mock(environment: CountdownEnvironment())
    static let live = SystemEnvironment.live(environment: CountdownEnvironment())
}

public let countdownReducer = Reducer<CountdownState, CountdownAction, SystemEnvironment<CountdownEnvironment>> { state, action, environment in
    struct TimerId: Hashable {}

    switch action {
    case .start:
        return Effect
            .timer(id: TimerId(), every: .seconds(1), tolerance: .zero, on: environment.mainQueue())
            .map { _ in CountdownAction.timerTicked }

    case .timerTicked:
        state.timeLeft -= 1
        if state.timeLeft <= 0 {
            return Effect(value: .finished).eraseToEffect()
        }

    case .finished:
        return .cancel(id: TimerId())
    
    case .skip:
        return Effect(value: .finished)
    }
    return .none
}
