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
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    viewStore.send(.closeButtonTapped)
                }) {
                    Image(systemName: "xmark")
                        .font(.h2.bold())
                        .foregroundColor(.appWhite)
                }
            }
            
            Spacer()
            ZStack {
                Text(key: "congratulations")
                    .font(.h1)
                    .foregroundColor(viewStore.workout.color.color)
                    .animation(.easeInOut(duration: 0.55))

                Confetti()
            }

            Text(key: "finished_greeting")
                .font(.h2)
                .foregroundColor(.appText)
                .animation(.easeInOut(duration: 0.55))

            Spacer()
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
