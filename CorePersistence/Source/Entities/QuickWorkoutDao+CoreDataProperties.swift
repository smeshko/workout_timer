import Foundation
import CoreData

extension QuickWorkoutDao {

    @nonobjc class func fetchRequest() -> NSFetchRequest<QuickWorkoutDao> {
        return NSFetchRequest<QuickWorkoutDao>(entityName: "QuickWorkoutDao")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var segments: NSOrderedSet?

}

// MARK: Generated accessors for segments
extension QuickWorkoutDao {

    @objc(insertObject:inSegmentsAtIndex:)
    @NSManaged public func insertIntoSegments(_ value: QuickWorkoutSegmentDao, at idx: Int)

    @objc(removeObjectFromSegmentsAtIndex:)
    @NSManaged public func removeFromSegments(at idx: Int)

    @objc(insertSegments:atIndexes:)
    @NSManaged public func insertIntoSegments(_ values: [QuickWorkoutSegmentDao], at indexes: NSIndexSet)

    @objc(removeSegmentsAtIndexes:)
    @NSManaged public func removeFromSegments(at indexes: NSIndexSet)

    @objc(replaceObjectInSegmentsAtIndex:withObject:)
    @NSManaged public func replaceSegments(at idx: Int, with value: QuickWorkoutSegmentDao)

    @objc(replaceSegmentsAtIndexes:withSegments:)
    @NSManaged public func replaceSegments(at indexes: NSIndexSet, with values: [QuickWorkoutSegmentDao])

    @objc(addSegmentsObject:)
    @NSManaged public func addToSegments(_ value: QuickWorkoutSegmentDao)

    @objc(removeSegmentsObject:)
    @NSManaged public func removeFromSegments(_ value: QuickWorkoutSegmentDao)

    @objc(addSegments:)
    @NSManaged public func addToSegments(_ values: NSOrderedSet)

    @objc(removeSegments:)
    @NSManaged public func removeFromSegments(_ values: NSOrderedSet)

}

extension QuickWorkoutDao: Identifiable {}
extension QuickWorkoutDao: DatabaseEntity {
    func toDomainEntity() -> QuickWorkout {
        QuickWorkout(id: id ?? UUID(),
                     name: name ?? "",
                     segments: segments?.compactMap { $0 as? QuickWorkoutSegmentDao }.map { $0.toDomainEntity() } ?? []
        )
    }
}
