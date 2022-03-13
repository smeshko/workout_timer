import SwiftUI
import CoreLogic
import ComposableArchitecture
import CorePersistence
import DomainEntities
import TimersListFeature
import RunningTimerFeature
import NewTimerFeature
import CoreInterface
import SettingsFeature

public struct AppView: Scene {
    let store: Store<AppState, AppAction>
    @Environment(\.scenePhase) var scenePhase


    public init() {
        store = Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live
        )
    }

    public var body: some Scene {
        WithViewStore(store.stateless) { viewStore in
            WindowGroup {
                IfLetStore(
                    store.scope(state: \.onboardingState, action: AppAction.onboardingAction),
                    then: OnboardingView.init(store:),
                    else: { TimersListView(store: store.scope(state: \.workoutsListState, action: AppAction.workoutsListAction)) }
                )
            }
            .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .active:
                    viewStore.send(.appDidBecomeActive)
                case .inactive:
                    viewStore.send(.appDidBecomeInactive)
                case .background:
                    viewStore.send(.appDidGoToBackground)
                @unknown default:
                    break
                }
            }
        }
    }
}
