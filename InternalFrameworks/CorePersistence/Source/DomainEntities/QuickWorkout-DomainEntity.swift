import DomainEntities
import CoreData

extension QuickWorkoutSegment: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickWorkoutSegmentDao {
        let segment = QuickWorkoutSegmentDao(context: context)
        segment.id = id
        segment.sets = Int16(sets)
        segment.work = Int16(work)
        segment.pause = Int16(pause)
        return segment
    }
}

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
