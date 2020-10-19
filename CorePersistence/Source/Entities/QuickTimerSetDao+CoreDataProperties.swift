import Foundation
import CoreData

extension QuickTimerSetDao {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuickTimerSetDao> {
        return NSFetchRequest<QuickTimerSetDao>(entityName: "QuickTimerSetDao")
    }

    @NSManaged var id: UUID?
    @NSManaged var work: QuickTimerSegmentDao?
    @NSManaged var pause: QuickTimerSegmentDao?

}

extension QuickTimerSetDao: Identifiable {}
extension QuickTimerSetDao: DatabaseEntity {
    func toDomainEntity() -> QuickTimerSet {
        QuickTimerSet(id: { id ?? UUID() }, work: work?.duration ?? 0, pause: pause?.duration ?? 0)
    }
}
