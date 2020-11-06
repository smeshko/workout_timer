import ComposableArchitecture
import CoreLogic
import CorePersistence
import Foundation
import QuickWorkoutsList
import DomainEntities

enum AppAction {
    case appDidBecomeActive
    case appDidBecomeInactive
    case appDidGoToBackground

    case workoutsListAction(QuickWorkoutsListAction)

    case notificationAuthResult(Result<Bool, Error>)
}

struct AppState: Equatable {
    var workoutsListState = QuickWorkoutsListState()

    init() {}
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var repository: QuickWorkoutsRepository
    let notificationClient: LocalNotificationClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        struct LocalStorageReadId: Hashable {}
         
        switch action {
        case .appDidBecomeActive:
            return environment
                .notificationClient
                .requestAuthorisation()
                .catchToEffect()
                .map(AppAction.notificationAuthResult)

        case .appDidGoToBackground:
            break

        case .appDidBecomeInactive:
            break

        case .workoutsListAction:
            break

        case .notificationAuthResult:
            break
        }
        
        return .none
    },
    quickWorkoutsListReducer.pullback(
        state: \.workoutsListState,
        action: /AppAction.workoutsListAction,
        environment: { QuickWorkoutsListEnvironment(repository: $0.repository, mainQueue: $0.mainQueue, notificationClient: $0.notificationClient) }
    )
)
