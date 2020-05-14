import Foundation
import WorkoutCore
import ComposableArchitecture

public enum WorkoutsFeedError: Error, Equatable {
  case failedLoadingWorkouts
}

public enum WorkoutsFeedAction: Equatable {
  case workoutTypeChanged( WorkoutsFeedState.WorkoutType)
  case workoutsLoaded(Result<[Workout], WorkoutsFeedError>)
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
    if state.workouts.isEmpty {
      return environment.loadWorkouts(state.selectedWorkoutType)
    }
    
  case .workoutTypeChanged(let type):
    state.selectedWorkoutType = type
    return environment.loadWorkouts(type)
    
  case .workoutsLoaded(.success(let workouts)):
    state.workoutsListState.workouts = workouts
  
  case .workoutsLoaded(.failure(let error)):
    break
  }
  
  return .none
}

private extension WorkoutsFeedEnvironment {
  func loadWorkouts(_ type: WorkoutsFeedState.WorkoutType) -> Effect<WorkoutsFeedAction, Never> {
    localStorageClient
      .readFromFile(type.filename, "json")
      .receive(on: DispatchQueue.main)
      .decode(type: [Workout].self, decoder: JSONDecoder())
      .mapError { _ in WorkoutsFeedError.failedLoadingWorkouts }
      .catchToEffect()
      .map(WorkoutsFeedAction.workoutsLoaded)
  }
}

private extension WorkoutsFeedState.WorkoutType {
  var filename: String {
    switch self {
    case .bodyweight: return "bodyweight"
    case .jumpRope: return "jumprope"
    case .custom: return "custom"
    }
  }
}
