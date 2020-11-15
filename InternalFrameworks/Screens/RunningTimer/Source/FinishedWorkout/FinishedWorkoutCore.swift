import Foundation
import CorePersistence
import DomainEntities
import ComposableArchitecture

public enum FinishedWorkoutAction: Equatable {
    case onAppear
    case didSaveFinishedWorkout(Result<Statistic, PersistenceError>)
    case didTapDoneButton
}

public struct FinishedWorkoutState: Equatable {
    let workout: QuickWorkout
    var statistic: Statistic?

    public init(workout: QuickWorkout) {
        self.workout = workout
    }
}

public struct FinishedWorkoutEnvironment {

    let repository: StatisticsRepository

    public init(repository: StatisticsRepository) {
        self.repository = repository
    }
}

public let finishedWorkoutReducer = Reducer<FinishedWorkoutState, FinishedWorkoutAction, FinishedWorkoutEnvironment> { state, action, environment in

    switch action {
    case .onAppear:
        return environment
            .repository
            .finish(state.workout)
            .catchToEffect()
            .map(FinishedWorkoutAction.didSaveFinishedWorkout)

    case .didSaveFinishedWorkout(.success(let statistic)):
        state.statistic = statistic

    case .didSaveFinishedWorkout(.failure):
        break

    case .didTapDoneButton:
        break
    }

    return .none
}