import Foundation
import CoreData

extension QuickTimerSegmentDao {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuickTimerSegmentDao> {
        return NSFetchRequest<QuickTimerSegmentDao>(entityName: "QuickTimerSegmentDao")
    }

    @NSManaged var duration: Double
    @NSManaged var id: UUID?
    @NSManaged var category: Int16

}

extension QuickTimerSegmentDao: Identifiable {}
extension QuickTimerSegmentDao: DatabaseEntity {
    func toDomainEntity() -> QuickTimerSet.Segment {
        QuickTimerSet.Segment(id: { id ?? UUID() }, duration: duration, category: QuickTimerSet.Segment.Category(rawValue: Int(category)) ?? .workout)
    }
}
