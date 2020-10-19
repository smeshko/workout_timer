import Foundation
import CoreData

public struct QuickTimerSet: Equatable, Identifiable, Hashable {

    public let id: UUID
    public let work: Segment
    public let pause: Segment

    public var duration: TimeInterval { work.duration + pause.duration }

    public init(id: () -> UUID, work: TimeInterval, pause: TimeInterval) {
        self.id = id()
        self.work = Segment(id: id, duration: work, category: .workout)
        self.pause = Segment(id: id, duration: pause, category: .pause)
    }

    public struct Segment: Equatable, Hashable {
        public enum Category: Int, Equatable {
            case workout
            case pause
        }

        public let duration: TimeInterval
        public let category: Category
        public let id: UUID

        public init(id: () -> UUID, duration: TimeInterval, category: Segment.Category) {
            self.id = id()
            self.duration = duration
            self.category = category
        }
    }
}

extension QuickTimerSet: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickTimerSetDao {
        let set = QuickTimerSetDao(context: context)
        set.id = id
        set.work = work.createDatabaseEntity(in: context)
        set.pause = pause.createDatabaseEntity(in: context)
        return set
    }
}

extension QuickTimerSet.Segment: DomainEntity {
    var objectId: String { id.uuidString }
    
    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickTimerSegmentDao {
        let segment = QuickTimerSegmentDao(context: context)
        segment.id = id
        segment.category = Int16(category.rawValue)
        segment.duration = duration
        return segment
    }
}
