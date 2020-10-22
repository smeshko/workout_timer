import SwiftUI
import ComposableArchitecture
import WorkoutCore
import CorePersistence

struct RunningTimerView: View {
    let store: Store<RunningTimerState, RunningTimerAction>

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    public init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.isInPreCountdown {
                    ZStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 125, height: 125)
                            .foregroundColor(viewStore.color)

                        Text("\(viewStore.preCountdownTimeLeft.clean)")
                            .foregroundColor(.appWhite)
                            .font(.system(size: 72, weight: .heavy))
                            .transition(.scale)
                        Spacer()
                    }

                } else {
                    VStack(spacing: 28) {
                        HStack(spacing: 18) {
                            Button(action: {
                                viewStore.send(.alertButtonTapped)
                            }, label: {
                                Image(systemName: "xmark")
                                    .frame(width: 18, height: 18)
                                    .padding(10)
                                    .foregroundColor(.appText)
                            })
                            .alert(
                              self.store.scope(state: { $0.alert }),
                              dismiss: .alertDismissed
                            )
                            .onChange(of: viewStore.isPresented) { isPresented in
                                if !isPresented {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            .background(Color.appCardBackground)
                            .cornerRadius(12)

                            Text(viewStore.workout.name)
                                .font(.h3)
                                .foregroundColor(.appText)

                            Spacer()

                            Text(viewStore.totalTimeLeft.formattedTimeLeft)
                                .foregroundColor(.appText)
                                .font(.h1)
                        }

                        SegmentedProgressView(totalSegments: viewStore.timerSections.count / 2,
                                              filledSegments: viewStore.finishedSections,
                                              title: "Sections",
                                              color: viewStore.color)
                            .padding(.top, 28)

                        Spacer()

                        VStack(spacing: 8) {

                            Text("Scored Time")
                                .foregroundColor(.appGrey)
                                .font(.display)

                            Text(viewStore.sectionTimeLeft.formattedTimeLeft)
                                .foregroundColor(.appText)
                                .font(.gigantic)

                            Text(viewStore.currentSegmentName)
                                .foregroundColor(.appText)
                                .font(.h2)
                        }

                        Spacer()
                    }

                    QuickTimerControlsView(store: self.store.scope(state: \.timerControlsState, action: RunningTimerAction.timerControlsUpdatedState), tint: viewStore.color)
                }
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
        Text("")
        //        let store = Store<RunningTimerState, RunningTimerAction>(
        //            initialState: RunningTimerState(
        //                segments: [QuickTimerSet(id: UUID.init, work: 30, pause: 10)],
        //                currentSegment: QuickTimerSet.Segment(id: UUID.init, duration: 30, category: .workout),
        //                timerControlsState: QuickTimerControlsState(timerState: .running)
        //            ),
        //            reducer: runningTimerReducer,
        //            environment: RunningTimerEnvironment(uuid: UUID.init,
        //                                                 mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        //                                                 soundClient: .mock
        //            )
        //        )
        //
        //        return Group {
        //            RunningTimerView(store: store)
        //                .preferredColorScheme(.dark)
        //                .previewDevice(.iPhone11)
        //
        //            RunningTimerView(store: store)
        //                .previewDevice(.iPhone8)
        //        }
    }
}

private extension RunningTimerState {
    var currentSegmentName: String {
        currentSection?.type == .work ? "Work out" : "Rest"
    }

    var color: Color {
        Color(hue: workout.color.hue, saturation: workout.color.saturation, brightness: workout.color.brightness)
    }
}

extension TimeInterval {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
