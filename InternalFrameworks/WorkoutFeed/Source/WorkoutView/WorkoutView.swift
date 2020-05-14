import SwiftUI
import WorkoutCore
import ComposableArchitecture

struct WorkoutView: View {
  
  let workout: Workout
  
  var body: some View {
    VStack {
      Image(uiImage: UIImage(data: workout.image ?? Data()) ?? UIImage())
      Text(workout.name ?? "")
        .padding()
      Text(workout.duration)
    }
  }
}

struct WorkoutView_Previews: PreviewProvider {
  static var previews: some View {
    WorkoutView(workout: Workout(id: "1", name: "Mock workout", exercises: []))
  }
}

private extension Workout {
  var duration: String {
    let total = exercises.flatMap { $0.sets }.map { $0.duration }.reduce(0, +)
    let minutes = Int(total / 60)
    
    return "\(minutes)m"
  }
}
