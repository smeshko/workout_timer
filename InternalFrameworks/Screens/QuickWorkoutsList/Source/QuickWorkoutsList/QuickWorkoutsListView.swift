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
    @State var origin: CGPoint = .zero

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            if viewStore.workoutStates.isEmpty && viewStore.loadingState.isFinished {
                NoWorkoutsView(store: store, isWorkoutFormPresented: $isWorkoutFormPresented)
            } else {
                if viewStore.isPresentingTimer {
                    IfLetStore(store.scope(state: \.runningTimerState, action: QuickWorkoutsListAction.runningTimerAction),
                               then: { RunningTimerView(store: $0, origin: origin).zIndex(1) })
                } else {
                    WorkoutsList(store: store, isWorkoutFormPresented: $isWorkoutFormPresented, origin: $origin)
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
        }
        .sheet(isPresented: $isWorkoutFormPresented) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .overlay(
            viewStore.loadingState.isLoading ?
            ProgressView().progressViewStyle(CircularProgressViewStyle()) :
            nil
        )
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

    @Binding private var isWorkoutFormPresented: Bool
    @Binding private var origin: CGPoint

    @State private var cellSize: CGSize = .zero

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>,
         isWorkoutFormPresented: Binding<Bool>,
         origin: Binding<CGPoint>
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        self._isWorkoutFormPresented = isWorkoutFormPresented
        self._origin = origin
    }

    var body: some View {
        List(store.scope(state: { $0.workoutStates },
                         action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
            ContextMenuView {
                QuickWorkoutCardView(store: cardViewStore, origin: $origin)
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
