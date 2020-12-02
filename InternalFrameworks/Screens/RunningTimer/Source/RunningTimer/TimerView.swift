import SwiftUI
import CoreInterface
import ComposableArchitecture
import DomainEntities

struct TimerView: View {
    private let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    private var isFinished: Bool {
        viewStore.timerControlsState.isFinished
    }

    private func toggleState() {
        if viewStore.timerControlsState.isPaused {
            viewStore.send(.timerControlsUpdatedState(.start))
        } else {
            viewStore.send(.timerControlsUpdatedState(.pause))
        }
    }

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            ProgressBar(elapsed: (viewStore.currentSection?.duration ?? 0) - viewStore.sectionTimeLeft,
                        total: (viewStore.currentSection?.duration ?? 0),
                        tint: progressColor)

            VStack(spacing: Spacing.xs) {
                Text(viewStore.sectionTimeLeft.formattedTimeLeft)
                    .foregroundColor(.appText)
                    .font(.giganticMono)

                Text(viewStore.currentSegmentName)
                    .foregroundColor(.appText)
                    .font(.h1)
            }
            .pulsatingAnimation(viewStore.timerControlsState.isPaused)
        }
        .onTapGesture(perform: toggleState)
        .animation(.none)
    }

    private var progressColor: WorkoutColor {
        if viewStore.currentSection?.type == .pause {
            return WorkoutColor(color: .green)
        } else {
            return viewStore.workout.color
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(
            store: Store<RunningTimerState, RunningTimerAction>(
                initialState: RunningTimerState(
                    workout: mockQuickWorkout1,
                    timerControlsState: TimerControlsState(timerState: .paused)
                ),
                reducer: runningTimerReducer,
                environment: .preview
            )
        )
        .padding()
    }
}

private struct ProgressBar: View {
    var elapsed: TimeInterval
    var total: TimeInterval
    let tint: WorkoutColor

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 16)
                .foregroundColor(Color(.systemBackground))
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(tint.color ,style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }

    private var progress: CGFloat {
        CGFloat(elapsed) / CGFloat(total)
    }
}

private extension RunningTimerState {
    var currentSegmentName: String {
        currentSection?.name ?? ""
    }
}

private extension View {
    func pulsatingAnimation(_ animate: Bool) -> some View {
        self
            .opacity(animate ? 0.25 : 1)
            .animation(
                animate ?
                    Animation.easeInOut(duration: 1).repeatForever() :
                    .none
            )
    }
}
