import Foundation
import CoreData

public struct QuickWorkout: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let segments: [QuickWorkoutSegment]

    public init(id: UUID, name: String, segments: [QuickWorkoutSegment]) {
        self.id = id
        self.name = name
        self.segments = segments
    }
}

public struct QuickWorkoutSegment: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let sets: Int
    public let work: Int
    public let pause: Int

    public init(id: UUID, sets: Int, work: Int, pause: Int) {
        self.id = id
        self.sets = sets
        self.work = work
        self.pause = pause
    }
}

extension QuickWorkout: DomainEntity {
    var objectId: String { id.uuidString }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> QuickWorkoutDao {
        let workout = QuickWorkoutDao(context: context)
        workout.name = name
        workout.segments = NSOrderedSet(array: segments.map { $0.createDatabaseEntity(in: context) })
        return workout
    }
}

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
