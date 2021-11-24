import SwiftUI
import CoreInterface
import DomainEntities
import ComposableArchitecture

public struct TimerView2: View {
    let color = WorkoutColor(color: TintColor.allTints[(0...8).randomElement()!].color)

    @ObservedObject var viewStore: ViewStore<TimerViewState, TimerViewAction>

    public init(store: Store<TimerViewState, TimerViewAction>) {
        self.viewStore = ViewStore(store)
    }

    public init() {
        self.viewStore = ViewStore(
            Store<TimerViewState, TimerViewAction>(
                initialState: TimerViewState(
                    workout: QuickWorkout(
                        id: UUID(),
                        name: "Some Workout",
                        color: WorkoutColor(color: .green),
                        segments: [
                            QuickWorkoutSegment(
                                id: UUID(),
                                name: "JumpRope",
                                sets: 2,
                                work: 10,
                                pause: 5
                            )
                        ]
                    )
                ),
                reducer: timerViewReducer,
                environment: .live
            )
        )
    }

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .foregroundColor(.appDark)
                }
            }

            Spacer()

            VStack {
                Text(viewStore.totalTimeLeft.formattedTimeLeft)
                    .font(.h2)

                Text("Remaining")
                    .font(.h3)
                    .foregroundColor(.appWhite)
            }

            ProgressView(
                "Pause",
                value: (viewStore.currentSection?.timeLeft ?? 0),
                total: (viewStore.currentSection?.duration ?? 0)
            )
                .progressViewStyle(CustomCircularProgressViewStyle(isRunning: viewStore.isRunning, tint: .white))
                .onTapGesture {
                    viewStore.send(viewStore.isRunning ? .pause : .resume)
                }

            Group {

                Spacer()

                Text(viewStore.currentSection?.timeLeft.formattedTimeLeft ?? "")
                    .font(.giganticMono)

                Text(viewStore.currentSection?.name ?? "")
                    .font(.h1)

                Spacer()

                VStack {
                    Text("\(viewStore.finishedSections)/\(viewStore.timerSections.count)")
                        .font(.h2)
                    Text("Intervals")
                        .font(.h3)
                        .foregroundColor(.appWhite)
                }
            }
            // Progress bar

            ProgressView(value: viewStore.totalTimeExpired, total: viewStore.timerSections.totalDuration)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: 4)
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color.monochromatic, color.color]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private extension WorkoutColor {
    var monochromatic: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness + 0.3)
    }
}

struct CustomCircularProgressViewStyle: ProgressViewStyle {
    let isRunning: Bool
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(tint, style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(270))

            if isRunning {
                Text("Pause")
                    .font(.h1)
            } else {
                Text("Resume")
                    .font(.h1)
            }
        }
        .contentShape(Circle())
    }
}
