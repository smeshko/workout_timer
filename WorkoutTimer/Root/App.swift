import SwiftUI
import WorkoutCore
import ComposableArchitecture
import CorePersistence
import QuickTimer

@main
struct MainApp: App {

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
//            NavigationView {
                QuickWorkoutsListView(
                    store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
                        initialState: QuickWorkoutsListState(),
                        reducer: quickWorkoutsListReducer,
                        environment: QuickWorkoutsListEnvironment(
                            repository: QuickWorkoutsRepository(),
                            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                        )
                    )
                )
//            }
//            RootView(
//                store: Store<AppState, AppAction>(
//                    initialState: AppState(),
//                    reducer: appReducer,
//                    environment: AppEnvironment(
//                        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
//                    )
//                )
//            )
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                UIApplication.shared.isIdleTimerDisabled = true
            case .inactive:
                UIApplication.shared.isIdleTimerDisabled = false
            case .background:
                UIApplication.shared.isIdleTimerDisabled = false
            @unknown default:
                break
            }
        }
    }
}

