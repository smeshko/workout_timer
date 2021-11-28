import Foundation
import CoreLogic
import CorePersistence
import DomainEntities
import ComposableArchitecture

public enum FinishedWorkoutAction: Equatable {
    case onAppear
    case closeButtonTapped
    case didSaveFinishedWorkout(Result<Statistic, PersistenceError>)
}

public struct FinishedWorkoutState: Equatable {
    var workout: FinishedWorkout
    var caloriesBurned: Int = 0
    var statistic: Statistic?

    public init(workout: FinishedWorkout) {
        self.workout = workout
    }
}

public struct FinishedWorkoutEnvironment {

    let repository: StatisticsRepository
    let calculator: CalorieCalculator
    let soundClient: SoundClient

    public init(repository: StatisticsRepository,
                calculator: CalorieCalculator,
                soundClient: SoundClient = .live) {
        self.repository = repository
        self.calculator = calculator
        self.soundClient = soundClient
    }
}

public extension SystemEnvironment where Environment == FinishedWorkoutEnvironment {
    static let live = SystemEnvironment.live(environment: FinishedWorkoutEnvironment(repository: .live, calculator: .live, soundClient: .live))
    static let preview = SystemEnvironment.mock(environment: FinishedWorkoutEnvironment(repository: .mock, calculator: .mock, soundClient: .mock))
}

public let finishedWorkoutReducer = Reducer<FinishedWorkoutState, FinishedWorkoutAction, SystemEnvironment<FinishedWorkoutEnvironment>> { state, action, environment in

    switch action {
    case .onAppear:
        state.caloriesBurned = environment.calculator.calories(state.workout.totalDuration, 4, 70)
        return environment
            .repository
            .finish(state.workout.workout)
            .catchToEffect()
            .map(FinishedWorkoutAction.didSaveFinishedWorkout)

    case .didSaveFinishedWorkout(.success(let statistic)):
        state.statistic = statistic

    case .didSaveFinishedWorkout(.failure), .closeButtonTapped:
        break
    }

    return .none
}
