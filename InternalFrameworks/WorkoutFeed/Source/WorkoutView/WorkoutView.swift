import SwiftUI
import WorkoutCore
import ComposableArchitecture

struct WorkoutView: View {
  
  let workout: Workout
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      Image(uiImage: UIImage(data: workout.image ?? Data()) ?? UIImage())
        .resizable()
        .frame(width: UIScreen.main.bounds.width, height: 240)
        .aspectRatio(contentMode: .fit)
        
      VStack(alignment: .leading, spacing: 4) {
        Text(workout.name ?? "")
          .font(.system(size: 24, weight: .bold))
        Text(workout.duration)
          .font(.system(size: 32, weight: .heavy))
        Spacer()
        Text("\(workout.exercises.count) exercises")
          .font(.system(size: 16, weight: .semibold))
      }
      .padding()
    }
  }
}

struct WorkoutView_Previews: PreviewProvider {
  static var previews: some View {
    let image = UIImage(named: "bodyweight", in: Bundle(identifier: "com.tsonevInc.mobile.ios.WorkoutFeed"), compatibleWith: nil)
    
    return WorkoutView(workout: Workout(id: "1", image: image?.pngData(), name: "Mock workout", exercises: [
      Exercise(title: nil, sets: [ExerciseSet(duration: 45)], pauseDuration: 15),
      Exercise(title: nil, sets: [ExerciseSet(duration: 45)], pauseDuration: 15)
    ]))
      .environment(\.colorScheme, .dark)
      .previewLayout(.fixed(width: 375, height: 240))
  }
}

private extension Workout {
  var duration: String {
    let total = exercises
      .flatMap { $0.sets }
      .map { $0.duration }
      .appending(contentsOf: exercises.map { $0.pauseDuration })
      .reduce(0, +)
    
    let minutes = Int(ceil(total / 60))
    
    return "\(minutes)m"
  }
}

private extension Array {
  func appending(contentsOf: Array) -> Array {
    var copy = self
    copy.append(contentsOf: contentsOf)
    return copy
  }
}
