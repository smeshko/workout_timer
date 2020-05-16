import Foundation
import WorkoutCore
import ComposableArchitecture

public enum WorkoutsFeedError: Error, Equatable {
  case failedLoadingWorkouts
}

public enum WorkoutsFeedAction: Equatable {
  case workoutTypeChanged(WorkoutsFeedState.WorkoutType)
  case workoutsLoaded(Result<[Workout], WorkoutsFeedError>)
  case beginNavigation
  
  case bodyweightWorkoutsAction(WorkoutsListAction)
  case jumpropeWorkoutsAction(WorkoutsListAction)
}

public struct WorkoutsFeedState: Equatable {
  
  public enum WorkoutType: String, CaseIterable, Hashable {
    case jumpRope = "Jump rope"
    case bodyweight = "Bodyweight"
    case custom = "Custom"
  }
  
  var workoutTypes = WorkoutType.allCases
  var selectedWorkoutType: WorkoutType = .jumpRope
  
  var bodyweightWorkoutsState = WorkoutsListState()
  var jumpropeWorkoutsState = WorkoutsListState()

  public init() {}
}

public struct WorkoutsFeedEnvironment {
  let localStorageClient: LocalStorageClient
  let mainQueue: AnySchedulerOf<DispatchQueue>
  
  public init(localStorageClient: LocalStorageClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.localStorageClient = localStorageClient
    self.mainQueue = mainQueue
  }
}

public let workoutsFeedReducer = Reducer<WorkoutsFeedState, WorkoutsFeedAction, WorkoutsFeedEnvironment> { state, action, environment in
  
  switch action {
    
  case .beginNavigation:
    if state.isSelectedTypeEmpty {
      return environment.loadWorkouts(state.selectedWorkoutType, mainQueue: environment.mainQueue)
    }
    
  case .workoutTypeChanged(let type):
    state.selectedWorkoutType = type
    if state.isSelectedTypeEmpty {
      return environment.loadWorkouts(type, mainQueue: environment.mainQueue)
    }
    
  case .workoutsLoaded(.success(let workouts)):
    switch state.selectedWorkoutType {
    case .bodyweight:
      state.bodyweightWorkoutsState.workouts = workouts
    case .jumpRope:
      state.jumpropeWorkoutsState.workouts = workouts
    default: break
    }
  
  case .workoutsLoaded(.failure(let error)):
    break
  }
  
  return .none
}

private extension WorkoutsFeedEnvironment {
  func loadWorkouts(_ type: WorkoutsFeedState.WorkoutType, mainQueue: AnySchedulerOf<DispatchQueue>) -> Effect<WorkoutsFeedAction, Never> {

    localStorageClient
      .readFromFile(type.filename, "json")
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

extension WorkoutsFeedState {
  var isSelectedTypeEmpty: Bool {
    switch selectedWorkoutType {
    case .bodyweight:
      return bodyweightWorkoutsState.workouts.isEmpty
    case .jumpRope:
      return jumpropeWorkoutsState.workouts.isEmpty
    default: return false
    }
  }
}
