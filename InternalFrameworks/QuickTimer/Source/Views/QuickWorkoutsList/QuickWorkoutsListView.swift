import SwiftUI
import ComposableArchitecture

public struct QuickWorkoutsListView: View {

    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                VStack {
                    if viewStore.workoutStates.isEmpty {
                        Text("No workouts")
                    } else {
                        ForEachStore(store.scope(state: { $0.workoutStates }, action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { viewStore in
                            QuickWorkoutCardView(store: viewStore)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
        }
    }
}

struct QuickWorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
//        QuickWorkoutsListView()
        Text("")
    }
}
