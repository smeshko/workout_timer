import DomainEntities
import CoreData

extension Statistic: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> StatisticDao {
        let statistic = StatisticDao(context: context)
        statistic.date = date
        statistic.id = id
        statistic.workoutName = workoutName
        statistic.workoutDuration = workoutDuration
        return statistic
    }
}
