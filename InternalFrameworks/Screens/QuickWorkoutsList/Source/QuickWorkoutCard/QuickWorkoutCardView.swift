import SwiftUI
import DomainEntities
import ComposableArchitecture
import RunningTimer

struct QuickWorkoutCardView: View {

    let store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>

    @State var isPresented = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 18) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewStore.duration) mins")
                        .font(.h3)

                    Text("\(viewStore.segmentsCount) segments")
                        .font(.bodySmall)
                }

                HStack {
                    Text(viewStore.workout.name)
                        .font(.h1)

                    Spacer()

                    if viewStore.canStart {
                        Button(action: {
                            viewStore.send(.tapStart)
                            isPresented = true
                        }, label: {
                            Image(systemName: "play.fill")
                                .padding(12)
                                .foregroundColor(.appWhite)
                                .background(Color(hue: viewStore.workout.color.hue, saturation: viewStore.workout.color.saturation, brightness: viewStore.workout.color.brightness))
                                .mask(Circle())

                        })
                        .fullScreenCover(isPresented: $isPresented) {
                            RunningTimerView(store: store.scope(state: \.runningTimerState, action: QuickWorkoutCardAction.runningTimerAction))
                        }

                    }
                }
            }
            .padding(18)
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
}

struct QuickWorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {

        let store = Store<QuickWorkoutCardState, QuickWorkoutCardAction>(
            initialState: QuickWorkoutCardState(
                workout: QuickWorkout(id: UUID(),
                                      name: "Quick Workout",
                                      color: WorkoutColor(hue: 0.53, saturation: 0.54, brightness: 0.33),
                                      segments: [
                                        QuickWorkoutSegment(id: UUID(), sets: 4, work: 20, pause: 10),
                                        QuickWorkoutSegment(id: UUID(), sets: 2, work: 60, pause: 10)
                                      ]),
                canStart: true),
            reducer: quickWorkoutCardReducer,
            environment: QuickWorkoutCardEnvironment(notificationClient: .mock)
        )

        return Group {
            QuickWorkoutCardView(store: store)
                .padding()
                .previewLayout(.fixed(width: 375, height: 180))
                .preferredColorScheme(.dark)

            QuickWorkoutCardView(store: store)
                .padding()
                .previewLayout(.fixed(width: 375, height: 180))
        }
    }
}
