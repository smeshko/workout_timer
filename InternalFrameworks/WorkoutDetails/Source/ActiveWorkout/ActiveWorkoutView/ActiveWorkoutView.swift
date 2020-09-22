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
                                .foregroundColor(.appBlack)
                        })
                        .background(Color.appWhite)
                        .cornerRadius(12)

                        Spacer()

                        Text(viewStore.formattedTimeExpired)
                            .font(.h3)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 28)
                }

                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        Text("Scored Time")
                            .foregroundColor(.appTextSecondary)
                            .font(.display)

                        Text("00:32")
                            .foregroundColor(.appWhite)
                            .font(.gigantic)
                    }

                    Text("Boxer skip")
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
                        .background(Color.appTextSecondary)
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
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.appBlack)
                .cornerRadius(12)
//                    VStack {
//
//                        HStack {
//                            Text(viewStore.formattedTimeExpired)
//                                .font(.system(size: 24, weight: .bold, design: .monospaced))
//                            Spacer()
//
//                            HStack(spacing: 24) {
//                                Button(action: {
//                                    if viewStore.isRunning {
//                                        viewStore.send(.pause)
//                                    } else {
//                                        viewStore.send(.resume)
//                                    }
//                                }) {
//                                    Image(systemName: viewStore.isRunning ? "pause.fill" : "play.fill")
//                                        .font(.system(size: 24))
//                                }
//
//                                Button(action: {
//                                    viewStore.send(.stopWorkout)
//                                    self.presentationMode.wrappedValue.dismiss()
//                                }) {
//                                    Image(systemName: "xmark")
//                                        .font(.system(size: 24))
//                                }
//                            }
//                        }
//                        .padding()
//                        .accentColor(.primary)
//
//                        Text(viewStore.currentSet.name.uppercased())
//                            .multilineTextAlignment(.center)
//                            .font(.system(size: 48, weight: .heavy))
//                            .shadow(color: .black, radius: 5, x: 2, y: 2)
//                            .padding()
//                    }
//                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEachStore(
                            self.store.scope(state: \.sets, action: ActiveWorkoutAction.exerciseSet(id:action:)),
                            content: ActiveExerciseRowView.init(store:)
                        )
                    }
                }
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
        ActiveWorkoutView(
            workout: mockWorkout
        )
    }
}

private let mockWorkout = Workout(id: "1", name: "Mock Workout", imageKey: "preview-bodyweight-1", sets: ExerciseSet.sets(5, exercise: Exercise(id: "", name: "Mock", imageKey: "preview-exercise-4"), duration: 45, pauseInBetween: 15))
