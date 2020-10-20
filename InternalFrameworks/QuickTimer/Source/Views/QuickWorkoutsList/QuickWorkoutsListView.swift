import SwiftUI
import ComposableArchitecture

public struct QuickWorkoutsListView: View {

    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State var isPresenting = false

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                ScrollView {
                    if viewStore.workoutStates.isEmpty {
                        Text("No workouts")
                    } else {
                        ForEachStore(store.scope(state: { $0.workoutStates }, action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { viewStore in
                                QuickWorkoutCardView(store: viewStore)
                                    .padding(.horizontal, 28)
                                    .padding(.bottom, 8)
                        }
                    }
                }
                .toolbar {
                    HStack {
                        Button(action: {
                            isPresenting = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .sheet(isPresented: $isPresenting, content: {
                            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState, action: QuickWorkoutsListAction.createWorkoutAction))
                        })
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
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
