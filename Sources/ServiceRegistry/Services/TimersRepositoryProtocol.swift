import Foundation
import DomainEntities

public protocol TimersRepositoryProtocol {
    func fetchAll() async throws -> [QuickWorkout]
    func create(_ workout: QuickWorkout) async throws -> QuickWorkout
    func create(_ segment: QuickWorkoutSegment) async throws -> QuickWorkoutSegment
    func update(_ workout: QuickWorkout) async throws -> QuickWorkout
    func delete(_ workout: QuickWorkout) async throws -> String
    func delete(_ workouts: [QuickWorkout]) async throws -> [String]
}
