import SwiftUI
import CoreInterface
import ComposableArchitecture

struct FinishedWorkoutView: View {
    private let store: Store<FinishedWorkoutState, FinishedWorkoutAction>
    @ObservedObject private var viewStore: ViewStore<FinishedWorkoutState, FinishedWorkoutAction>

    init(store: Store<FinishedWorkoutState, FinishedWorkoutAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            ZStack {
                Text(key: "congratulations")
                    .font(.h1)
                    .foregroundColor(viewStore.workout.workout.color.color)

                Confetti()
            }

            Text(key: "finished_greeting")
                .font(.h2)
                .foregroundColor(.appText)
            
            Spacer()

            VStack(spacing: Spacing.xxs) {
                Text("Estimated burned calories")
                    .font(.h2)
                    .foregroundColor(viewStore.workout.workout.color.color)
                Text("\(viewStore.caloriesBurned)")
                    .font(.bodyRegular)
                    .foregroundColor(.appGrey)
            }

            VStack(spacing: Spacing.xxs) {
                Text("Total time")
                    .font(.h2)
                    .foregroundColor(viewStore.workout.workout.color.color)
                Text(viewStore.workout.totalDuration.formattedTimeLeft)
                    .font(.bodyRegular)
                    .foregroundColor(.appGrey)
            }

            VStack(spacing: Spacing.xxs) {
                Text("Date")
                    .font(.h2)
                    .foregroundColor(viewStore.workout.workout.color.color)
                
                Text("\(viewStore.workout.startDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.bodyRegular)
                        .foregroundColor(.appGrey)
                     
                Text("\(viewStore.workout.startDate.formatted(date: .omitted, time: .shortened)) - \(viewStore.workout.finishDate.formatted(date: .omitted, time: .shortened))")
                    .font(.bodyRegular)
                    .foregroundColor(.appGrey)
            }

            Spacer()
            
            Button(action: {
                viewStore.send(.closeButtonTapped)
            }) {
                Text("Done")
                    .font(.h2)
                    .foregroundColor(.appWhite)
            }
            .padding(.vertical, Spacing.m)
            .padding(.horizontal, Spacing.xl)
            .background(Capsule().foregroundColor(viewStore.workout.workout.color.color))

        }
        .padding(Spacing.xxl)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

//struct FinishedWorkoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        FinishedWorkoutView(
//            store: Store<FinishedWorkoutState, FinishedWorkoutAction>(
//                initialState: FinishedWorkoutState(workout: mockQuickWorkout1),
//                reducer: finishedWorkoutReducer,
//                environment: .preview
//            )
//        )
//        .previewDevice(.iPhone11)
//    }
//}
