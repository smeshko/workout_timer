import Foundation
import WorkoutCore
import ComposableArchitecture

public enum ActiveWorkoutAction: Equatable {
  
}

public struct ActiveWorkoutState: Equatable {
  var workout: Workout
  var currentSet: ExerciseSet
  var totalTimeExpired: Int = 0
  var isRunning = false

  public init(workout: Workout) {
    self.workout = workout
    self.currentSet = workout.sets.first!
  }
}

public struct ActiveWorkoutEnvironment: Equatable {
  
  public init() {}
}

public let activeWorkoutReducer = Reducer<ActiveWorkoutState, ActiveWorkoutAction, ActiveWorkoutEnvironment> { state, action, environment in
  
  
  return .none
}
