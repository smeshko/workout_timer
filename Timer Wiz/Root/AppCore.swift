import ComposableArchitecture
import CoreLogic
import CorePersistence
import Foundation
import QuickWorkoutsList
import DomainEntities
import UIKit
import WorkoutSettings

enum AppAction {
    case appDidBecomeActive
    case appDidBecomeInactive
    case appDidGoToBackground

    case workoutsListAction(QuickWorkoutsListAction)
    case onboardingAction(OnboardingAction)
    case notificationAuthResult(Result<Bool, Error>)
}

struct AppState: Equatable {
    var workoutsListState = QuickWorkoutsListState()
    var onboardingState: OnboardingState?

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
    onboardingReducer.optional().pullback(
        state: \.onboardingState,
        action: /AppAction.onboardingAction,
        environment: { _ in }
    ),
    Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> { state, action, environment in
        struct LocalStorageReadId: Hashable {}
         
        switch action {
        case .appDidBecomeActive:
            if environment.settings.onboardingShown == false {
                state.onboardingState = OnboardingState()
            }
            environment.settings.setupFirstAppStartValues()
            if environment.settings.keepScreenOn {
                UIApplication.shared.isIdleTimerDisabled = true
            }

        case .appDidGoToBackground:
            if environment.settings.keepScreenOn {
                UIApplication.shared.isIdleTimerDisabled = false
            }

        case .appDidBecomeInactive:
            if environment.settings.keepScreenOn {
                UIApplication.shared.isIdleTimerDisabled = false
            }

        case .onboardingAction(.start):
            environment.settings.setOnboardingShown(to: true)
            state.onboardingState = nil
            return environment
                .notificationClient
                .requestAuthorisation()
                .receive(on: DispatchQueue.main.eraseToAnyScheduler())
                .catchToEffect()
                .map(AppAction.notificationAuthResult)

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
