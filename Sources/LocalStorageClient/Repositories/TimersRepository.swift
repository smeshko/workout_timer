import Combine
import Foundation
import DomainEntities
import ServiceRegistry

public class TimersRepository: TimersRepositoryProtocol {
    private let storage: Store

    public init() {
        storage = LocalStorageService()
    }

    init(storage: Store){
        self.storage = storage
    }

    public func fetchAll() async throws -> [QuickWorkout] {
        try await storage.fetchAll(QuickWorkout.self)
    }

    public func create(_ workout: QuickWorkout) async throws -> QuickWorkout {
        try await storage.create(workout)
    }

    public func create(_ segment: QuickWorkoutSegment) async throws -> QuickWorkoutSegment {
        try await storage.create(segment)
    }

    public func update(_ workout: QuickWorkout) async throws -> QuickWorkout {
        try await storage.update(workout)
    }

    public func delete(_ workout: QuickWorkout) async throws -> String {
        try await storage.delete(workout)
    }

    public func delete(_ workouts: [QuickWorkout]) async throws -> [String] {
        try await storage.delete(workouts)
    }
}
