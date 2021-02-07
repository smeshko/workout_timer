import SwiftUI
import WorkoutSettings
import ComposableArchitecture
import QuickWorkoutForm
import RunningTimer

public struct QuickWorkoutsListView: View {

    private let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State private var origin: CGPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            if viewStore.loadingState.isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            } else if viewStore.workoutStates.isEmpty && viewStore.loadingState.isFinished {
                NoWorkoutsView(store: store)
            } else {
                if viewStore.isPresentingTimer {
                    IfLetStore(store.scope(state: \.runningTimerState, action: QuickWorkoutsListAction.runningTimerAction),
                               then: { RunningTimerView(store: $0, origin: origin) })

                } else {
                    WorkoutsList(store: store, origin: $origin)
                        .toolbar {
                            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                                SettingsButton(store: store)
                            }
                            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                                FormButton(store: store)
                            }
                        }
                }
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct QuickWorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyStore = Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
            initialState: QuickWorkoutsListState(),
            reducer: quickWorkoutsListReducer,
            environment: .preview
        )

        let filledStore = Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
            initialState: QuickWorkoutsListState(workouts: [mockQuickWorkout1, mockQuickWorkout2]),
            reducer: quickWorkoutsListReducer,
            environment: .preview
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

private struct SettingsButton: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Button(action: {
            viewStore.send(.settings(.present))
        }, label: {
            Image(systemName: "gear")
        })
        .sheet(isPresented: viewStore.binding(get: \.isPresentingSettings),
               onDismiss: {
                viewStore.send(.settings(.dismiss))

               }) {
            SettingsView(store: store.scope(state: \.settingsState, action: QuickWorkoutsListAction.settingsAction))
        }
    }
}

private struct FormButton: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Button(action: {
            viewStore.send(.timerForm(.present))
        }, label: {
            Image(systemName: "plus.circle")
        })
        .sheet(isPresented: viewStore.binding(get: \.isPresentingTimerForm),
               onDismiss: {
                viewStore.send(.timerForm(.dismiss))
                ViewStore(store).send(.createWorkoutAction(.cancel))
               }) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
    }
}
