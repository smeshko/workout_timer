import SwiftUI
import CoreInterface
import ComposableArchitecture

#if os(watchOS)
struct MainView: View {

    fileprivate struct State: Equatable {
        var workoutColor: Color
        var isFinished = false
        var isPaused = false
        var currentSection: TimerSection?
    }

    let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject fileprivate var viewStore: ViewStore<MainView.State, RunningTimerAction>

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: \.runningView))
    }

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            HeaderView(store: store.scope(state: \.headerState, action: RunningTimerAction.headerAction))

            if !viewStore.isFinished {
                SegmentedProgressView(
                    store: store.scope(state: \.segmentedProgressState, action: RunningTimerAction.segmentedProgressAction),
                    color: viewStore.workoutColor
                )
                .padding(.top, Spacing.xxl)
            }

            Spacer()

            IfLetStore(store.scope(state: \.finishedWorkoutState, action: RunningTimerAction.finishedWorkoutAction),
                       then: FinishedWorkoutView.init,
                       else: TimerView(store: store)
            )

            Spacer()

            if !viewStore.isFinished {
                QuickTimerControlsView(store: store.scope(state: \.timerControlsState,
                                                          action: RunningTimerAction.timerControlsUpdatedState), tint: viewStore.workoutColor)
            }
        }
        .onChange(of: viewStore.currentSection) { value in
            guard let section = value else { return }
            viewStore.send(.segmentedProgressAction(.onTimerSectionFinished(section)))
        }
        .onTapGesture(perform: toggleState)
    }

    private func toggleState() {
        if viewStore.isPaused {
            viewStore.send(.timerControlsUpdatedState(.start))
        } else {
            viewStore.send(.timerControlsUpdatedState(.pause))
        }
    }
}

private extension RunningTimerState {
    var runningView: MainView.State {
        MainView.State(
            workoutColor: workout.color.color,
            isFinished: timerControlsState.isFinished,
            isPaused: timerControlsState.isPaused,
            currentSection: currentSection
        )
    }
}
#endif
