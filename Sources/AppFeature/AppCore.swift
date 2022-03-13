import ComposableArchitecture
import CoreLogic
import CorePersistence
import Foundation
import TimersListFeature
import DomainEntities
import UIKit
import SettingsFeature

enum AppAction {
    case appDidBecomeActive
    case appDidBecomeInactive
    case appDidGoToBackground

    case workoutsListAction(TimersListAction)
    case onboardingAction(OnboardingAction)
    case notificationAuthResult(Result<Bool, Error>)
}

struct AppState: Equatable {
    var workoutsListState = TimersListState()
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
            if environment.settings.value(for: .onboardingShown) == false {
                state.onboardingState = OnboardingState()
            }
            environment.settings.setupFirstAppStartValues()
            if environment.settings.value(for: .screen) {
                UIApplication.shared.isIdleTimerDisabled = true
            }

        case .appDidGoToBackground:
            if environment.settings.value(for: .screen) {
                UIApplication.shared.isIdleTimerDisabled = false
            }

        case .appDidBecomeInactive:
            if environment.settings.value(for: .screen) {
                UIApplication.shared.isIdleTimerDisabled = false
            }

        case .onboardingAction(.start):
            environment.settings.set(.onboardingShown, to: true)
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
    timersListReducer.pullback(
        state: \.workoutsListState,
        action: /AppAction.workoutsListAction,
        environment: { _ in .live }
    )
)

private extension SettingsClient {
    func setupFirstAppStartValues() {
        if !value(for: .appStarted) {
            set(.sound, to: true)
            set(.screen, to: true)
            set(.appStarted, to: true)
        }
    }
}
