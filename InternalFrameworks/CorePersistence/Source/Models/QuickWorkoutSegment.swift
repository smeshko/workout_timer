import Foundation
import CoreData

public struct QuickWorkoutSegment: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let sets: Int
    public let work: Int
    public let pause: Int

    public init(id: UUID, sets: Int, work: Int, pause: Int) {
        self.id = id
        self.sets = sets
        self.work = work
        self.pause = pause
    }
}

extension QuickWorkoutSegment: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickWorkoutSegmentDao {
        let segment = QuickWorkoutSegmentDao(context: context)
        segment.id = id
        segment.sets = Int16(sets)
        segment.work = Int16(work)
        segment.pause = Int16(pause)
        return segment
    }
}
