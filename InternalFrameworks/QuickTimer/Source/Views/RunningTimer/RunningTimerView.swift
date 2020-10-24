import SwiftUI
import ComposableArchitecture
import WorkoutCore
import CorePersistence

struct RunningTimerView: View {
    let store: Store<RunningTimerState, RunningTimerAction>

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    public init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.isInPreCountdown {
                    PreCountdownView(viewStore: viewStore)
                } else {
                    VStack(spacing: 28) {
                        HeaderView(store: store)

                        SegmentedProgressView(totalSegments: viewStore.timerSections.count / 2,
                                              filledSegments: viewStore.finishedSections,
                                              title: "Sections",
                                              color: viewStore.color)
                            .padding(.top, 28)

                        Spacer()

                        TimerView(viewStore: viewStore)

                        Spacer()

                        QuickTimerControlsView(store: self.store.scope(state: \.timerControlsState, action: RunningTimerAction.timerControlsUpdatedState), tint: viewStore.color)

                    }
                    .onChange(of: viewStore.isPresented) { isPresented in
                        if !isPresented {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .padding(28)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct RunningTimerView_Previews: PreviewProvider {
    static var previews: some View {
        let runningStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1,
                currentSection: TimerSection(duration: 45, type: .work),
                timerControlsState: QuickTimerControlsState(timerState: .running),
                isInPreCountdown: false
            ),
            reducer: runningTimerReducer,
            environment: RunningTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                 soundClient: .mock
            )
        )
        let preCountdownStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1,
                isInPreCountdown: true
            ),
            reducer: runningTimerReducer,
            environment: RunningTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                 soundClient: .mock
            )
        )

        return Group {
            RunningTimerView(store: preCountdownStore)
                .previewDevice(.iPhone11)

            RunningTimerView(store: runningStore)
                .previewDevice(.iPhone11)
                .preferredColorScheme(.dark)
        }
    }
}

private struct PreCountdownView: View {
    let viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    var body: some View {
        ZStack {
            Spacer()
            RoundedRectangle(cornerRadius: 25)
                .frame(width: 125, height: 125)
                .foregroundColor(viewStore.color)

            Text("\(viewStore.preCountdownTimeLeft.clean)")
                .foregroundColor(.appWhite)
                .font(.system(size: 72, weight: .heavy))
                .transition(.scale)
            Spacer()
        }
    }
}

private struct HeaderView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    let viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        HStack(spacing: 18) {
            Button(action: {
                viewStore.send(.alertButtonTapped)
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 18, height: 18)
                    .padding(10)
                    .foregroundColor(.appText)
            })
            .alert(
              self.store.scope(state: { $0.alert }),
              dismiss: .alertDismissed
            )
            .background(Color.appCardBackground)
            .cornerRadius(12)

            Text(viewStore.workout.name)
                .font(.h3)
                .foregroundColor(.appText)

            Spacer()

            Text(viewStore.totalTimeLeft.formattedTimeLeft)
                .foregroundColor(.appText)
                .font(.h1)
        }
    }
}

private struct TimerView: View {
    let viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    var body: some View {
        VStack(spacing: 8) {
            Text("Scored Time")
                .foregroundColor(.appGrey)
                .font(.display)

            Text(viewStore.sectionTimeLeft.formattedTimeLeft)
                .foregroundColor(.appText)
                .font(.gigantic)

            Text(viewStore.currentSegmentName)
                .foregroundColor(.appText)
                .font(.h2)
        }
    }
}

private extension RunningTimerState {
    var currentSegmentName: String {
        currentSection?.type == .work ? "Work out" : "Rest"
    }

    var color: Color {
        Color(hue: workout.color.hue, saturation: workout.color.saturation, brightness: workout.color.brightness)
    }
}

private extension TimeInterval {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
