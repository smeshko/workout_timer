import Foundation
import WorkoutCore
import ComposableArchitecture

public enum WorkoutAction: Equatable {
  
}

public struct WorkoutState: Equatable {

  var workout: Workout
  
  public init(workout: Workout) {
    self.workout = workout
  }
}

public struct WorkoutEnvironment: Equatable {
  
  public init() {}
}

public let workoutReducer = Reducer<WorkoutState, WorkoutAction, WorkoutEnvironment> { state, action, environment in
  
  
  return .none
}
