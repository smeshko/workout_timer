import SwiftUI
import Settings
import ComposableArchitecture
import QuickWorkoutForm
import RunningTimer

public struct QuickWorkoutsListView: View {

    private let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State private var isWorkoutFormPresented: Bool = false
    @State private var isSettingsPresented = false
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
                NoWorkoutsView(store: store, isWorkoutFormPresented: $isWorkoutFormPresented)
            } else {
                if viewStore.isPresentingTimer {
                    IfLetStore(store.scope(state: \.runningTimerState, action: QuickWorkoutsListAction.runningTimerAction),
                               then: { RunningTimerView(store: $0, origin: origin) })

                } else {
                    WorkoutsList(store: store, isWorkoutFormPresented: $isWorkoutFormPresented, origin: $origin)
                        .toolbar {
                            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                                SettingsButton(isPresented: $isSettingsPresented)
                            }
                            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                                FormButton(isPresented: $isWorkoutFormPresented, store: store)
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
    @Binding var isPresented: Bool

    var body: some View {
        Button(action: {
            isPresented = true
        }, label: {
            Image(systemName: "gear")
        })
        .sheet(isPresented: $isPresented) {
            SettingsView(
                store: Store<SettingsState, SettingsAction>(
                    initialState: SettingsState(),
                    reducer: settingsReducer,
                    environment: SettingsEnvironment(client: .live)
                )
            )
        }
    }
}

private struct FormButton: View {
    @Binding var isPresented: Bool
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    var body: some View {
        Button(action: {
            isPresented = true
        }, label: {
            Image(systemName: "plus.circle")
        })
        .sheet(isPresented: $isPresented) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
    }
}
