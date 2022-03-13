import DomainEntities
import CoreData

extension QuickWorkoutSegment: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickWorkoutSegmentDao {
        let segment = QuickWorkoutSegmentDao(context: context)
        segment.id = id
        segment.name = name
        segment.sets = Int16(sets)
        segment.work = Int16(work)
        segment.pause = Int16(pause)
        return segment
    }
}
