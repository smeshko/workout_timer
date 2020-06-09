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
                            .fillColor(
                                viewStore.currentSegment?.category == .workout ?
                                .brand1 : .brand2
                            )
                            .edgesIgnoringSafeArea(.top)
                        
                        VStack {
                            Text("\(viewStore.state.currentSetIndex) / \(viewStore.segments.count)")
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
                            
                            Text(viewStore.segmentTimeLeft.formattedTimeLeft)
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
    var currentSetIndex: Int {
        guard let segment = currentSegment else { return 1 }
        return (segments.firstIndex(of: segment) ?? 0) + 1
    }

    var segmentProgress: Double {
        Double(segmentTimeLeft) / Double(currentSegment?.duration ?? 0)
    }
}
