import ComposableArchitecture
import CorePersistence
import Foundation
import QuickTimer
import DomainEntities

enum AppAction {
    case appDidBecomeActive
    case appDidBecomeInactive
    case appDidGoToBackground

    case workoutsListAction(QuickWorkoutsListAction)

    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)

}

struct AppState: Equatable {
    var workoutsListState = QuickWorkoutsListState()

    init() {}
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var repository: QuickWorkoutsRepository
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        struct LocalStorageReadId: Hashable {}
         
        switch action {
        case .appDidBecomeActive:
            return environment.repository.fetchAllWorkouts()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.didFetchWorkouts)

        case .appDidGoToBackground:
        return environment.repository.fetchAllWorkouts()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(AppAction.didFetchWorkouts)

        case .appDidBecomeInactive:
            break

        case .didFetchWorkouts(.success(let workouts)):
            state.workoutsListState = QuickWorkoutsListState(workouts: workouts)

        case .didFetchWorkouts(.failure(_)):
            break

        case .workoutsListAction:
            break
        }
        
        return .none
    },
    quickWorkoutsListReducer.pullback(
        state: \.workoutsListState,
        action: /AppAction.workoutsListAction,
        environment: { QuickWorkoutsListEnvironment(repository: $0.repository, mainQueue: $0.mainQueue) }
    )
)
