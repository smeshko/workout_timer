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

    @State private var isShowingTimer = false

    @State private var phase = Phase.countdown

    public init(store: Store<RunningTimerState, RunningTimerAction>, origin: CGPoint) {
        self.store = store
        self.origin = origin
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            switch phase {
            case .timer:
                MainView(store: store)
                    .animation(.none)
            case .countdown:
                IfLetStore(store.scope(state: \.precountdownState, action: RunningTimerAction.preCountdownAction),
                           then: { PreCountdownView(store: $0, origin: origin) })
            case .finished:
                IfLetStore(store.scope(state: \.finishedWorkoutState, action: RunningTimerAction.finishedWorkoutAction),
                           then: FinishedWorkoutView.init)
            }
        }
        .animation(.default)
        .onChange(of: viewStore.phase, perform: { value in
            withAnimation {
                phase = value
            }
        })
        .padding(28)
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
                timerControlsState: TimerControlsState(timerState: .running)
            ),
            reducer: runningTimerReducer,
            environment: RunningTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                 soundClient: .mock,
                                                 notificationClient: .mock
            )
        )
        let preCountdownStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1
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

private struct MainView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
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

            if viewStore.isCompact {}
        }
        .animation(.default)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onChange(of: viewStore.finishedSections) { change in
            viewStore.send(.segmentedProgressAction(.moveToNextSegment))
        }
//        .onChange(of: horizontalSizeClass) { sizeClass in
//            viewStore.send(.onSizeClassChange(isCompact: sizeClass == .compact))
//        }
    }
}

extension RunningTimerState {
    var color: Color {
        Color(hue: workout.color.hue, saturation: workout.color.saturation, brightness: workout.color.brightness)
    }
}
