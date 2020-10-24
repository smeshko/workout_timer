import SwiftUI
import CoreLogic
import ComposableArchitecture

public struct QuickWorkoutsListView: View {

    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @State var isPresenting: Bool = false

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                if viewStore.workoutStates.isEmpty {
                    NoWorkoutsView(store: store)
                } else {
                    ScrollView {
                        WorkoutsList(store: store)
                    }
                    .toolbar {
                        HStack {
                            Button(action: {
                                isPresenting = true
                            }, label: {
                                Image(systemName: "plus")
                            })
                            .sheet(isPresented: $isPresenting) {
                                CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                                          action: QuickWorkoutsListAction.createWorkoutAction))
                            }
                        }
                    }
                    .navigationTitle("Workouts")
                }
            }
        }
    }
}

struct QuickWorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyStore = Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
            initialState: QuickWorkoutsListState(),
            reducer: quickWorkoutsListReducer,
            environment: QuickWorkoutsListEnvironment(
                repository: .mock,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        )

        let filledStore = Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
            initialState: QuickWorkoutsListState(workouts: [mockQuickWorkout1, mockQuickWorkout2]),
            reducer: quickWorkoutsListReducer,
            environment: QuickWorkoutsListEnvironment(
                repository: .mock,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        )

        return Group {
            QuickWorkoutsListView(store: emptyStore)
                .previewDevice(.iPhone11)
                .preferredColorScheme(.dark)

            QuickWorkoutsListView(store: filledStore)
                .previewDevice(.iPhone11)
        }
    }
}

private struct NoWorkoutsView: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State var isPresenting: Bool = false

    var body: some View {
        VStack(spacing: 18) {
                Button(action: {
                    isPresenting = true
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.appSuccess)
                            .frame(width: 125, height: 125)

                        Image(systemName: "plus")
                            .font(.gigantic)
                            .foregroundColor(.appWhite)
                    }
                })
                .sheet(isPresented: $isPresenting) {
                    CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                              action: QuickWorkoutsListAction.createWorkoutAction))
                }
            Text("Create your first workout")
                .font(.h2)
                .foregroundColor(.appText)
        }
    }
}

private struct WorkoutsList: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    let viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
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
        }
    }
}
