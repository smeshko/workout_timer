import ComposableArchitecture
import CoreLogic
import CorePersistence
import Foundation
import QuickWorkoutsList
import DomainEntities
import UIKit

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
    let notificationClient: LocalNotificationClient
}

extension SystemEnvironment where Environment == AppEnvironment {
    static let preview = SystemEnvironment.mock(environment: AppEnvironment(notificationClient: .mock))
    static let live = SystemEnvironment.live(environment: AppEnvironment(notificationClient: .live))
}

let appReducer = Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>>.combine(
    Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> { state, action, environment in
        struct LocalStorageReadId: Hashable {}
         
        switch action {
        case .appDidBecomeActive:
            environment.settings.setupFirstAppStartValues()
            if environment.settings.keepScreenOn {
                UIApplication.shared.isIdleTimerDisabled = true
            }

            return environment
                .notificationClient
                .requestAuthorisation()
                .catchToEffect()
                .map(AppAction.notificationAuthResult)

        case .appDidGoToBackground:
            if environment.settings.keepScreenOn {
                UIApplication.shared.isIdleTimerDisabled = false
            }

        case .appDidBecomeInactive:
            if environment.settings.keepScreenOn {
                UIApplication.shared.isIdleTimerDisabled = false
            }

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
        environment: { _ in .live }
    )
)

private extension SettingsClient {
    func setupFirstAppStartValues() {
        if !appStartedOnce {
            setSoundEnabled(to: true)
            setKeepScreenOn(to: true)
            setAppStartedOnce(to: true)
        }
    }
}
