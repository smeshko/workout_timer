import Foundation
import CoreData

public struct QuickWorkout: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let color: WorkoutColor
    public let segments: [QuickWorkoutSegment]

    public init(id: UUID, name: String, color: WorkoutColor, segments: [QuickWorkoutSegment]) {
        self.id = id
        self.name = name
        self.color = color
        self.segments = segments
    }
}

extension QuickWorkout: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickWorkoutDao {
        let workout = QuickWorkoutDao(context: context)
        workout.name = name
        workout.colorHue = color.hue
        workout.colorBrightness = color.brightness
        workout.colorSaturation = color.saturation
        workout.segments = NSOrderedSet(array: segments.map { $0.createDatabaseEntity(in: context) })
        return workout
    }
}
