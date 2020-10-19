import Foundation
import CoreData

extension QuickWorkoutSegmentDao {

    @nonobjc class func fetchRequest() -> NSFetchRequest<QuickWorkoutSegmentDao> {
        return NSFetchRequest<QuickWorkoutSegmentDao>(entityName: "QuickWorkoutSegmentDao")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var sets: Int16
    @NSManaged public var work: Int16
    @NSManaged public var pause: Int16
    @NSManaged public var workout: QuickWorkoutDao?

}

extension QuickWorkoutSegmentDao: Identifiable {}
extension QuickWorkoutSegmentDao: DatabaseEntity {
    func toDomainEntity() -> QuickWorkoutSegment {
        QuickWorkoutSegment(
            id: id ?? UUID(),
            sets: Int(sets),
            work: Int(work),
            pause: Int(pause)
        )
    }
}
