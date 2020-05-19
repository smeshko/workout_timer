import SwiftUI
import WorkoutCore
import ComposableArchitecture
import WorkoutDetails

struct WorkoutView: View {
  
  let workout: Workout
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      Image(uiImage: UIImage(namedSharedAsset: workout.image) ?? UIImage())
        .resizable()
        .frame(width: UIScreen.main.bounds.width, height: 240)
        .aspectRatio(contentMode: .fit)
        
      VStack(alignment: .leading, spacing: 4) {
        Text(workout.name)
          .font(.system(size: 24, weight: .bold))
        Text(workout.duration)
          .font(.system(size: 32, weight: .heavy))
        Spacer()
        Text("\(workout.count) exercises")
          .font(.system(size: 16, weight: .semibold))
      }
      .padding()
    }
  }
}

struct WorkoutView_Previews: PreviewProvider {
  static var previews: some View {
    
    return WorkoutView(workout: Workout(id: "1", name: "Mock workout", image: "preview-workout-1", sets:
      ExerciseSet.sets(4, exercise: .pushUps, duration: 30, pauseInBetween: 10)
    ))
      .environment(\.colorScheme, .dark)
      .previewLayout(.fixed(width: 375, height: 240))
  }
}

private extension Workout {
  var duration: String {
    let total = sets
      .map { $0.duration }
      .reduce(0, +)
    
    let minutes = Int(ceil(total / 60))
    
    return "\(minutes)m"
  }
  
  var count: String {
    "\(sets.filter { $0.name != Exercise.recovery.name }.count)"
  }
}

private extension Array {
  func appending(contentsOf: Array) -> Array {
    var copy = self
    copy.append(contentsOf: contentsOf)
    return copy
  }
}
