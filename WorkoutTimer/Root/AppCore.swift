import ComposableArchitecture
import UIKit
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
      .fileExists(jumpRopeFileName, "json")
      .flatMap { exists -> Effect<Void, StorageError> in
        if !exists {
          if let jumpropeData = try? JSONEncoder().encode(jumpropeWorkouts), let bodyweightData = try? JSONEncoder().encode(bodyweightWorkouts) {
            return .concatenate(env.localStorageClient.write(jumpropeData, jumpRopeFileName, "json"),
                                env.localStorageClient.write(bodyweightData, bodyweightFileName, "json"))
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

private let jumpropeWorkouts = [
  Workout(id: "jumprope-1", image: UIImage(named: "jumprope-3")?.pngData(), name: "Jump Rope Fat Burn", exercises: [
    Exercise(title: "Criss Cross", sets: ExerciseSet.count(5, duration: 45), pauseDuration: 15),
    Exercise(title: "Double Under", sets: ExerciseSet.count(5, duration: 45), pauseDuration: 15)
  ]),

  Workout(id: "jumprope-2", image: UIImage(named: "jumprope-2")?.pngData(), name: "Jump Rope Get Fit", exercises: [
    Exercise(title: "Boxer step", sets: ExerciseSet.count(5, duration: 60), pauseDuration: 15),
    Exercise(title: "Freestyle", sets: ExerciseSet.count(5, duration: 45), pauseDuration: 15),
    Exercise(title: "Criss Cross", sets: ExerciseSet.count(5, duration: 45), pauseDuration: 15),
    Exercise(title: "Double Under", sets: ExerciseSet.count(5, duration: 45), pauseDuration: 15)
  ])
]

private let bodyweightWorkouts = [
  Workout(id: "bodyweight-1", image: UIImage(named: "bodyweight-1")?.pngData(), name: "Bodyweight Fat Burn", exercises: [
    Exercise(title: "Push ups", sets: ExerciseSet.count(2, duration: 30), pauseDuration: 20),
    Exercise(title: "Jumping jacks", sets: ExerciseSet.count(4, duration: 45), pauseDuration: 15)
  ])
]

private extension ExerciseSet {
  static func count(_ num: Int, duration: TimeInterval) -> [ExerciseSet] {
    (0...num).map { _ in
      ExerciseSet(duration: duration)
    }
  }
}

private let bodyweightFileName = "bodyweight"
private let jumpRopeFileName = "jumprope"
private let customFileName = "custom"
