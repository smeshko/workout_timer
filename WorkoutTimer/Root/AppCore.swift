import ComposableArchitecture
import UIKit
import WorkoutFeed
import Foundation
import WorkoutCore
import QuickTimer

enum AppAction {
  case applicationDidStart
  case finishedWritingWorkouts(Result<Void, StorageError>)
}

struct AppState: Equatable {
  init() {
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
    
  }
  
  return .none
  }
)

private let jumpropeWorkouts = [
  
  Workout(id: "jumprope-3", name: "Complete Routine", image: "bodyweight-3", sets: [
    .freestyle(180),
    .recovery(45),
    .freestyle(180),
    .recovery(45),
    .freestyle(180),
    .recovery(45),
    .freestyle(180),
    .recovery(45),
    .freestyle(180),
    .recovery(45),
    .freestyle(180),

    .recovery(60),

    .heavyRopeJumping(60),
    .recovery(30),
    .pushUps(60),
    .recovery(30),
    .heavyRopeJumping(60),
    .recovery(30),
    .pushUps(60),
    .recovery(30),
    .heavyRopeJumping(60),
    .recovery(30),
    .pushUps(60),
    .recovery(30),
    
    .heavyRopeJumping(30),
    .recovery(30),
    .heavyRopeJumping(30),
    .recovery(30),
    .heavyRopeJumping(30),

    .recovery(60),

    .shadowBoxing(120),
    .recovery(45),
    .bicycles(60),
    .recovery(30),
    .shadowBoxing(120),
    .recovery(45),
    .oneArmShoulderTouches(60),
    .recovery(30),
    .shadowBoxing(120),
    .recovery(45),
    .boatToLowBoat(60),
    .recovery(30),
    .shadowBoxing(120),
    .recovery(45),
    .plank(60),

    .recovery(10),
    
    .lyingTStretch(30),
    .recovery(5),
    .lyingTStretch(30),
    .recovery(5),
    .lyingHamstringStretch(30),
    .recovery(5),
    .lyingHamstringStretch(30),
    .recovery(5),
    .quadRockers(45)
  ]),

  Workout(id: "jumprope-1", name: "Jump Rope Warmup", image: "jumprope-1", sets: ExerciseSet.alternating(4, [
    .freestyle: 180,
    .recovery: 60
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
