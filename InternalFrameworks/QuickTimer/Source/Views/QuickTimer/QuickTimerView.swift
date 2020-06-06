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
                ZStack(alignment: .bottom) {
                    if viewStore.timerControlsState.timerState == .running || viewStore.timerControlsState.timerState == .paused {
                        ProgressView(value: viewStore.binding(
                            get: \.segmentProgress,
                            send: QuickTimerAction.progressBarDidUpdate
                        ), axis: .vertical)
                            .edgesIgnoringSafeArea(.top)
                        
                        VStack {
                            Text("\(viewStore.state.currentSetIndex) / \(viewStore.workoutSegmentsCount)")
                                .font(.system(size: 32))
                                .shadow(color: .black, radius: 4, x: 5, y: 5)
                            if viewStore.currentSegment?.category == .workout {
                                Text("Work")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            } else {
                                Text("Recover")
                            }
                            
                            Spacer()
                            
                            Text(viewStore.formattedSegmentTimeLeft)
                                .font(.system(size: 90, design: .monospaced))
                                .shadow(color: .black, radius: 6, x: 5, y: 5)
                            Spacer()
                        }
                    } else {
                        VStack {
                            Spacer()
                            QuickExerciseBuilderView(store: self.store.scope(state: \.circuitPickerState, action: QuickTimerAction.circuitPickerUpdatedValues))
                                .padding()
                            Spacer()
                        }
                    }
                    QuickTimerControlsView(store: self.store.scope(state: \.timerControlsState, action: QuickTimerAction.timerControlsUpdatedState))
                        .padding()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .navigationBarHidden(true)
                .onAppear {
                    viewStore.send(.setNavigation)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTimerView(
            store: Store<QuickTimerState, QuickTimerAction>(
                initialState: QuickTimerState(),
                reducer: quickTimerReducer,
                environment: QuickTimerEnvironment(
                    uuid: UUID.init,
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
    
    var segmentProgress: Double {
        Double(segmentTimeLeft) / Double(currentSegment?.duration ?? 0)
    }
    
    var formattedTotalTimeLeft: String {
        String(format: "%02d:%02d", totalTimeLeft / 60, Int(segmentTimeLeft) % 60)
    }
    
    var formattedSegmentTimeLeft: String {
        String(format: "%02d:%02d", segmentTimeLeft / 60, Int(segmentTimeLeft) % 60)
    }  
}
