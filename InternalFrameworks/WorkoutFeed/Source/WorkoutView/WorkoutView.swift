import SwiftUI
import WorkoutCore
import ComposableArchitecture

struct WorkoutView: View {
  
  let workout: Workout
  
  var body: some View {
    Text(workout.name ?? "")
  }
}

struct WorkoutView_Previews: PreviewProvider {
  static var previews: some View {
    WorkoutView(workout: Workout(id: "1", name: "Mock workout", exercises: []))
  }
}
