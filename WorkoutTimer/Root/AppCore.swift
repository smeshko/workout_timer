import ComposableArchitecture
import WorkoutFeed
import Foundation
import WorkoutCore
import QuickTimer

enum AppAction {
  case applicationDidStart
  case workoutsFeed(WorkoutsFeedAction)
  case finishedWritingWorkouts(Result<Void, StorageError>)
}

struct AppState: Equatable {
  var workoutsFeedState: WorkoutsFeedState
  
  init(workoutsFeedState: WorkoutsFeedState = WorkoutsFeedState()) {
    self.workoutsFeedState = workoutsFeedState
  }
}

struct AppEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var localStorageClient: LocalStorageClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
  struct TriviaRequestId: Hashable {}
  
  switch action {
  case .applicationDidStart:
    return env
      .localStorageClient
      .fileExists("jumprope", "json")
      .flatMap { exists -> Effect<Void, StorageError> in
        if !exists {
          if let data = try? JSONEncoder().encode(jumprope) {
            return env.localStorageClient.write(data, "jumprope", "json")
          } else {
            return Effect(error: StorageError.savingFailed)
          }
        } else {
          return .none
        }
      }
    .catchToEffect()
    .map(AppAction.finishedWritingWorkouts)
    .cancellable(id: TriviaRequestId())
    
  case .finishedWritingWorkouts(.failure(let error)):
    break
    
  case .finishedWritingWorkouts(.success):
    break
    
  case .workoutsFeed(let feedAction):
    break
  }
  
  return .none
  },
  workoutsFeedReducer.pullback(
    state: \.workoutsFeedState,
    action: /AppAction.workoutsFeed,
    environment: { appEnv in WorkoutsFeedEnvironment(localStorageClient: appEnv.localStorageClient) }
  )
)

private let jumprope = [
  Workout(id: "jumprope-1", name: "Jump Rope Fat Burn", exercises: [
    Exercise(title: "Criss Cross", sets: ExerciseSet.count(5, duration: 45), pauseDuration: 15),
    Exercise(title: "Double Under", sets: ExerciseSet.count(5, duration: 45), pauseDuration: 15)
  ])
]

extension ExerciseSet {
  static func count(_ num: Int, duration: TimeInterval) -> [ExerciseSet] {
    (0...num).map { _ in
      ExerciseSet(duration: duration)
    }
  }
}
