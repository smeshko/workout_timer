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
                    RemoteImage(key: viewStore.currentSet.image)
                        .aspectRatio(contentMode: .fit)
                        .frame(idealHeight: 240, alignment: .top)
                    
                    
                    VStack(spacing: 0) {
                        
                        HStack {
                            Text(viewStore.formattedTimeExpired)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                            Spacer()
                            
                            HStack(spacing: 24) {
                                Button(action: {
                                    if viewStore.isRunning {
                                        viewStore.send(.pause)
                                    } else {
                                        viewStore.send(.resume)
                                    }
                                }) {
                                    Image(systemName: viewStore.isRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 24))
                                }
                                
                                Button(action: {
                                    viewStore.send(.stopWorkout)
                                    self.presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 24))
                                }
                            }
                        }
                        .padding()
                        .accentColor(.primary)
                        
                        Text(viewStore.currentSet.name.uppercased())
                            .multilineTextAlignment(.center)
                            .font(.system(size: 48, weight: .heavy))
                            .shadow(color: .black, radius: 5, x: 2, y: 2)
                            .padding()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEachStore(
                            self.store.scope(state: \.sets, action: ActiveWorkoutAction.exerciseSet(id:action:)),
                            content: ActiveExerciseRowView.init(store:)
                        )
                    }
                }
            }
            .onAppear {
                viewStore.send(.workoutBegin)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
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

private let mockWorkout = Workout(id: "1", name: "Mock Workout", image: "preview-bodyweight-1", sets: ExerciseSet.sets(5, exercise: Exercise(id: "", name: "Mock", image: "preview-exercise-4"), duration: 45, pauseInBetween: 15))
