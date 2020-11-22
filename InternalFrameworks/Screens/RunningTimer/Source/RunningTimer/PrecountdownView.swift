import SwiftUI
import ComposableArchitecture

struct PreCountdownView: View {
    private let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject private var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

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
struct PrecountdownView_Previews: PreviewProvider {
    static var previews: some View {
        PreCountdownView(
            store: Store<RunningTimerState, RunningTimerAction>(
                initialState: RunningTimerState(workout: mockQuickWorkout1),
                reducer: runningTimerReducer,
                environment: RunningTimerEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    soundClient: .mock,
                    notificationClient: .mock
                )
            ),
            origin: .zero
        )
    }
}

private extension TimeInterval {
    var clean: String {
        guard self >= 0 else { return String(format: "%.0f", 0) }
        return String(format: "%.0f", self)
    }
}
