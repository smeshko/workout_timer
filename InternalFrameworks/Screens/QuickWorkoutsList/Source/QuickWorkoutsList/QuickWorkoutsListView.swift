import SwiftUI
import ComposableArchitecture
import QuickWorkoutForm
import RunningTimer

public struct QuickWorkoutsListView: View {

    private let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State private var isWorkoutFormPresented: Bool = false
    @State private var origin: CGPoint = .zero

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            ZStack {
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
                            .animation(.none)
                    }
                }
            }
            .animation(Animation.easeInOut(duration: 0.55))
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
