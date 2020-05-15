import SwiftUI
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
      Text(viewStore.workout.name ?? "")
    }
  }
}

struct WorkoutDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    WorkoutDetailsView(workout: Workout(id: ""))
  }
}
