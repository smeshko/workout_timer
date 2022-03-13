import SwiftUI
import SettingsFeature
import ComposableArchitecture
import NewTimerFeature
import RunningTimerFeature
import CoreLogic

public struct TimersListView: View {

    fileprivate struct State: Equatable {
        var loadingState: LoadingState
        var noWorkouts = false
        var isPresentingTimer = false
    }

    private let store: Store<TimersListState, TimersListAction>

    public init(store: Store<TimersListState, TimersListAction>) {
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
                    TimersList(store: store)
                        .toolbar {
                            ToolbarItem(placement: placement(isLeading: true)) {
                                SettingsButton(store: store)
                            }
                            ToolbarItem(placement: placement(isLeading: false)) {
                                FormButton(store: store)
                            }
                        }
                        .navigationTitle("workouts".localized)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .fullScreenCover(isPresented: viewStore.binding(get: \.isPresentingTimer)) {
                IfLetStore(store.scope(state: \.timerViewState, action: TimersListAction.timerViewAction),
                           then: TimerView.init(store:))
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private func placement(isLeading: Bool) -> ToolbarItemPlacement {
        #if os(watchOS)
        return .automatic
        #else
        return isLeading ? .navigationBarLeading : .navigationBarTrailing
        #endif
    }
}

private struct SettingsButton: View {
    let store: Store<TimersListState, TimersListAction>
    @ObservedObject private var viewStore: ViewStore<Bool, TimersListAction>

    init(store: Store<TimersListState, TimersListAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: \.isPresentingSettings))
    }

    var body: some View {
        Button(action: {
            viewStore.send(.onSettingsPresentationChange(true))
        }, label: {
            Image(systemName: "gear")
        })
        .sheet(isPresented: viewStore.binding(get: { $0 }), onDismiss: { viewStore.send(.onSettingsPresentationChange(false)) }) {
            SettingsView(store: store.scope(state: \.settingsState, action: TimersListAction.settingsAction))
        }
    }
}

private struct FormButton: View {
    let store: Store<TimersListState, TimersListAction>
    @ObservedObject private var viewStore: ViewStore<Bool, TimersListAction>

    init(store: Store<TimersListState, TimersListAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: \.isPresentingTimerForm))
    }

    var body: some View {
        Button(action: {
            viewStore.send(.onTimerFormPresentationChange(true))
        }, label: {
            Image(systemName: "plus.circle")
        })
        .sheet(isPresented: viewStore.binding(get: { $0 })) {
            IfLetStore(
                store.scope(state: \.newTimerFormState, action: TimersListAction.newTimerFormAction)) { store in
                    NewTimerForm(store: store)
                        .interactiveDismissDisabled()
                }
        }
    }
}

private extension TimersListState {
    var view: TimersListView.State {
        TimersListView.State(
            loadingState: loadingState,
            noWorkouts: workouts.isEmpty,
            isPresentingTimer: isPresentingTimer
        )
    }
}

//struct QuickWorkoutsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        let emptyStore = Store<TimersListState, TimersListAction>(
//            initialState: TimersListState(),
//            reducer: timersListReducer,
//            environment: .preview
//        )
//
//        let filledStore = Store<TimersListState, TimersListAction>(
//            initialState: TimersListState(workouts: [mockQuickWorkout1, mockQuickWorkout2]),
//            reducer: timersListReducer,
//            environment: .preview
//        )
//
//        return Group {
//            TimersListView(store: emptyStore)
//                .previewDevice(.iPhone11)
//                .preferredColorScheme(.dark)
//
//            TimersListView(store: filledStore)
//                .previewDevice(.iPhone11)
//
//            TimersListView(store: filledStore)
//                .previewDevice(.watch6)
//
//        }
//    }
//}
