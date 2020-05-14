import Foundation
import WorkoutCore
import ComposableArchitecture

public enum SomeError: Error, Equatable {
  case error
}

public enum WorkoutsFeedAction: Equatable {
  case workoutTypeChanged( WorkoutsFeedState.WorkoutType)
  case workoutsLoaded(Result<[Workout], SomeError>)
  case beginNavigation
  
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

public struct WorkoutsFeedEnvironment {
  let localStorageClient: LocalStorageClient
  
  public init(localStorageClient: LocalStorageClient) {
    self.localStorageClient = localStorageClient
  }
}

public let workoutsFeedReducer = Reducer<WorkoutsFeedState, WorkoutsFeedAction, WorkoutsFeedEnvironment> { state, action, environment in
  
  switch action {
    
  case .beginNavigation:
    return environment
      .localStorageClient
      .readFromFile("jumprope", "json")
      .decode(type: [Workout].self, decoder: JSONDecoder())
      .mapError { _ in SomeError.error }
      .catchToEffect()
      .map(WorkoutsFeedAction.workoutsLoaded)
    
  case .workoutTypeChanged(let type):
    state.selectedWorkoutType = type
    state.workoutsListState.workouts = []
    
  case .workoutsLoaded(.success(let workouts)):
    state.workoutsListState.workouts = workouts
  
  case .workoutsLoaded(.failure(let error)):
    break
  }
  
  return .none
}
