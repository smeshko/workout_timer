import SwiftUI
import CoreLogic
import ComposableArchitecture
import CorePersistence
import QuickWorkoutsList

@main
struct MainApp: App {

    @Environment(\.scenePhase) var scenePhase

    let store: Store<AppState, AppAction>
    let viewStore: ViewStore<AppState, AppAction>

    init() {
        store = Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                repository: .live
            )
        )
        viewStore = ViewStore(store)
    }

    var body: some Scene {
        WindowGroup {
            QuickWorkoutsListView(store: store.scope(state: \.workoutsListState, action: AppAction.workoutsListAction))
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                viewStore.send(.appDidBecomeActive)
                UIApplication.shared.isIdleTimerDisabled = true
            case .inactive:
                viewStore.send(.appDidBecomeInactive)
                UIApplication.shared.isIdleTimerDisabled = false
            case .background:
                viewStore.send(.appDidGoToBackground)
                UIApplication.shared.isIdleTimerDisabled = false
            @unknown default:
                break
            }
        }
    }
}

