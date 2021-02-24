import SwiftUI
import WorkoutSettings
import ComposableArchitecture
import QuickWorkoutForm
import RunningTimer
import CoreLogic

public struct QuickWorkoutsListView: View {

    fileprivate struct State: Equatable {
        var loadingState: LoadingState
        var noWorkouts = false
        var isPresentingTimer = false
    }

    private let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store.scope(state: \.view)) { viewStore in
            NavigationView {
                if viewStore.loadingState.isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                } else if viewStore.noWorkouts && viewStore.loadingState.isFinished {
                    NoWorkoutsView(store: store)
                } else {
                    if viewStore.isPresentingTimer {
                        IfLetStore(store.scope(state: \.runningTimerState, action: QuickWorkoutsListAction.runningTimerAction),
                                   then: { RunningTimerView(store: $0) })

                    } else {
                        WorkoutsList(store: store)
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
    @ObservedObject private var viewStore: ViewStore<Bool, QuickWorkoutsListAction>

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: \.isPresentingSettings))
    }

    var body: some View {
        Button(action: {
            viewStore.send(.settings(.present))
        }, label: {
            Image(systemName: "gear")
        })
        .sheet(isPresented: viewStore.binding(get: { $0 }),
               onDismiss: {
                viewStore.send(.settings(.dismiss))
               }) {
            SettingsView(store: store.scope(state: \.settingsState, action: QuickWorkoutsListAction.settingsAction))
        }
    }
}

private struct FormButton: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<Bool, QuickWorkoutsListAction>

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: \.isPresentingTimerForm))
    }

    var body: some View {
        Button(action: {
            viewStore.send(.timerForm(.present))
        }, label: {
            Image(systemName: "plus.circle")
        })
        .sheet(isPresented: viewStore.binding(get: { $0 }),
               onDismiss: {
                viewStore.send(.timerForm(.dismiss))
                ViewStore(store).send(.createWorkoutAction(.cancel))
               }) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
    }
}

private extension QuickWorkoutsListState {
    var view: QuickWorkoutsListView.State {
        QuickWorkoutsListView.State(
            loadingState: loadingState,
            noWorkouts: workoutStates.isEmpty,
            isPresentingTimer: isPresentingTimer
        )
    }
}
