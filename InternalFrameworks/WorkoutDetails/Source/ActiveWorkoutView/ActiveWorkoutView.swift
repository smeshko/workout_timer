import SwiftUI
import WorkoutCore
import ComposableArchitecture

public struct ActiveWorkoutView: View {
    
    let store: Store<ActiveWorkoutState, ActiveWorkoutAction>
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    public init(workout: Workout) {
        self.store = Store<ActiveWorkoutState, ActiveWorkoutAction>(
            initialState: ActiveWorkoutState(workout: workout),
            reducer: activeWorkoutReducer,
            environment: ActiveWorkoutEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                soundClient: .live
            )
        )
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                ImageView(viewStore: ViewStore(store), presentationMode: _presentationMode)

                CurrentExerciseView(viewStore: ViewStore(store))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(Color.appDark)

                NextExerciseView(viewStore: ViewStore(store))
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .onAppear {
                viewStore.send(.workoutBegin)
            }
        }
    }
}

struct ActiveWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveWorkoutView(workout: mockWorkout1)
    }
}

private struct ImageView: View {

    let viewStore: ViewStore<ActiveWorkoutState, ActiveWorkoutAction>
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack(alignment: .top) {
//                    RemoteImage(key: viewStore.currentSet.imageKey)
            Image(namedSharedAsset: "bodyweight-2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.top)


            HStack {
                Button(action: {
                    viewStore.send(.stopWorkout)
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

                Text(viewStore.totalTimeExpired.formattedTimeLeft)
                    .foregroundColor(.appWhite)
                    .font(.h1)
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 28)
        }

    }
}

private struct CurrentExerciseView: View {
    let viewStore: ViewStore<ActiveWorkoutState, ActiveWorkoutAction>

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("Scored Time")
                    .foregroundColor(.appGrey)
                    .font(.display)

                Text(viewStore.currentSetSecondsLeft.formattedTimeLeft)
                    .foregroundColor(.appWhite)
                    .font(.gigantic)
            }

            Text(viewStore.currentSet?.name ?? "")
                .foregroundColor(.appWhite)
                .font(.h2)

            HStack(spacing: 18) {
                Button(action: {
                    viewStore.send(.pause)
                }, label: {
                    Image(systemName: "pause")
                        .frame(width: 18, height: 18)
                        .padding(15)
                        .foregroundColor(.appWhite)
                })
                .background(Color.appGrey)
                .cornerRadius(12)

                Button(action: {

                }, label: {
                    Text("Next")
                        .padding(.vertical, 18)
                        .padding(.horizontal, 42)
                        .background(Color.appPrimary)
                        .foregroundColor(.appWhite)
                        .font(.h4)
                        .cornerRadius(12)
                })
            }

            SegmentedProgressView(totalSegments: viewStore.totalWorkoutSets,
                                  filledSegments: viewStore.finishedWorkoutSets,
                                  title: "Exercises")
                .padding(.horizontal, 28)
        }
    }
}

private struct NextExerciseView: View {
    let viewStore: ViewStore<ActiveWorkoutState, ActiveWorkoutAction>

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                if let set = viewStore.nextSet {
                    Text("Up next")
                        .foregroundColor(.appGrey)
                        .font(.display)

                    ExerciseRowView(set: set)
                } else {
                    Text("That's the last one!")
                        .foregroundColor(.appGrey)
                        .font(.display)
                }
            }
            .padding(28)
        }
    }
}