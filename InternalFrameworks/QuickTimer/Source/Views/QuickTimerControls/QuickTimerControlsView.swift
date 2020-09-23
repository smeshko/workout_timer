import SwiftUI
import ComposableArchitecture
import WorkoutCore

struct QuickTimerControlsView: View {
    let store: Store<QuickTimerControlsState, QuickTimerControlsAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 18) {
                if viewStore.timerState.isPaused {
                    ControlButton(action: {
                        viewStore.send(.start)
                    }, image: "play")
                } else {
                    ControlButton(action: {
                        viewStore.send(.pause)
                    }, image: "pause")
                }

                ControlButton(action: {
                    viewStore.send(.stop)
                }, image: "stop")
            }
        }
    }
}

struct TimerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTimerControlsView(
            store: Store<QuickTimerControlsState, QuickTimerControlsAction>(
                initialState: QuickTimerControlsState(timerState: .paused),
                reducer: quickTimerControlsReducer,
                environment: QuickTimerControlsEnvironment()
            )
        )
    }
}

private struct ControlButton: View {

    let action: () -> Void
    let image: String

    var body: some View {
        Button(action: action, label: {
            Image(systemName: image)
                .frame(width: 18, height: 18)
                .padding(15)
                .foregroundColor(.appWhite)
        })
        .background(Color.appGrey)
        .cornerRadius(12)
    }
}
