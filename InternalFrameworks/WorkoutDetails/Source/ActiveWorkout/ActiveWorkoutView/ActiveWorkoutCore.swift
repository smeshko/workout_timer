import Foundation
import WorkoutCore
import ComposableArchitecture

public enum ActiveWorkoutAction: Equatable {
  case exerciseSet(id: String, action: ActiveExerciseRowAction)
  case workoutBegin
  case timerTicked
  case pause
  case resume
  case moveToNextExercise
  case stopWorkout
  case workoutFinished
  
  
  case exerciseAction(ActiveExerciseRowAction)
}

public struct ActiveWorkoutState: Equatable {
  var workout: Workout
  var sets: IdentifiedArrayOf<ActiveExerciseRowState> = []
  var currentSet: ExerciseSet
  var totalTimeExpired: TimeInterval = 0
  var isRunning = false
  var isFinished = false

  var formattedTimeExpired: String {
    String(format: "%02d:%02d", Int(ceil(totalTimeExpired)) / 60, Int(ceil(totalTimeExpired)) % 60)
  }

  public init(workout: Workout) {
    self.workout = workout
    self.currentSet = workout.sets.first!
    sets = IdentifiedArrayOf<ActiveExerciseRowState>(workout.sets.map { ActiveExerciseRowState(set: $0) })
  }
}

public struct ActiveWorkoutEnvironment {
  
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let soundClient: SoundClient
  
  public init(mainQueue: AnySchedulerOf<DispatchQueue>, soundClient: SoundClient) {
    self.mainQueue = mainQueue
    self.soundClient = soundClient
  }
}

public let activeWorkoutReducer = Reducer<ActiveWorkoutState, ActiveWorkoutAction, ActiveWorkoutEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
      
    case .pause:
      state.isRunning = false
      return Effect<ActiveWorkoutAction, Never>.cancel(id: TimerId())
      
    case .resume:
      return Effect(value: ActiveWorkoutAction.workoutBegin)
      
    case .stopWorkout:
      state.reset()
      return Effect<ActiveWorkoutAction, Never>.cancel(id: TimerId())
      
    case .workoutBegin:
      state.isRunning = true
      state.sets.applyChanges(to: state.currentSet) { el in
        el.isActive = true
      }
      return Effect
        .timer(id: TimerId(), every: 1, tolerance: .zero, on: environment.mainQueue)
        .map { _ in ActiveWorkoutAction.timerTicked }
      
    case .timerTicked:
      state.totalTimeExpired += 1
      state.sets.applyChanges(to: state.currentSet) { el in
        el.secondsLeft -= 1
      }

      if (state.sets.first(where: { $0.set == state.currentSet })?.secondsLeft ?? 0) <= 0 {
        return Effect(value: ActiveWorkoutAction.moveToNextExercise)
      }
      
    case .moveToNextExercise:
      return state.moveToNextExercise(soundClient: environment.soundClient)
      
    case .workoutFinished:
      state.isRunning = false
      state.isFinished = true
      return Effect<ActiveWorkoutAction, Never>.cancel(id: TimerId())
      
    case .exerciseAction: break
      
    case .exerciseSet:
      break
    }
    return .none
  },
  activeExerciseRowReducer.forEach(
    state: \.sets,
    action: /ActiveWorkoutAction.exerciseSet(id:action:),
    environment: { _ in ActiveExerciseRowEnvironment() } )
//  .resending(
//    from: { (string: String) -> ActiveWorkoutAction in
//      ActiveWorkoutAction.exerciseAction(ActiveExerciseRowAction.exerciseBegin)
//    },
//    to: { (string: String) -> ActiveWorkoutAction in
//      ActiveWorkoutAction.exerciseAction(ActiveExerciseRowAction.exerciseBegin)
//    }
//  )

  )


private extension ActiveWorkoutState {
  mutating func moveToNextExercise(soundClient: SoundClient) -> Effect<ActiveWorkoutAction, Never> {
    sets.applyChanges(to: currentSet, { $0.isActive = false })

    guard let index = sets.firstIndex(where: { $0.set == currentSet }), index < sets.count - 1 else {
      return Effect(value: ActiveWorkoutAction.workoutFinished)
    }
    
    currentSet = sets[index + 1].set
    sets.applyChanges(to: currentSet, { $0.isActive = true })
    
    return soundClient.play(.segment).fireAndForget()
  }
  
  mutating func reset() {
    currentSet = workout.sets.first!
    sets = IdentifiedArrayOf<ActiveExerciseRowState>(workout.sets.map { ActiveExerciseRowState(set: $0) })
    totalTimeExpired = 0
    isRunning = false
  }
}

extension IdentifiedArrayOf where Element == ActiveExerciseRowState {
  mutating func applyChanges(to element: ExerciseSet, _ changes: (inout Element) -> Void) {
    guard let index = self.firstIndex(where: { $0.set == element }) else { return }
    var el = self[index]
    changes(&el)
    self.remove(at: index)
    self.insert(el, at: index)
  }
}

extension Reducer {
  func resending<Value>(
    from case: @escaping (Value) -> Action,
    to embed: @escaping (Value) -> Action
  ) -> Self {
    .combine(
      self,
      .init { state, action, _ in
        if let value = CasePath.case(`case`).extract(from: action) {
          return Effect(value: embed(value))
        } else {
          return .none
        }
      }
    )
  }
}
