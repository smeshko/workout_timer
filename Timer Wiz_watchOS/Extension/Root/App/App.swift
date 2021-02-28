import SwiftUI
import CoreLogic
import QuickWorkoutsList
import ComposableArchitecture

@main
struct QuickWorkoutsApp: App {
    let store: Store<AppState, AppAction>

    init() {
        store = Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live
        )
    }

    @SceneBuilder var body: some Scene {
        WithViewStore(store.stateless) { viewStore in
            WindowGroup {
                QuickWorkoutsListView(store: store.scope(state: \.workoutsListState, action: AppAction.workoutsListAction))
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
