import SwiftUI
import CoreInterface
import ComposableArchitecture

struct FinishedWorkoutView: View {
    private let store: Store<FinishedWorkoutState, FinishedWorkoutAction>
    @ObservedObject private var viewStore: ViewStore<FinishedWorkoutState, FinishedWorkoutAction>

    @State private var beginAnimation = false

    init(store: Store<FinishedWorkoutState, FinishedWorkoutAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            Text("Congratulations")
                .font(.h1)
                .foregroundColor(viewStore.workout.color.color)
                .animation(.easeInOut(duration: 0.55))

            Confetti()
        }
        .onAppear {
            viewStore.send(.onAppear)
        }

//        VStack {
//            Spacer()
//
//            ZStack {
//                Text("Congratulations!")
//                    .font(.h1)
//                    .foregroundColor(viewStore.workout.color.color)
//                    .animation(.easeInOut(duration: 0.55))
//
//                Confetti()
//            }
//            Text("Another one in the books")
//                .font(.h2)
//                .foregroundColor(.appText)
//                .animation(.easeInOut(duration: 0.55))
//
//            Spacer()
//
//            Button {
//                withAnimation {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        viewStore.send(.didTapDoneButton)
//                    }
//                    beginAnimation = false
//                }
//            } label: {
//                Text("Done")
//                    .font(.h3)
//                    .foregroundColor(.appWhite)
//                    .padding()
//            }
//            .background(Color.appSuccess)
//            .cornerRadius(12)
//            .padding(.bottom, 28)
//            .animation(.easeInOut(duration: 0.55))
//        }
//        .opacity(beginAnimation ? 1 : 0)
//        .onAppear {
//            viewStore.send(.onAppear)
//            beginAnimation = true
//        }
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
