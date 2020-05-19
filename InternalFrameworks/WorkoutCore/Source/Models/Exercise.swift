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
