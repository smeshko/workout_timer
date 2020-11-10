import SwiftUI
import CoreLogic
import ComposableArchitecture
import CorePersistence
import QuickWorkoutsList
import CoreInterface

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
                repository: .live,
                notificationClient: .live
            )
        )
        viewStore = ViewStore(store)
    }

    var body: some Scene {
        WindowGroup {
            QuickWorkoutsListView(store: store.scope(state: \.workoutsListState, action: AppAction.workoutsListAction))
//            NavigationView {
//                ClassView()
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                    .edgesIgnoringSafeArea(.all)
//                    .navigationTitle("People")
//                    .navigationBarTitleDisplayMode(.inline)
//            }
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

private struct ClassView: View {
    let store = Store<ClassState, ClassAction>(
        initialState: ClassState(),
        reducer: classReducer,
        environment: ClassEnv()
    )

    var body: some View {
        WithViewStore(store) { viewStore in
            CoreInterface.List(store.scope(state: \.people, action: ClassAction.personAction)) { store in
                PersonView(store: store)
            }
            .actionProvider { indices in
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    viewStore.send(.remove(indices))
                }

                return UIMenu(title: "", children: [delete])
            }
            .previewProvider { viewStore in
                Text("preview")
            }
            .destination { viewStore in
                Text("Destination")
            }
        }
    }
}

private struct PersonView: View {
    let store: Store<Person, PersonAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.name)
                .font(.h2)
                .foregroundColor(.appText)
                .padding()
        }
    }
}

private enum PersonAction {

}

private struct Person: Equatable, Identifiable {
    var id: String { name }
    let name: String
}

private struct ClassState: Equatable {
    var people: IdentifiedArrayOf<Person> = IdentifiedArray(Array(1...10).map { Person(name: "Name \($0)") })
}

private enum ClassAction {
    case personAction(String, PersonAction)
    case remove(IndexSet)
}

private struct ClassEnv {}

private let classReducer = Reducer<ClassState, ClassAction, ClassEnv> { state, action, _ in

    switch action {
    case .personAction(_, _):
        break

    case .remove(let index):
        index.forEach { state.people.remove(at: $0) }
    }

    return .none
}
