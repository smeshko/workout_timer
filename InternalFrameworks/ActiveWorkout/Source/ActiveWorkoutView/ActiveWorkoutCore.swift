import Foundation
import WorkoutCore
import ComposableArchitecture

public enum ActiveWorkoutAction: Equatable {
  case exerciseSet(id: UUID, action: ActiveExerciseRowAction)
}

public struct ActiveWorkoutState: Equatable {
  var workout: Workout
  var sets: IdentifiedArrayOf<ActiveExerciseRowState> = []
  var currentSet: ActiveExerciseRowState
  var totalTimeExpired: Int = 0
  var isRunning = false

  public init(workout: Workout) {
    self.workout = workout
    self.currentSet = ActiveExerciseRowState(set: workout.sets.first!)
    sets = IdentifiedArrayOf<ActiveExerciseRowState>(workout.sets.map { ActiveExerciseRowState(set: $0) })
  }
}

public struct ActiveWorkoutEnvironment: Equatable {
  
  public init() {}
}

public let activeWorkoutReducer = Reducer<ActiveWorkoutState, ActiveWorkoutAction, ActiveWorkoutEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .exerciseSet(let id, let rowAction):
      switch rowAction {
      case .exerciseFinished:
        state.moveToNextExercise()
      default: break
      }
    }
    return .none
  },
  activeExerciseRowReducer.forEach(
    state: \.sets,
    action: /ActiveWorkoutAction.exerciseSet(id:action:),
    environment: { _ in ActiveExerciseRowEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler()) } )
  )

private extension ActiveWorkoutState {
  mutating func moveToNextExercise() {
    guard let index = sets.firstIndex(of: currentSet), index < sets.count - 1 else { return }
    currentSet = sets[index + 1]
    currentSet.isActive = true
  }
}
