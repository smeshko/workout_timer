import Foundation

public struct Exercise: Codable, Equatable, Hashable {
  public let title: String?
  
  public init(title: String?) {
    self.title = title
  }
}

public extension Exercise {
  static var jumpingJacks: Exercise {
    Exercise(title: "Jumping jacks")
  }
  
  static var pushUps: Exercise {
    Exercise(title: "Push ups")
  }
  
  static var crissCross: Exercise {
    Exercise(title: "Criss Cross")
  }
  
  static var doubleUnder: Exercise {
    Exercise(title: "Double Unders")
  }
  
  static var boxerStep: Exercise {
    Exercise(title: "Boxer steps")
  }
  
  static var recovery: Exercise {
    Exercise(title: "Recovery")
  }
}

public extension ExerciseSet {
  static func jumpingJacks(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: Exercise(title: "Jumping jacks"), duration: duration)
  }
  
  static func pushUps(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: Exercise(title: "Push ups"), duration: duration)
  }
  
  static func crissCross(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: Exercise(title: "Criss Cross"), duration: duration)
  }
  
  static func doubleUnder(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: Exercise(title: "Double Unders"), duration: duration)
  }
  
  static func boxerStep(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: Exercise(title: "Boxer steps"), duration: duration)
  }
  
  static func recovery(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: Exercise(title: "Recovery"), duration: duration)
  }
}
