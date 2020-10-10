import SwiftUI
import ComposableArchitecture
import WorkoutCore

struct RunningTimerView: View {
    let store: Store<RunningTimerState, RunningTimerAction>
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    public init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 28) {

                HStack {
                    Button(action: {
                        viewStore.send(.timerFinished)
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .frame(width: 18, height: 18)
                            .padding(10)
                            .foregroundColor(.appDark)
                    })
                    .background(Color.appWhite)
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    Text(viewStore.totalTimeLeft.formattedTimeLeft)
                        .foregroundColor(.appWhite)
                        .font(.h1)
                }
                
                SegmentedProgressView(totalSegments: viewStore.segments.count,
                                      filledSegments: viewStore.finishedSegments,
                                      title: "Segments")
                    .padding(.top, 28)

                Spacer()

                VStack(spacing: 8) {

                    Text("Scored Time")
                        .foregroundColor(.appGrey)
                        .font(.display)

                    Text(viewStore.segmentTimeLeft.formattedTimeLeft)
                        .foregroundColor(.appWhite)
                        .font(.gigantic)

                    Text(viewStore.currentSegmentName)
                        .foregroundColor(.appWhite)
                        .font(.h2)
                }

                Spacer()

                QuickTimerControlsView(store: self.store.scope(state: \.timerControlsState, action: RunningTimerAction.timerControlsUpdatedState))
            }
            .padding(28)
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
    }
}

struct RunningTimerView_Previews: PreviewProvider {
    static var previews: some View {
        RunningTimerView(
            store: Store<RunningTimerState, RunningTimerAction>(
                initialState: RunningTimerState(),
                reducer: runningTimerReducer,
                environment: RunningTimerEnvironment(uuid: UUID.init,
                                                     mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                     soundClient: .mock
                )
            )
        )
    }
}

private extension RunningTimerState {
    var currentSegmentName: String {
        currentSegment?.category == .workout ? "Work out" : "Recover"
    }
}
