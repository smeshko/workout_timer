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
        .padding(Spacing.xxl)
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
                currentSection: TimerSection(id: UUID(), duration: 45, type: .work, name: "Jump rope"),
                precountdownState: nil,
                timerControlsState: TimerControlsState(timerState: .running)
            ),
            reducer: runningTimerReducer,
            environment: .preview
        )
        let preCountdownStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1,
                precountdownState: PreCountdownState(workoutColor: mockQuickWorkout1.color)
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

            RunningTimerView(store: runningStore, origin: .zero)
                .previewLayout(.landscape(.iPhone11))
        }
    }
}

private struct MainView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?

    private var isFinished: Bool {
        viewStore.timerControlsState.isFinished
    }

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {

        if verticalSizeClass == .compact {
            VStack(spacing: Spacing.xxl) {
                if !isFinished {
                    SegmentedProgressView(
                        store: store.scope(state: \.segmentedProgressState, action: RunningTimerAction.segmentedProgressAction),
                        color: viewStore.workout.color.color
                    )
                    .padding(.top, Spacing.xxl)
                }

                HStack {
                    HeaderView(store: store.scope(state: \.headerState, action: RunningTimerAction.headerAction))

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

            }
        } else {
            VStack(spacing: Spacing.xxl) {
                HeaderView(store: store.scope(state: \.headerState, action: RunningTimerAction.headerAction))

                if !isFinished {
                    SegmentedProgressView(
                        store: store.scope(state: \.segmentedProgressState, action: RunningTimerAction.segmentedProgressAction),
                        color: viewStore.workout.color.color
                    )
                    .padding(.top, Spacing.xxl)
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
            .onChange(of: viewStore.currentSection) { value in
                guard let section = value else { return }
                viewStore.send(.segmentedProgressAction(.onTimerSectionFinished(section)))
            }
            .onTapGesture(perform: toggleState)
        }
    }

    private func toggleState() {
        if viewStore.timerControlsState.isPaused {
            viewStore.send(.timerControlsUpdatedState(.start))
        } else {
            viewStore.send(.timerControlsUpdatedState(.pause))
        }
    }
}
