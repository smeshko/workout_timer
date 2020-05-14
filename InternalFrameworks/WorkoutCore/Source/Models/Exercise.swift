import Foundation

public struct Exercise: Equatable {
  public let title: String?
  public let sets: [ExerciseSet]
  public let pauseDuration: TimeInterval
  
  public init(title: String?, sets: [ExerciseSet], pauseDuration: TimeInterval) {
    self.title = title
    self.sets = sets
    self.pauseDuration = pauseDuration
  }
}

public struct ExerciseSet: Equatable {
  public let duration: TimeInterval
  
  public init(duration: TimeInterval) {
    self.duration = duration
  }
}
