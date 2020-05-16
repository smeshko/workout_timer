import Foundation
import UIKit

public struct Exercise: Codable, Equatable, Hashable {
  public let title: String?
  public let image: Data?
  
  public init(title: String?, image: Data? = nil) {
    self.title = title
    self.image = image
  }
}

public extension Exercise {
  
  private static let bundle = Bundle(identifier: "com.tsonevInc.mobile.ios.WorkoutCore")
  
  static var jumpingJacks: Exercise {
    Exercise(title: "Jumping jacks", image: UIImage(named: "stretching", in: bundle, compatibleWith: nil)?.pngData())
  }
  
  static var pushUps: Exercise {
    Exercise(title: "Push ups", image: UIImage(named: "stretching", in: bundle, compatibleWith: nil)?.pngData())
  }
  
  static var crissCross: Exercise {
    Exercise(title: "Criss Cross", image: UIImage(named: "stretching", in: bundle, compatibleWith: nil)?.pngData())
  }
  
  static var doubleUnder: Exercise {
    Exercise(title: "Double Unders", image: UIImage(named: "stretching", in: bundle, compatibleWith: nil)?.pngData())
  }
  
  static var boxerStep: Exercise {
    Exercise(title: "Boxer steps", image: UIImage(named: "stretching", in: bundle, compatibleWith: nil)?.pngData())
  }
  
  static var recovery: Exercise {
    Exercise(title: "Recovery", image: UIImage(named: "stretching", in: bundle, compatibleWith: nil)?.pngData())
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
