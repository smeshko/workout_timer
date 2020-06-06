import Foundation

public struct Segment: Equatable, Identifiable, Hashable {
    public enum Category: Equatable {
        case workout
        case pause
    }
    
    public let id: UUID
    public let duration: TimeInterval
    public let category: Category
    
    public init(id: UUID, duration: TimeInterval, category: Segment.Category) {
        self.id = id
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
