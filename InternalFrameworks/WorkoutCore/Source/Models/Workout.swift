import Foundation
import UIKit
import ComposableArchitecture

public struct Workout: Codable, Equatable, Identifiable {
  
  public let id: String
  public let name: String
  public var image: String
  public let sets: IdentifiedArrayOf<ExerciseSet>
  
  public init(id: String, name: String, image: String, sets: IdentifiedArrayOf<ExerciseSet> = []) {
    self.id = id
    self.image = image
    self.name = name
    self.sets = sets
  }
}
