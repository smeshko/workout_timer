import Foundation
import CoreLogic2
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

public extension SystemEnvironment where Environment == FinishedWorkoutEnvironment {
    static let live = SystemEnvironment.live(environment: FinishedWorkoutEnvironment(repository: .live, soundClient: .live))
    static let preview = SystemEnvironment.mock(environment: FinishedWorkoutEnvironment(repository: .mock, soundClient: .mock))
}

public let finishedWorkoutReducer = Reducer<FinishedWorkoutState, FinishedWorkoutAction, SystemEnvironment<FinishedWorkoutEnvironment>> { state, action, environment in

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
    }

    return .none
}
