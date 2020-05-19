import SwiftUI
import WorkoutCore
import ComposableArchitecture

public struct ActiveWorkoutView: View {
  
  let store: Store<ActiveWorkoutState, ActiveWorkoutAction>
  
  public init(workout: Workout) {
    self.store = Store<ActiveWorkoutState, ActiveWorkoutAction>(
      initialState: ActiveWorkoutState(workout: workout),
      reducer: activeWorkoutReducer,
      environment: ActiveWorkoutEnvironment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      )
    )
  }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      ZStack(alignment: .top) {
        Image(uiImage: UIImage(namedSharedAsset: viewStore.currentSet.image) ?? UIImage())
          .resizable()
          .aspectRatio(contentMode: .fit)

        HStack {
          Text(viewStore.formattedTimeExpired)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
          Spacer()
          Button(action: {
            if viewStore.isRunning {
              viewStore.send(.pause)
            } else {
              viewStore.send(.resume)
            }
          }) {
            Image(systemName: viewStore.isRunning ? "pause.fill" : "play.fill")
          }
        }
        .padding()
        .accentColor(.primary)
        
      }
      
      ScrollView {
        VStack(spacing: 0) {
          ForEachStore(
            self.store.scope(state: \.sets, action: ActiveWorkoutAction.exerciseSet(id:action:)),
            content: ActiveExerciseRowView.init(store:)
          )
        }
      }
      .onAppear {
        viewStore.send(.workoutBegin)
      }
      
    }
    .navigationBarHidden(true)
  }
}

struct ActiveWorkoutView_Previews: PreviewProvider {
  static var previews: some View {
    ActiveWorkoutView(
      workout: mockWorkout
    )
  }
}

private let mockWorkout = Workout(id: "1", name: "Mock Workout", image: "preview-bodyweight-1", sets: ExerciseSet.sets(5, exercise: Exercise(name: "Mock", image: "preview-exercise-1"), duration: 45, pauseInBetween: 15))
