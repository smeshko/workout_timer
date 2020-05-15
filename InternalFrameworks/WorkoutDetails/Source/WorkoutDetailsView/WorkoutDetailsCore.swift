import Foundation
import WorkoutCore
import ComposableArchitecture

public enum WorkoutDetailsAction: Equatable {
  
}

public struct WorkoutDetailsState: Equatable {

  var workout: Workout
  
  public init(workout: Workout) {
    self.workout = workout
  }
}

public struct WorkoutDetailsEnvironment: Equatable {
  
  public init() {}
}

public let workoutDetailsReducer = Reducer<WorkoutDetailsState, WorkoutDetailsAction, WorkoutDetailsEnvironment> { state, action, environment in
  
  
  return .none
}
