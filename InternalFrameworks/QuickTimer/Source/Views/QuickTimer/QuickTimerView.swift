import SwiftUI
import ComposableArchitecture
import WorkoutCore

public struct QuickTimerView: View {
  
  let store: Store<QuickTimerState, QuickTimerAction>
    
  public init(store: Store<QuickTimerState, QuickTimerAction>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationView {
      WithViewStore(self.store) { viewStore in
        VStack {
          VStack {
            Text(viewStore.formattedTotalTimeLeft)
              .font(.system(size: 48, design: .monospaced))
            
            Text(viewStore.formattedSegmentTimeLeft)
              .font(.system(size: 72, design: .monospaced))
          }
          .padding([.top])
          
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
          
          QuickExerciseBuilderView(store: self.store.scope(state: \.circuitPickerState, action: QuickTimerAction.circuitPickerUpdatedValues))
            .padding()
          
          QuickTimerControlsView(store: self.store.scope(state: \.timerControlsState, action: QuickTimerAction.timerControlsUpdatedState))
            .padding()
          
        }
        .onAppear {
          viewStore.send(.setNavigation)
        }
      }
    }
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    QuickTimerView(
      store: Store<QuickTimerState, QuickTimerAction>(
        initialState: QuickTimerState(),
        reducer: quickTimerReducer,
        environment: QuickTimerEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          soundClient: .mock
        )
      )
    )
  }
}

private extension QuickTimerState {
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
  
  var formattedTotalTimeLeft: String {
    String(format: "%02d:%02d", totalTimeLeft / 60, totalTimeLeft % 60)
  }
  
  var formattedSegmentTimeLeft: String {
    String(format: "%02d:%02d", segmentTimeLeft / 60, segmentTimeLeft % 60)
  }  
}


/*
 
 Set      -> a workout
 Segment  -> workout + pause
 Circuit  -> multiple segments
 
 */
