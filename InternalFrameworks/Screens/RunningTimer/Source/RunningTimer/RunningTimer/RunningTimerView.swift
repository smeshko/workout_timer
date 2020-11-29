import SwiftUI
import ComposableArchitecture
import CoreInterface
import CorePersistence

public struct RunningTimerView: View {

    let store: Store<RunningTimerState, RunningTimerAction>
    let origin: CGPoint

    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    @Environment(\.scenePhase) var scenePahse

    public init(store: Store<RunningTimerState, RunningTimerAction>, origin: CGPoint) {
        self.store = store
        self.origin = origin
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        IfLetStore(store.scope(state: \.precountdownState, action: RunningTimerAction.preCountdownAction),
                   then: { PreCountdownView(store: $0, origin: origin) },
                   else: MainView(store: store)
        )
        .padding(28)
        .onChange(of: scenePahse) { newScene in
            switch newScene {
            case .background:
                viewStore.send(.onBackground)
            default: break
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct RunningTimerView_Previews: PreviewProvider {
    static var previews: some View {
        let runningStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1,
                currentSection: TimerSection(id: UUID(), duration: 45, type: .work),
                timerControlsState: TimerControlsState(timerState: .running)
            ),
            reducer: runningTimerReducer,
            environment: .preview
        )
        let preCountdownStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1
            ),
            reducer: runningTimerReducer,
            environment: .preview
        )

        return Group {
            RunningTimerView(store: preCountdownStore, origin: .zero)
                .previewDevice(.iPhone11)

            RunningTimerView(store: runningStore, origin: .zero)
                .previewDevice(.iPhone11)
                .preferredColorScheme(.dark)
        }
    }
}

private struct MainView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    private var isFinished: Bool {
        viewStore.timerControlsState.isFinished
    }

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: 28) {
            HeaderView(store: store.scope(state: \.headerState, action: RunningTimerAction.headerAction))
                .transition(.slide)
                .animation(.default)

            if !isFinished {
                SegmentedProgressView(
                    store: store.scope(state: \.segmentedProgressState, action: RunningTimerAction.segmentedProgressAction),
                    color: viewStore.workout.color.color
                )
                .padding(.top, 28)
            }

            Spacer()

            IfLetStore(store.scope(state: \.finishedWorkoutState, action: RunningTimerAction.finishedWorkoutAction),
                       then: FinishedWorkoutView.init,
                       else: TimerView(store: store)
            )

            Spacer()

            if !isFinished {
                QuickTimerControlsView(store: store.scope(state: \.timerControlsState,
                                                          action: RunningTimerAction.timerControlsUpdatedState), tint: viewStore.workout.color.color)
            }
        }
        .onChange(of: viewStore.finishedSections) { change in
            viewStore.send(.segmentedProgressAction(.moveToNextSegment))
        }
    }
}
