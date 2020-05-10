import Foundation

public struct Segment: Equatable, Identifiable {
  public enum Category: Equatable {
    case workout
    case pause
  }
  
  public let id = UUID()
  public let duration: Int
  public let category: Category
}
