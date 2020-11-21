import SwiftUI
import ComposableArchitecture
import CoreInterface
import CorePersistence

public struct RunningTimerView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    let viewStore: ViewStore<RunningTimerState, RunningTimerAction>
    let origin: CGPoint

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
                    .padding(.top, 28)

                    Spacer()

                    if viewStore.timerControlsState.isPaused {
                        PausedView(store: store)
                    } else {
                        TimerView(store: store)
                    }

                    Spacer()

                    QuickTimerControlsView(store: store.scope(state: \.timerControlsState,
                                                              action: RunningTimerAction.timerControlsUpdatedState), tint: viewStore.color)

                    NavigationLink(
                        destination: IfLetStore(store.scope(state: \.finishedWorkoutState, action: RunningTimerAction.finishedWorkoutAction),
                                                then: FinishedWorkoutView.init),
                        isActive: viewStore.binding(get: \.timerControlsState.timerState.isFinished, send: RunningTimerAction.onPush),
                        label: { EmptyView() }
                    )

                }
                .onChange(of: viewStore.finishedSections) { change in
                    viewStore.send(.segmentedProgressAction(.moveToNextSegment))
                }
                .onChange(of: viewStore.isPresented) { isPresented in
                    if !isPresented {
                        presentationMode.wrappedValue.dismiss()
                    }
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

private struct PreCountdownView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    let viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    let proxy = UIScreen.main.bounds
    let origin: CGPoint

    @State var startAnimation = false

    init(store: Store<RunningTimerState, RunningTimerAction>, origin: CGPoint) {
        self.store = store
        self.origin = origin
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            Text("\(viewStore.preCountdownTimeLeft.clean)")
                .opacity(startAnimation ? 1 : 0)
                .foregroundColor(.white)
                .font(.system(size: 72, weight: .heavy, design: .monospaced))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .transition(
            AnyTransition.asymmetric(
                insertion: AnyTransition
                    .scale(scale: 0, anchor: .init(x: origin.x / proxy.size.width, y: origin.y / proxy.size.height)),
                removal: AnyTransition
                    .scale(scale: 0, anchor: .center)
            )
        )
        .background(
            Circle()
                .scale(startAnimation ? 5 : 0)
                .foregroundColor(viewStore.color)
        )
        .onAppear {
            startAnimation = true
        }
        .onDisappear {
            startAnimation = false
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

private struct PausedView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    let viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Text("Pause")
            .foregroundColor(.appText)
            .font(.system(size: 72, weight: .heavy))
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
                .font(.h1Mono)
        }
    }
}

private struct TimerView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    let viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Scored Time")
                .foregroundColor(.appGrey)
                .font(.display)

            Text(viewStore.sectionTimeLeft.formattedTimeLeft)
                .foregroundColor(.appText)
                .font(.giganticMono)

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
