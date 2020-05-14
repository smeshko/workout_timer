import Foundation
import WorkoutCore
import ComposableArchitecture

public enum WorkoutsFeedAction: Equatable {
  case workoutTypeChanged( WorkoutsFeedState.WorkoutType)
  
  case workoutsList(WorkoutsListAction)
}

public struct WorkoutsFeedState: Equatable {
  
  public enum WorkoutType: String, CaseIterable, Hashable {
    case jumpRope = "Jump rope"
    case bodyweight = "Bodyweight"
    case custom = "Custom"
  }
  
  var workoutTypes = WorkoutType.allCases
  var selectedWorkoutType: WorkoutType = .jumpRope
  var workouts: [Workout] = []
  
  var workoutsListState = WorkoutsListState()

  public init() {}
}

public struct WorkoutsFeedEnvironment: Equatable {
  
  public init() {}
}

public let workoutsFeedReducer = Reducer<WorkoutsFeedState, WorkoutsFeedAction, WorkoutsFeedEnvironment> { state, action, environment in
  
  switch action {
  case .workoutTypeChanged(let type):
    state.selectedWorkoutType = type
    state.workoutsListState.workouts = []
  }
  
  return .none
}
