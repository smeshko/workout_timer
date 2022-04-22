import Foundation
import TestUtilities
import DomainEntities
import ServiceRegistry

public class TimersRepositoryMock: MockBase, TimersRepositoryProtocol {
    public var allWorkouts: [QuickWorkout] = []
    public var workout: QuickWorkout?
    public var segment: QuickWorkoutSegment?
    public var deletedIds: [String] = []

    public func fetchAll() async throws -> [QuickWorkout] {
        track()
        return allWorkouts
    }

    public func create(_ workout: QuickWorkout) async throws -> QuickWorkout {
        track()
        return self.workout!
    }

    public func create(_ segment: QuickWorkoutSegment) async throws -> QuickWorkoutSegment {
        track()
        return self.segment!
    }

    public func update(_ workout: QuickWorkout) async throws -> QuickWorkout {
        track()
        return self.workout!
    }

    public func delete(_ workout: QuickWorkout) async throws -> String {
        track()
        return deletedIds.first!
    }

    public func delete(_ workouts: [QuickWorkout]) async throws -> [String] {
        track()
        return deletedIds
    }
}
