import Foundation
import UIKit

public struct Exercise: Identifiable, Codable, Equatable, Hashable {
  public let id: String
  public let name: String
  public let image: String
  
  public init(id: String, name: String, image: String) {
    self.id = id
    self.name = name
    self.image = image
  }
}
