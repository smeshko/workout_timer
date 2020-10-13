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
                            .foregroundColor(.appText)
                    })
                    .background(Color.appCardBackground)
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    Text(viewStore.totalTimeLeft.formattedTimeLeft)
                        .foregroundColor(.appText)
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
                        .foregroundColor(.appText)
                        .font(.gigantic)

                    Text(viewStore.currentSegmentName)
                        .foregroundColor(.appText)
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

        let store = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                segments: [QuickTimerSet(id: UUID.init, work: 30, pause: 10)],
                currentSegment: QuickTimerSet.Segment(id: UUID.init, duration: 30, category: .workout),
                timerControlsState: QuickTimerControlsState(timerState: .running)
            ),
            reducer: runningTimerReducer,
            environment: RunningTimerEnvironment(uuid: UUID.init,
                                                 mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                 soundClient: .mock
            )
        )

        return Group {
            RunningTimerView(store: store)
                .preferredColorScheme(.dark)
                .previewDevice(.iPhone11)

            RunningTimerView(store: store)
                .previewDevice(.iPadPro)
        }
    }
}

private extension RunningTimerState {
    var currentSegmentName: String {
        currentSegment?.category == .workout ? "Work out" : "Recover"
    }
}
