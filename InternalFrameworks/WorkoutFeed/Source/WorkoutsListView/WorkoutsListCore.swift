import Foundation
import WorkoutCore
import ComposableArchitecture

public enum WorkoutsListAction: Equatable {
  
}

public struct WorkoutsListState: Equatable {
  var workouts: [Workout] = []
  
  public init(workouts: [Workout] = []) {
    self.workouts = workouts
  }
}

public struct WorkoutsListEnvironment: Equatable {
  public init() {}
}

public let workoutsListReducer = Reducer<WorkoutsListState, WorkoutsListAction, WorkoutsListEnvironment> { state, action, environment in
  
  
  return .none
}
