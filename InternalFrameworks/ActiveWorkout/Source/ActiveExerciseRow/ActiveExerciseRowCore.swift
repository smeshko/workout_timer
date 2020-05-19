import Foundation
import WorkoutCore
import ComposableArchitecture

struct TimerId: Hashable {}

public enum ActiveExerciseRowAction: Equatable {}

@dynamicMemberLookup
public struct ActiveExerciseRowState: Identifiable, Equatable {
  
  var isActive = false
  let set: ExerciseSet
  var secondsLeft: TimeInterval = 0
  
  public var id: UUID {
    self.set.id
  }
  
  var formattedTimeLeft: String {
    String(format: "%02d:%02d", Int(secondsLeft) / 60, Int(secondsLeft) % 60)
  }
  
  subscript<T>(dynamicMember keyPath: KeyPath<ExerciseSet, T>) -> T {
    self.set[keyPath: keyPath]
  }

  public init(set: ExerciseSet) {
    self.set = set
    secondsLeft = set.duration
  }
}

public struct ActiveExerciseRowEnvironment {}

public let activeExerciseRowReducer = Reducer<ActiveExerciseRowState, ActiveExerciseRowAction, ActiveExerciseRowEnvironment> { state, action, environment in
  return .none
}
