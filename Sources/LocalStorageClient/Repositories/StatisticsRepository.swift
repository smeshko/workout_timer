import Foundation
import DomainEntities
import ServiceRegistry

public class StatisticsRepository: StatisticsRepositoryProtocol {
    private let storage: Store

    public init() {
        storage = LocalStorageService()
    }

    init(storage: Store){
        self.storage = storage
    }

    public func fetchAll() async throws -> [Statistic] {
        try await storage.fetchAll(Statistic.self)
    }

    public func finish(_ workout: FinishedWorkout, calories: Int) async throws -> Statistic {
        try await storage.create(Statistic(workout: workout, calories: calories))
    }
}

private extension Statistic {
    init(workout: FinishedWorkout, calories: Int) {
        self.init(
            id: UUID(),
            workoutName: workout.workout.name,
            duration: workout.totalDuration,
            startDate: workout.startDate,
            finishDate: workout.finishDate,
            burnedCalories: calories
        )
    }
}
