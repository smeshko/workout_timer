import SwiftUI
import ComposableArchitecture
import WorkoutCore

public struct QuickTimerView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    let store: Store<QuickTimerState, QuickTimerAction>
    
    public init(store: Store<QuickTimerState, QuickTimerAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                ZStack(alignment: self.zStackAlignment) {
                    if viewStore.timerControlsState.timerState == .running || viewStore.timerControlsState.timerState == .paused {
                        
                        ProgressView(viewStore: viewStore, axis: self.progressAxis)
                            .fillColor(viewStore.currentSegment?.category.progressColor)
                            .edgesIgnoringSafeArea(self.progressIgnoredSafeAreas)
                        
                        SizeClassAdaptingView {
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
                            QuickTimerControlsView(store: self.store.scope(state: \.timerControlsState, action: QuickTimerAction.timerControlsUpdatedState))
                                .padding()
                        }
                        
                    } else {
                        VStack {
                            Spacer()
                            
                            QuickExerciseBuilderView(store: self.store.scope(state: \.circuitPickerState, action: QuickTimerAction.circuitPickerUpdatedValues))
                                .padding()
                            
                            Spacer()
                            
                            QuickTimerControlsView(store: self.store.scope(state: \.timerControlsState, action: QuickTimerAction.timerControlsUpdatedState))
                                .padding()
                        }
                    }
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .onAppear {
                    viewStore.send(.setNavigation)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var zStackAlignment: Alignment {
        horizontalSizeClass == .compact ? .bottom : .leading
    }
    
    private var progressAxis: Axis {
        horizontalSizeClass == .compact ? .vertical : .horizontal
    }
    
    private var progressIgnoredSafeAreas: Edge.Set {
        horizontalSizeClass == .compact ? .top : .horizontal
    }
}

private extension ProgressView {
    
    init(viewStore:  ViewStore<QuickTimerState, QuickTimerAction>, axis: Axis) {
        self.init(value: viewStore.binding(
            get: \.segmentProgress,
            send: QuickTimerAction.progressBarDidUpdate
        ), axis: axis)
    }
}

private extension QuickTimerSet.Segment.Category {
    var progressColor: Color {
        self == .workout ? .brand1 : .brand2
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

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<QuickTimerState, QuickTimerAction>(
            initialState: QuickTimerState(),
            reducer: quickTimerReducer,
            environment: QuickTimerEnvironment(
                uuid: UUID.init,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                soundClient: .mock
            )
        )
        
        return Group {
            QuickTimerView(store: store)
                .previewDevice(.iPhone8)
            
            QuickTimerView(store: store)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
            
        }
    }
}
