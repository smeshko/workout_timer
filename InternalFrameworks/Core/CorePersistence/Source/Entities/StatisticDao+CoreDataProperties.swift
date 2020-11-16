import Foundation
import DomainEntities
import CoreData

extension StatisticDao {

    @nonobjc class func fetchRequest() -> NSFetchRequest<StatisticDao> {
        return NSFetchRequest<StatisticDao>(entityName: "StatisticDao")
    }

    @NSManaged var date: Date?
    @NSManaged var id: UUID?
    @NSManaged var workoutName: String?
    @NSManaged var workoutDuration: Double

}

extension StatisticDao: Identifiable {}
extension StatisticDao: DatabaseEntity {
    func toDomainEntity() -> Statistic {
        Statistic(
            id: id ?? UUID(),
            date: date ?? Date(),
            workoutName: workoutName ?? "",
            workoutDuration: workoutDuration
        )
    }

    func update(with new: Statistic, in context: NSManagedObjectContext) {
        date = new.date
        workoutName = new.workoutName
        workoutDuration = new.workoutDuration
    }
}
