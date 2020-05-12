import SwiftUI
import ComposableArchitecture

public struct TimerView: View {
  
  let store: Store<TimerState, TimerAction>
    
  public init(store: Store<TimerState, TimerAction>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationView {
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
          
          CircuitPickerView(store: self.store.scope(state: \.circuitPickerState, action: TimerAction.circuitPickerUpdatedValues))
            .padding()
          
          Spacer()
          
          TimerControlsView(store: self.store.scope(state: \.timerControlsState, action: TimerAction.timerControlsUpdatedState))
            .padding()
          
        }
        .onAppear {
          viewStore.send(.setNavigation)
        }
        .navigationBarItems(trailing:
          Button(action: {
            viewStore.send(.setCircuitComposerSheet(isPresented: true))
          }) {
            Image(systemName: "hammer.fill")
        }
          .sheet(isPresented: viewStore.binding(
            get: \.isPresentingCircuitComposer,
            send: TimerAction.setCircuitComposerSheet(isPresented:)
          )) {
            CircuitComposerView(store: self.store.scope(state: \.circuitComposerState, action: TimerAction.circuitComposerUpdated))
          }
        )
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
