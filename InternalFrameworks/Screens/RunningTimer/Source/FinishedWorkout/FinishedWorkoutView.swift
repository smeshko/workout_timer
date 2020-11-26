import SwiftUI
import CoreInterface
import ComposableArchitecture

struct FinishedWorkoutView: View {
    let store: Store<FinishedWorkoutState, FinishedWorkoutAction>
    let viewStore: ViewStore<FinishedWorkoutState, FinishedWorkoutAction>

    init(store: Store<FinishedWorkoutState, FinishedWorkoutAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                Text("Congratulations!")
                    .font(.h1)
                    .foregroundColor(viewStore.workout.color.color)

                Confetti()
            }
            Text("Another one in the books")
                .font(.h2)
                .foregroundColor(.appText)

            Spacer()

            Button {
                viewStore.send(.didTapDoneButton)
            } label: {
                Text("Done")
                    .font(.h3)
                    .foregroundColor(.appWhite)
                    .padding()
            }
            .background(Color.appSuccess)
            .cornerRadius(12)
            .padding(.bottom, 28)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

struct FinishedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        FinishedWorkoutView(
            store: Store<FinishedWorkoutState, FinishedWorkoutAction>(
                initialState: FinishedWorkoutState(workout: mockQuickWorkout1),
                reducer: finishedWorkoutReducer,
                environment: FinishedWorkoutEnvironment(repository: .mock)
            )
        )
        .previewDevice(.iPhone11)
    }
}
