import SwiftUI
import ComposableArchitecture
import CoreInterface

struct QuickTimerControlsView: View {
    let store: Store<QuickTimerControlsState, QuickTimerControlsAction>
    let tint: Color

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 18) {
                if viewStore.timerState.isPaused {
                    ControlButton(action: {
                        viewStore.send(.start)
                    }, image: "play", tint: tint)
                } else {
                    ControlButton(action: {
                        viewStore.send(.pause)
                    }, image: "pause", tint: tint)
                }
            }
        }
    }
}

struct TimerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        let pausedStore = Store<QuickTimerControlsState, QuickTimerControlsAction>(
            initialState: QuickTimerControlsState(timerState: .paused),
            reducer: quickTimerControlsReducer,
            environment: QuickTimerControlsEnvironment()
        )

        let runningStore = Store<QuickTimerControlsState, QuickTimerControlsAction>(
            initialState: QuickTimerControlsState(timerState: .running),
            reducer: quickTimerControlsReducer,
            environment: QuickTimerControlsEnvironment()
        )

        return Group {
            QuickTimerControlsView(store: pausedStore, tint: .appSuccess)
                .padding()
                .previewLayout(.sizeThatFits)

            QuickTimerControlsView(store: runningStore, tint: .appSuccess)
                .preferredColorScheme(.dark)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}

private struct ControlButton: View {

    let action: () -> Void
    let image: String
    let tint: Color

    var body: some View {
        Button(action: action, label: {
            Image(systemName: image)
                .frame(width: 40, height: 40)
                .padding(15)
                .foregroundColor(.appWhite)
                .font(.h1)
        })
        .background(tint)
        .cornerRadius(12)
    }
}