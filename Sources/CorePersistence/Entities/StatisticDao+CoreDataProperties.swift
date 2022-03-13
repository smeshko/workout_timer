import Foundation
import DomainEntities
import CoreData

extension StatisticDao {

    @nonobjc class func fetchRequest() -> NSFetchRequest<StatisticDao> {
        return NSFetchRequest<StatisticDao>(entityName: "StatisticDao")
    }

    @NSManaged var startDate: Date?
    @NSManaged var finishDate: Date?
    @NSManaged var burnedCalories: Int16
    @NSManaged var id: UUID?
    @NSManaged var workoutName: String?
    @NSManaged var duration: Double
    @NSManaged public var createdAt: Date?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}

extension StatisticDao: Identifiable {}
extension StatisticDao: DatabaseEntity {
    func toDomainEntity() -> Statistic {
        Statistic(
            id: id ?? UUID(),
            workoutName: workoutName ?? "",
            duration: duration,
            startDate: startDate ?? Date(),
            finishDate: finishDate ?? Date(),
            burnedCalories: Int(burnedCalories)
        )
    }

    func update(with new: Statistic, in context: NSManagedObjectContext) {
        workoutName = new.workoutName
        duration = new.duration
        startDate = new.startDate
        finishDate = new.finishDate
        burnedCalories = Int16(new.burnedCalories)
    }
}
