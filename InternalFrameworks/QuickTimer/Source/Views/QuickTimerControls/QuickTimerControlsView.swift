import SwiftUI
import ComposableArchitecture

struct QuickTimerControlsView: View {
  let store: Store<QuickTimerControlsState, QuickTimerControlsAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 32) {
        Button(action: {
          viewStore.send(.pause)
        }) {
          Image(systemName: "pause")
            .font(.system(size: 22))
        }
        .disabled(!viewStore.isRunning)
        
        Button(action: {
          viewStore.send(.start)
        }) {
          Image(systemName: "play")
            .font(.system(size: 44))
        }
        .disabled(viewStore.isRunning)
        
        Button(action: {
          viewStore.send(.stop)
        }) {
          Image(systemName: "stop")
            .font(.system(size: 22))
        }
        .disabled(!viewStore.isRunning)
      }
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
