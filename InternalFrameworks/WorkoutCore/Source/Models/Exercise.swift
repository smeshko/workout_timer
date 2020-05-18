import Foundation
import UIKit

public struct Exercise: Identifiable, Codable, Equatable, Hashable {
  public let id: UUID
  public let name: String
  public let image: String
  
  public init(name: String, image: String) {
    self.id = UUID()
    self.name = name
    self.image = image
  }
}

private extension Data {
  private static let bundle = Bundle(identifier: "com.tsonevInc.mobile.ios.WorkoutTimer")
  
  static let image = UIImage(named: "stretching", in: bundle, compatibleWith: nil)?.pngData()
}

public extension Exercise {
  static var jumpingJacks: Exercise {
    Exercise(name: "Jumping jacks", image: "stretching")
  }
  
  static var pushUps: Exercise {
    Exercise(name: "Push ups", image: "push-ups")
  }
  
  static var crissCross: Exercise {
    Exercise(name: "Criss Cross", image: "criss-cross")
  }
  
  static var doubleUnder: Exercise {
    Exercise(name: "Double Unders", image: "double-unders")
  }
  
  static var boxerStep: Exercise {
    Exercise(name: "Boxer steps", image: "boxer-steps")
  }
  
  static var recovery: Exercise {
    Exercise(name: "Recovery", image: "stretching")
  }
}

public extension ExerciseSet {
  static func jumpingJacks(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: .jumpingJacks, duration: duration)
  }
  
  static func pushUps(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: .pushUps, duration: duration)
  }
  
  static func crissCross(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: .crissCross, duration: duration)
  }
  
  static func doubleUnder(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: .doubleUnder, duration: duration)
  }
  
  static func boxerStep(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: .boxerStep, duration: duration)
  }
  
  static func recovery(_ duration: TimeInterval) -> ExerciseSet {
    ExerciseSet(exercise: .recovery, duration: duration)
  }
}
