import Foundation
import ComposableArchitecture

public enum WorkoutDetailsAction: Equatable {
  
}

public struct WorkoutDetailsState: Equatable {

  public init() {}
}

public struct WorkoutDetailsEnvironment: Equatable {
  
  public init() {}
}

public let workoutDetailsReducer = Reducer<WorkoutDetailsState, WorkoutDetailsAction, WorkoutDetailsEnvironment> { state, action, environment in
  
  
  return .none
}
