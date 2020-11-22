import SwiftUI
import ComposableArchitecture
import CoreInterface
import CorePersistence

public struct RunningTimerView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    let origin: CGPoint

    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.scenePhase) var scenePahse

    public init(store: Store<RunningTimerState, RunningTimerAction>, origin: CGPoint) {
        self.store = store
        self.origin = origin
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            if viewStore.isInPreCountdown {
                PreCountdownView(store: store, origin: origin)
            } else {
                VStack(spacing: 28) {
                    HeaderView(store: store)

                    SegmentedProgressView(
                        store: store.scope(state: \.segmentedProgressState, action: RunningTimerAction.segmentedProgressAction),
                        color: viewStore.color
                    )
                    .animation(.none)
                    .padding(.top, 28)

                    Spacer()

                    TimerView(store: store)

                    Spacer()

                    QuickTimerControlsView(store: store.scope(state: \.timerControlsState,
                                                              action: RunningTimerAction.timerControlsUpdatedState), tint: viewStore.color)

                    if viewStore.timerControlsState.timerState.isFinished {
                        NavigationLink(
                            destination: IfLetStore(store.scope(state: \.finishedWorkoutState, action: RunningTimerAction.finishedWorkoutAction),
                                                    then: FinishedWorkoutView.init),
                            isActive: .constant(true),
                            label: { EmptyView() }
                        )
                    }
                }
                .onChange(of: viewStore.finishedSections) { change in
                    viewStore.send(.segmentedProgressAction(.moveToNextSegment))
                }
                .onChange(of: horizontalSizeClass) { sizeClass in
                    viewStore.send(.onSizeClassChange(isCompact: sizeClass == .compact))
                }
            }
        }
        .animation(Animation.easeInOut(duration: 0.6))
        .padding(28)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onChange(of: scenePahse) { newScene in
            switch newScene {
            case .active:
                viewStore.send(.onActive)
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
                timerControlsState: TimerControlsState(timerState: .running),
                isInPreCountdown: false
            ),
            reducer: runningTimerReducer,
            environment: RunningTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                 soundClient: .mock,
                                                 notificationClient: .mock
            )
        )
        let preCountdownStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1,
                isInPreCountdown: true
            ),
            reducer: runningTimerReducer,
            environment: RunningTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                 soundClient: .mock,
                                                 notificationClient: .mock
            )
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

extension RunningTimerState {
    var color: Color {
        Color(hue: workout.color.hue, saturation: workout.color.saturation, brightness: workout.color.brightness)
    }
}
