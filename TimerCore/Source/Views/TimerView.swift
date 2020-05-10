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
        
        if viewStore.isRunning {
          if viewStore.currentSegment?.category == .workout {
            Text("\(viewStore.state.currentSetIndex) / \(viewStore.workoutSegmentsCount)")
              .font(.system(size: 22))
          } else {
            Text("Recover")
              .font(.system(size: 22))
          }
        }
        
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

private extension TimerState {
  private var workouts: [Segment] {
    segments.filter { $0.category == .workout }
  }
  
  var currentSetIndex: Int {
    guard let segment = currentSegment else { return 1 }
    return (workouts.firstIndex(of: segment) ?? 0) + 1
  }
  
  var workoutSegmentsCount: Int {
    workouts.count
  }
}


/*
 
 Set      -> a workout
 Segment  -> workout + pause
 Circuit  -> multiple segments
 
 */
