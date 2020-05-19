import Foundation
import ComposableArchitecture

@dynamicMemberLookup
public struct ExerciseSet: Identifiable, Codable, Equatable {
  public var id: UUID
  fileprivate let exercise: Exercise
  public let duration: TimeInterval
  
  public init(exercise: Exercise, duration: TimeInterval) {
    self.id = UUID()
    self.exercise = exercise
    self.duration = duration
  }
  
  public subscript<T>(dynamicMember keyPath: KeyPath<Exercise, T>) -> T {
    exercise[keyPath: keyPath]
  }
  
  /// A convenience function to batch creates exercise
  /// - Parameters:
  ///   - count: number of times to add the given exercise
  ///   - exercise: the exercise to create
  ///   - duration: the duration of the exercise
  ///   - pauseInBetween: pause between exercises. If `nil`, no pause will be added. Defaults to `nil`
  /// - Returns: an array of `ExerciseSet`s that contain the requested exercise
  public static func sets(_ count: Int, exercise: Exercise, duration: TimeInterval, pauseInBetween: TimeInterval? = nil) -> IdentifiedArrayOf<ExerciseSet> {
    var sets: IdentifiedArrayOf<ExerciseSet> = []
    (0 ..< count).forEach { index in
      sets.insert(ExerciseSet(exercise: exercise, duration: duration), at: 0)
      if let pause = pauseInBetween, index != count - 1 {
        sets.insert(.recovery(pause), at: 0)
      }
    }
    return sets
  }
  
  /// Creates an array of exercise sets by alternating between the given exercises.
  /// - Parameters:
  ///   - exercises: a dictionary with exercises and their durations to alternate between
  ///   - count: the number of times to add the exercises
  /// - Returns: an array of exercise sets
  public static func alternating(_ count: Int, _ exercises: [Exercise: TimeInterval]) -> IdentifiedArrayOf<ExerciseSet> {
    var sets: IdentifiedArrayOf<ExerciseSet> = []
    (0 ..< count).forEach { _ in
      sets.insert(contentsOf: exercises.map { exercise, duration in
        ExerciseSet(exercise: exercise, duration: duration)
      }, at: 0)
    }
    return sets
  }
}
