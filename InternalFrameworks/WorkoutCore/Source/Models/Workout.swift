import Foundation

public struct Workout: Codable, Equatable, Identifiable {
  public let id: String
  public let image: Data?
  public let name: String?
  public let exercises: [Exercise]
  
  public init(id: String, image: Data? = nil, name: String? = nil, exercises: [Exercise] = []) {
    self.id = id
    self.image = image
    self.name = name
    self.exercises = exercises
  }
}
