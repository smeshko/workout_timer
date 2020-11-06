import SwiftUI
import ComposableArchitecture
import QuickWorkoutForm

public struct QuickWorkoutsListView: View {

    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State var isPresenting: Bool = false
    @State var editMode: EditMode = .inactive

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            if viewStore.workoutStates.isEmpty && viewStore.loadingState.isFinished {
                NoWorkoutsView(store: store)
            } else {
                WorkoutsList(store: store, isPresenting: $isPresenting)
                    .environment(\.editMode, $editMode)
                    .toolbar {
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    editMode.toggle()
                                }
                            }, label: {
                                if editMode.isEditing {
                                    Text("Done")
                                } else {
                                    Image(systemName: "pencil.circle")
                                        .font(.system(size: 28))
                                }
                            })

                            Button(action: {
                                isPresenting = true
                            }, label: {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 28))
                            })
                            .disabled(editMode.isEditing)
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresenting) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
        .onAppear {
            viewStore.send(.onAppear)
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
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                notificationClient: .mock
            )
        )

        let filledStore = Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
            initialState: QuickWorkoutsListState(workouts: [mockQuickWorkout1, mockQuickWorkout2]),
            reducer: quickWorkoutsListReducer,
            environment: QuickWorkoutsListEnvironment(
                repository: .mock,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                notificationClient: .mock
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

    @Binding var isPresenting: Bool
    @Environment(\.editMode) var editMode

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>, isPresenting: Binding<Bool>) {
        self.store = store
        self.viewStore = ViewStore(store)
        self._isPresenting = isPresenting
    }

    var body: some View {
        List {
            ForEachStore(store.scope(state: { $0.workoutStates },
                                     action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
                QuickWorkoutCardView(store: cardViewStore)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .listRowInsets(EdgeInsets(top: -1, leading: -1, bottom: -1, trailing: -1))
                    .background(Color(.systemBackground))
                    .listRowBackground(Color(.clear))
            }
            .onDelete { insets in
                withAnimation {
                    viewStore.send(QuickWorkoutsListAction.deleteWorkouts(insets))
                    editMode?.animation().wrappedValue.toggle()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color.clear)
        .padding(.top, 28)
        .navigationTitle("Workouts")
    }
}

private extension EditMode {
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
