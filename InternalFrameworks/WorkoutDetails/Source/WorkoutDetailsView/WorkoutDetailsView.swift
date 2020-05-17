import SwiftUI
import ActiveWorkout
import WorkoutCore
import ComposableArchitecture

public struct WorkoutDetailsView: View {
  let store: Store<WorkoutDetailsState, WorkoutDetailsAction>
  
  public init(workout: Workout) {
    store = Store<WorkoutDetailsState, WorkoutDetailsAction>(
      initialState: WorkoutDetailsState(workout: workout),
      reducer: workoutDetailsReducer,
      environment: WorkoutDetailsEnvironment()
    )
  }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      ScrollView {
        ZStack {
          Image(uiImage: UIImage(namedSharedAsset: viewStore.workout.image) ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
          
          VStack(spacing: 64) {
            Text(viewStore.workout.name)
              .font(.system(size: 24, weight: .bold))
            
            NavigationLink(destination: ActiveWorkoutView(workout: viewStore.workout)) {
              Text("Start")
                .padding(32)
                .background(Color.white)
                .clipShape(Circle())
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            }
            .buttonStyle(PlainButtonStyle())
            
          }
        }
        VStack(spacing: 0) {
          ForEach(viewStore.workout.sets, id: \.name) { set in
            ExerciseRowView(set: set)
          }
          Spacer()
        }
      }
      .navigationBarTitle("", displayMode: .inline)
    }
    
  }
}

struct WorkoutDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    return WorkoutDetailsView(workout: Workout(id: "1", name: "Mock workout", image: "bodyweight",  sets:
      ExerciseSet.sets(4, exercise: .jumpingJacks, duration: 30, pauseInBetween: 10)
    ))
      .colorScheme(.dark)
      .background(Color.black)
  }
}
