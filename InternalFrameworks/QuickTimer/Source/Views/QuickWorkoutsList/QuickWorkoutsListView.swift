import SwiftUI
import WorkoutCore
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
                VStack {
                    if viewStore.workoutStates.isEmpty {
                        NoWorkoutsView(store: store, isPresenting: isPresenting)
                    } else {
                        WorkoutsView(store: store, isPresenting: isPresenting)
                    }
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
    @State var isPresenting: Bool

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 18) {
                CreateWorkoutButton(store: store, isPresenting: isPresenting) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.appSuccess)
                            .frame(width: 125, height: 125)

                        Image(systemName: "plus")
                            .font(.gigantic)
                            .foregroundColor(.appWhite)
                    }
                }

//                Button(action: {
//                    viewStore.send(.createWorkoutButtonTapped)
//                    isPresenting = true
//                }, label: {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 12)
//                            .foregroundColor(.appSuccess)
//                            .frame(width: 125, height: 125)
//
//                        Image(systemName: "plus")
//                            .font(.gigantic)
//                            .foregroundColor(.appWhite)
//                    }
//                })
//                .sheet(isPresented: $isPresenting) {
//                    IfLetStore(store.scope(state: \.createWorkoutState, action: QuickWorkoutsListAction.createWorkoutAction),
//                               then: CreateQuickWorkoutView.init(store:))
//                }

                Text("Create your first workout")
                    .font(.h2)
                    .foregroundColor(.appText)
            }
        }
        .navigationTitle("")
    }
}

private struct WorkoutsView: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @State var isPresenting: Bool

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
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
                .toolbar {
                    HStack {
                        CreateWorkoutButton(store: store, isPresenting: isPresenting) {
                            Image(systemName: "plus")
                        }
//                        Button(action: {
//                            viewStore.send(.createWorkoutButtonTapped)
//                            isPresenting = true
//                        }) {
//                        }
//                        .sheet(isPresented: $isPresenting) {
//                            IfLetStore(store.scope(state: \.createWorkoutState, action: QuickWorkoutsListAction.createWorkoutAction),
//                                       then: CreateQuickWorkoutView.init(store:))
//                        }
                    }
                }
                .navigationTitle("Workouts")
            }
        }
    }
}

private struct CreateWorkoutButton<Content: View>: View {

    var content: () -> Content
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    let viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State var isPresenting: Bool

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>,
         isPresenting: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content) {
        self.store = store
        self.$isPresenting = isPresenting
        self.content = content
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Button(action: {
            isPresenting = true
        }, label: content)
        .sheet(isPresented: $isPresenting) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
    }
}
