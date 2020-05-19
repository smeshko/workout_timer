import Foundation
import WorkoutCore
import ComposableArchitecture

public enum ActiveWorkoutAction: Equatable {
  case exerciseSet(id: UUID, action: ActiveExerciseRowAction)
  case workoutBegin
  case timerTicked
  case pause
  case resume
  case moveToNextExercise
}

public struct ActiveWorkoutState: Equatable {
  var workout: Workout
  var sets: IdentifiedArrayOf<ActiveExerciseRowState> = []
  var currentSet: ExerciseSet
  var totalTimeExpired: Int = 0
  var isRunning = false

  var formattedTimeExpired: String {
    String(format: "%02d:%02d", totalTimeExpired / 60, totalTimeExpired % 60)
  }

  public init(workout: Workout) {
    self.workout = workout
    self.currentSet = workout.sets.first!
    sets = IdentifiedArrayOf<ActiveExerciseRowState>(workout.sets.map { ActiveExerciseRowState(set: $0) })
  }
}

public struct ActiveWorkoutEnvironment {
  
  let mainQueue: AnySchedulerOf<DispatchQueue>
  
  public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.mainQueue = mainQueue
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
      state.moveToNextExercise()
      
    case .exerciseSet:
      break
    }
    return .none
  },
  activeExerciseRowReducer.forEach(
    state: \.sets,
    action: /ActiveWorkoutAction.exerciseSet(id:action:),
    environment: { _ in ActiveExerciseRowEnvironment() } )
  )


private extension ActiveWorkoutState {
  mutating func moveToNextExercise() {
    sets.applyChanges(to: currentSet, { $0.isActive = false })

    guard let index = sets.firstIndex(where: { $0.set == currentSet }), index < sets.count - 1 else { return }
    currentSet = sets[index + 1].set
    sets.applyChanges(to: currentSet, { $0.isActive = true })
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
