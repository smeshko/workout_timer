import Foundation

public struct Segment: Equatable, Identifiable, Hashable {
  public enum Category: Equatable {
    case workout
    case pause
  }
  
  public let id = UUID()
  public let duration: Int
  public let category: Category
  
  public init(duration: Int, category: Segment.Category) {
    self.duration = duration
    self.category = category
  }
}

extension Segment: CustomStringConvertible {
  public var description: String {
    "\(duration)s \(category)"
  }
}

extension Segment.Category: CustomStringConvertible {
  public var description: String {
    switch self {
    case .workout: return "workout"
    case .pause: return "pause"
    }
  }
}
