import DomainEntities
import CoreData

extension Statistic: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> StatisticDao {
        let statistic = StatisticDao(context: context)
        statistic.id = id
        statistic.workoutName = workoutName
        statistic.startDate = startDate
        statistic.finishDate = finishDate
        statistic.burnedCalories = Int16(burnedCalories)
        statistic.duration = duration
        
        return statistic
    }
}
