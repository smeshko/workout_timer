import ComposableArchitecture
import CorePersistence
import Foundation
import QuickWorkoutsList
import DomainEntities

enum AppAction {
    case appDidBecomeActive
    case appDidBecomeInactive
    case appDidGoToBackground

    case workoutsListAction(QuickWorkoutsListAction)
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
            break

        case .appDidGoToBackground:
            break

        case .appDidBecomeInactive:
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
