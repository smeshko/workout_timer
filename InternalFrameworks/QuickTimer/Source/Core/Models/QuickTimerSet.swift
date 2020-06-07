import Foundation

public struct QuickTimerSet: Equatable, Identifiable, Hashable {

    public let id: UUID
    public let work: Segment
    public let pause: Segment
    
    public var duration: TimeInterval { work.duration + pause.duration }
    
    public init(id: UUID, work: TimeInterval, pause: TimeInterval) {
        self.id = id
        self.work = Segment(id: UUID(), duration: work, category: .workout)
        self.pause = Segment(id: UUID(), duration: pause, category: .pause)
    }

    public struct Segment: Equatable, Hashable {
        public enum Category: Equatable {
            case workout
            case pause
        }
        
        public let duration: TimeInterval
        public let category: Category
        public let id: UUID
        
        public init(id: UUID, duration: TimeInterval, category: Segment.Category) {
            self.id = id
            self.duration = duration
            self.category = category
        }
    }
}
