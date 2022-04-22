import Foundation
import CoreData
import DomainEntities

extension QuickWorkoutSegmentDao {

    @nonobjc class func fetchRequest() -> NSFetchRequest<QuickWorkoutSegmentDao> {
        return NSFetchRequest<QuickWorkoutSegmentDao>(entityName: "QuickWorkoutSegmentDao")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var sets: Int16
    @NSManaged public var work: Int16
    @NSManaged public var pause: Int16
    @NSManaged public var workout: QuickWorkoutDao?
    @NSManaged public var createdAt: Date?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}

extension QuickWorkoutSegmentDao: Identifiable {}
extension QuickWorkoutSegmentDao: DatabaseEntity {
    func toDomainEntity() -> QuickWorkoutSegment {
        QuickWorkoutSegment(
            id: id ?? UUID(),
            name: name,
            sets: Int(sets),
            work: Int(work),
            pause: Int(pause)
        )
    }

    func update(with new: QuickWorkoutSegment, in context: NSManagedObjectContext) {
        name = new.name
        sets = Int16(new.sets)
        work = Int16(new.work)
        pause = Int16(new.pause)
    }
}
