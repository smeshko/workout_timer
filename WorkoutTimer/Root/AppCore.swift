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
  struct LocalStorageReadId: Hashable {}
  
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
    .cancellable(id: LocalStorageReadId())
    
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
    environment: { appEnv in WorkoutsFeedEnvironment(localStorageClient: appEnv.localStorageClient, mainQueue: appEnv.mainQueue) }
  )
)

private let jumpropeWorkouts = [
  Workout(id: "jumprope-1", name: "Jump Rope Fat Burn", image: "jumprope-1", sets: ExerciseSet.alternating(3, [
    .crissCross: 45,
    .recovery: 15,
    .doubleUnder: 45
  ])),

  Workout(id: "jumprope-2", name: "Jump Rope Get Fit", image: "jumprope-2", sets: ExerciseSet.sets(5, exercise: .boxerStep, duration: 45, pauseInBetween: 15))
]

private let bodyweightWorkouts = [
  Workout(id: "bodyweight-1", name: "Bodyweight Fat Burn", image: "bodyweight-1", sets: ExerciseSet.alternating(2, [
    .pushUps: 30,
    .recovery: 15,
    .jumpingJacks: 30
  ]))
]

private let bodyweightFileName = "bodyweight"
private let jumpRopeFileName = "jumprope"
private let customFileName = "custom"
