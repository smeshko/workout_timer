import SwiftUI
import DomainEntities
import ComposableArchitecture
import QuickWorkoutForm
import CoreInterface
import RunningTimer

public struct QuickWorkoutsListView: View {

    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State var isWorkoutFormPresented: Bool = false
    @State var isRunningTimerPresented: (Bool, Store<RunningTimerState, RunningTimerAction>?) = (false, nil)

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            if viewStore.workoutStates.isEmpty && viewStore.loadingState.isFinished {
                NoWorkoutsView(store: store, isWorkoutFormPresented: $isWorkoutFormPresented)
            } else {
                WorkoutsList(store: store, isWorkoutFormPresented: $isWorkoutFormPresented, isRunningTimerPresented: $isRunningTimerPresented)
                    .toolbar {
                        HStack(spacing: 12) {
                            Button(action: {
                                isWorkoutFormPresented = true
                            }, label: {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 28))
                            })
                        }
                    }
            }
        }
        .sheet(isPresented: $isWorkoutFormPresented) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
        .fullScreenCover(isPresented: $isRunningTimerPresented.0) {
            RunningTimerView(store: isRunningTimerPresented.1!)
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

    @Binding var isWorkoutFormPresented: Bool

    var body: some View {
        VStack(spacing: 18) {
            Button(action: {
                isWorkoutFormPresented = true
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
            Text("Create your first workout")
                .font(.h2)
                .foregroundColor(.appText)
        }
        .sheet(isPresented: $isWorkoutFormPresented) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
    }
}

private struct WorkoutsList: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    let viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @Binding var isWorkoutFormPresented: Bool
    @Binding var isRunningTimerPresented: (Bool, Store<RunningTimerState, RunningTimerAction>?)
    @State var cellSize: CGSize = .zero

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>,
         isWorkoutFormPresented: Binding<Bool>,
         isRunningTimerPresented: Binding<(Bool, Store<RunningTimerState, RunningTimerAction>?)>
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        self._isWorkoutFormPresented = isWorkoutFormPresented
        self._isRunningTimerPresented = isRunningTimerPresented
    }

    var body: some View {
        List(store.scope(state: { $0.workoutStates },
                         action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
            ContextMenuView {
                QuickWorkoutCardView(store: cardViewStore)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .settingSize($cellSize)
            } previewProvider: {
                WorkoutPreview(store: cardViewStore)
            }
            .actionProvider {
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    viewStore.send(.deleteWorkout(ViewStore(cardViewStore).workout))
                }

                let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                    viewStore.send(.editWorkout(ViewStore(cardViewStore).workout))
                    isWorkoutFormPresented = true
                }

                let start = UIAction(title: "Start", image: UIImage(systemName: "play.fill")) { action in
                    ViewStore(cardViewStore).send(.tapStart)
                    isRunningTimerPresented = (
                        true,
                        cardViewStore.scope(state: \.runningTimerState, action: QuickWorkoutCardAction.runningTimerAction)
                    )
                }

                let deleteMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [deleteAction])

                return UIMenu(title: "", children: [start, edit, deleteMenu])
            }
            .onPreviewTap {
                viewStore.send(.editWorkout(ViewStore(cardViewStore).workout))
                isWorkoutFormPresented = true
            }
            .frame(height: cellSize.height)
        }
        .onDelete { insets in
            withAnimation {
                viewStore.send(QuickWorkoutsListAction.deleteWorkouts(insets))
            }
        }
        .sheet(isPresented: $isWorkoutFormPresented) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Workouts")
    }
}

private extension View {
    func settingSize(_ binding: Binding<CGSize>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { binding.wrappedValue = proxy.size }
            })
    }
}
