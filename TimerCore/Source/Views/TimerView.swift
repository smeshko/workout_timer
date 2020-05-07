import SwiftUI
import ComposableArchitecture

public struct TimerView: View {
  
  let store: Store<TimerState, TimerAction>
  
  public init(store: Store<TimerState, TimerAction>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Spacer()
        
        Text(viewStore.formattedTotalTimeLeft)
          .font(.system(size: 48, design: .monospaced))
        
        Text(viewStore.formattedSegmentTimeLeft)
          .font(.system(size: 72, design: .monospaced))
        
        Spacer()
        
        VStack(spacing: 16) {
          ValuePicker(store: self.store.scope(state: \.sets, action: TimerAction.changeSetsCount),
            valueName: "Sets",
            maxValue: 21,
            tint: .orange
          )

          ValuePicker(store: self.store.scope(state: \.workoutTime, action: TimerAction.changeWorkoutTime),
            valueName: "Workout Time",
            maxValue: 121,
            tint: .red
          )

          ValuePicker(store: self.store.scope(state: \.breakTime, action: TimerAction.changeBreakTime),
            valueName: "Break Time",
            maxValue: 61,
            tint: .purple
          )
        }
        .padding()
        
        Spacer()
        
        HStack(spacing: 32) {
          Button(action: {
            viewStore.send(.pause)
          }) {
            Image(systemName: "pause")
              .font(.system(size: 22))
          }
          .disabled(!viewStore.isRunning)
          
          Button(action: {
            viewStore.send(.start(new: viewStore.currentSegment == nil))
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
        .padding()
      }
      .onAppear {
        viewStore.send(.setNavigation)
      }
    }
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    TimerView(
      store: Store<TimerState, TimerAction>(
        initialState: TimerState(),
        reducer: timerReducer,
        environment: TimerEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          soundClient: .mock
        )
      )
    )
  }
}
