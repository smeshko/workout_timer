import DomainEntities
import CoreData

extension QuickWorkout: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickWorkoutDao {
        let workout = QuickWorkoutDao(context: context)
        workout.id = id
        workout.name = name
        workout.colorHue = color.hue
        workout.colorBrightness = color.brightness
        workout.colorSaturation = color.saturation
        workout.segments = NSOrderedSet(array: segments.map { $0.createDatabaseEntity(in: context) })
        return workout
    }
}
