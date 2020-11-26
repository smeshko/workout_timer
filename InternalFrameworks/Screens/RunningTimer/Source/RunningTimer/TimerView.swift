import SwiftUI
import ComposableArchitecture

struct TimerView: View {
    private let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            ProgressTrack(tint: progressColor)
            ProgressBar(elapsed: (viewStore.currentSection?.duration ?? 0) - viewStore.sectionTimeLeft,
                        total: (viewStore.currentSection?.duration ?? 0))

            VStack(spacing: 8) {
                Text(viewStore.sectionTimeLeft.formattedTimeLeft)
                    .foregroundColor(.appText)
                    .font(.giganticMono)

                Text(viewStore.currentSegmentName)
                    .foregroundColor(.appText)
                    .font(.h2)
            }
            .pulsatingAnimation(viewStore.timerControlsState.isPaused)
        }
    }

    private var progressColor: Color {
        if viewStore.currentSection?.type == .pause {
            return .green
        } else {
            return viewStore.workout.color.color
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
    }
}

private struct ProgressTrack: View {
    let tint: Color

    var body: some View {
        Circle()
            .fill(Color.clear)
            .overlay(
                Circle().stroke(tint, lineWidth: 15)
        )
    }
}

private struct ProgressBar: View {
    var elapsed: TimeInterval
    var total: TimeInterval

    var body: some View {
        Circle()
            .fill(Color.clear)
            .overlay(
                Circle().trim(from: 0, to: progress)
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 16,
                            lineCap: .square,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(Color(.systemBackground))
                ).animation(
                    .easeInOut(duration: 0.2)
                )
    }

    var progress: CGFloat {
        CGFloat(elapsed) / CGFloat(total)
    }
}

private extension RunningTimerState {
    var currentSegmentName: String {
        currentSection?.type == .work ? "Work out" : "Rest"
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
