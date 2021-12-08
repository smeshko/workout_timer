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
                    .styling(font: .h1, color: viewStore.workout.workout.color.color)

                Confetti()
            }

            Text(key: "finished_greeting")
                .styling(font: .h2)
            
            Spacer()

            VStack(spacing: Spacing.xxs) {
                Text("Estimated burned calories")
                    .styling(font: .h2, color: viewStore.workout.workout.color.color)
                Text("\(viewStore.caloriesBurned)")
                    .styling(font: .bodyRegular, color: .appGrey)
            }

            VStack(spacing: Spacing.xxs) {
                Text("Total time")
                    .styling(font: .h2, color: viewStore.workout.workout.color.color)

                Text(viewStore.workout.totalDuration.formattedTimeLeft)
                    .styling(font: .bodyRegular, color: .appGrey)
            }

            VStack(spacing: Spacing.xxs) {
                Text("Date")
                    .styling(font: .h2, color: viewStore.workout.workout.color.color)
                
                Text("\(viewStore.workout.startDate.formatted(date: .abbreviated, time: .omitted))")
                    .styling(font: .bodyRegular, color: .appGrey)
                     
                Text("\(viewStore.workout.startDate.formatted(date: .omitted, time: .shortened)) - \(viewStore.workout.finishDate.formatted(date: .omitted, time: .shortened))")
                    .styling(font: .bodyRegular, color: .appGrey)
            }

            Spacer()
            
            Button(action: {
                viewStore.send(.closeButtonTapped)
            }) {
                Text("Done")
                    .styling(font: .h2)
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
