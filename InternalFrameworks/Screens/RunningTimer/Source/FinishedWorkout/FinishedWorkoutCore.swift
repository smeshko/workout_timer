import Foundation
import CoreLogic
import CorePersistence
import DomainEntities
import ComposableArchitecture

public enum FinishedWorkoutAction: Equatable {
    case onAppear
    case didSaveFinishedWorkout(Result<Statistic, PersistenceError>)
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
    let soundClient: SoundClient

    public init(repository: StatisticsRepository,
                soundClient: SoundClient = .live) {
        self.repository = repository
        self.soundClient = soundClient
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
        guard environment.settings.soundEnabled else { return .none }
        return environment.soundClient.play(.workout).fireAndForget()

    case .didSaveFinishedWorkout(.failure):
        break
    }

    return .none
}
