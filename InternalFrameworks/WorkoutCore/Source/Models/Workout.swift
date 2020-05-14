import Foundation

public struct Workout: Codable, Equatable, Identifiable {
  public let id: String
  public let name: String?
  public let exercises: [Exercise]
  
  public init(id: String, name: String? = nil, exercises: [Exercise] = []) {
    self.id = id
    self.name = name
    self.exercises = exercises
  }
}
