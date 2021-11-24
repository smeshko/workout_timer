import SwiftUI
import CoreLogic
import ComposableArchitecture
import CorePersistence
import DomainEntities
import TimersList
import RunningTimer
import NewTimerForm
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
                TimerView2()
//                CountdownView(
//                    store: Store(
//                        initialState: CountdownState(workoutColor: WorkoutColor.init(color: Color(red: 77 / 255, green: 144 / 255, blue: 142 / 255))),
//                        reducer: countdownReducer,
//                        environment: .live
//                    )
//                )
//                IfLetStore(
//                    store.scope(state: \.onboardingState, action: AppAction.onboardingAction),
//                    then: OnboardingView.init(store:),
//                    else: { TimersListView(store: store.scope(state: \.workoutsListState, action: AppAction.workoutsListAction)) }
//                )
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
