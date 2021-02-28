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

enum AppAction {
    case workoutsListAction(QuickWorkoutsListAction)
}

struct AppState: Equatable {
    var workoutsListState = QuickWorkoutsListState()

    init() {}
}

struct AppEnvironment {}

extension SystemEnvironment where Environment == AppEnvironment {
    static let preview = SystemEnvironment.mock(environment: AppEnvironment())
    static let live = SystemEnvironment.live(environment: AppEnvironment())
}

let appReducer = Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>>.combine(
    Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> { state, action, environment in
        struct LocalStorageReadId: Hashable {}

        switch action {

        case .workoutsListAction:
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
