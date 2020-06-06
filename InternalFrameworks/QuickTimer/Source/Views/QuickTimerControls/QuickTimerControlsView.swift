import SwiftUI
import ComposableArchitecture

struct QuickTimerControlsView: View {
    let store: Store<QuickTimerControlsState, QuickTimerControlsAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 32) {
                if viewStore.isRunning {
                    Button("Pause", action: { viewStore.send(.pause) })
                    Button("Finish", action: { viewStore.send(.stop) })
                } else {
                    Button("Start", action: { viewStore.send(.start) })
                }
            }
            .font(.system(size: 22))
        }
    }
}

struct TimerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTimerControlsView(
            store: Store<QuickTimerControlsState, QuickTimerControlsAction>(
                initialState: QuickTimerControlsState(),
                reducer: quickTimerControlsReducer,
                environment: QuickTimerControlsEnvironment()
            )
        )
    }
}

private extension QuickTimerControlsState {
    var isRunning: Bool {
        timerState == .running
    }
}
