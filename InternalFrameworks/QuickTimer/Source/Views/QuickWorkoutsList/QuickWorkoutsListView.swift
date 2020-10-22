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
//                VStack {
                ScrollView {
                    if viewStore.workoutStates.isEmpty {
                        Text("No workouts")
                    } else {
//                        List {
                        LazyVStack {
                            ForEachStore(store.scope(state: { $0.workoutStates }, action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
                                QuickWorkoutCardView(store: cardViewStore)
                                    .padding(.horizontal, 28)
                                    .padding(.bottom, 18)
                                    .contextMenu {
                                        Button(action: {
                                            withAnimation {
                                                viewStore.send(QuickWorkoutsListAction.deleteWorkout(ViewStore(cardViewStore).workout))
                                            }
                                        }, label: {
                                            Label("Delete", systemImage: "trash")
                                                .foregroundColor(.red)
                                        })
                                    }

                            }
//                            .onDelete(perform: { indexSet in
//                                viewStore.send(.deleteWorkouts(indexSet))
//                            })
//                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//                            .listRowInsets(EdgeInsets(top: -1, leading: -1, bottom: -1, trailing: -1))
//                            .background(Color(.systemBackground))
                        }
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
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
