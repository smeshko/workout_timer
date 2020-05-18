import Foundation
import WorkoutCore
import ComposableArchitecture

struct TimerId: Hashable {}

public enum ActiveExerciseRowAction: Equatable {
  case timerTicked
  case exerciseBegin
  case exerciseFinished
}

public struct ActiveExerciseRowState: Identifiable, Equatable {
  
  public var id: UUID { self.set.id }
  let set: ExerciseSet
  var isActive = false
  var formattedTimeLeft: String = "00:00"
  
  fileprivate var secondsLeft: TimeInterval = 0 {
    didSet {
      formattedTimeLeft = String(format: "%02d:%02d", secondsLeft / 60, secondsLeft.truncatingRemainder(dividingBy: 60))
    }
  }

  public init(set: ExerciseSet) {
    self.set = set
  }
}

public struct ActiveExerciseRowEnvironment {
  
  let mainQueue: AnySchedulerOf<DispatchQueue>
  
  public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.mainQueue = mainQueue
  }
}

public let activeExerciseRowReducer = Reducer<ActiveExerciseRowState, ActiveExerciseRowAction, ActiveExerciseRowEnvironment> { state, action, environment in
  
  switch action {
  case .exerciseBegin:
    state.secondsLeft = state.set.duration
    return Effect
      .timer(id: TimerId(), every: 1, tolerance: .zero, on: environment.mainQueue)
      .map { _ in ActiveExerciseRowAction.timerTicked }
    
  case .timerTicked:
    state.secondsLeft -= 1
    
    if state.secondsLeft == 0 {
      return Effect(value: ActiveExerciseRowAction.exerciseFinished)
    }
    
  case .exerciseFinished:
    break
  }
  
  return .none
}
