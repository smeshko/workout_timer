import SwiftUI
import ComposableArchitecture

struct PausedView: View {
    private let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

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

struct PausedView_Previews: PreviewProvider {
    static var previews: some View {
        PausedView(
            store: Store<RunningTimerState, RunningTimerAction>(
                initialState: RunningTimerState(workout: mockQuickWorkout1),
                reducer: runningTimerReducer,
                environment: RunningTimerEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    soundClient: .mock,
                    notificationClient: .mock
                )
            )
        )
    }
}
