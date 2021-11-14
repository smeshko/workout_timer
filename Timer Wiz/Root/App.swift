import SwiftUI
import CoreLogic
import ComposableArchitecture
import CorePersistence
import TimersList
import CoreInterface
import WorkoutSettings

@main
struct MainApp: App {
    @Environment(\.scenePhase) var scenePhase
    let store: Store<AppState, AppAction>

    init() {
        store = Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live
        )
    }

    var body: some Scene {
        WithViewStore(store.stateless) { viewStore in
            WindowGroup {
                IfLetStore(
                    store.scope(state: \.onboardingState, action: AppAction.onboardingAction),
                    then: OnboardingView.init(store:),
                    else: { QuickWorkoutsListView(store: store.scope(state: \.workoutsListState, action: AppAction.workoutsListAction)) }
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
