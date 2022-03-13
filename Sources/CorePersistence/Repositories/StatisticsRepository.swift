import Combine
import Foundation
import DomainEntities

public struct StatisticsRepository {

    public var fetchAll: () -> AnyPublisher<[Statistic], PersistenceError>
    public var finish: (FinishedWorkout, Int) -> AnyPublisher<Statistic, PersistenceError>
}

public extension StatisticsRepository {
    static let live = StatisticsRepository(
        fetchAll: { LocalStore(client: .shared).fetchAll(Statistic.self) },
        finish: { LocalStore(client: .shared).create(Statistic(workout: $0, calories: $1)) }
    )

    static let mock = StatisticsRepository(
        fetchAll: { LocalStore(client: .preview).fetchAll(Statistic.self) },
        finish: { LocalStore(client: .preview).create(Statistic(workout: $0, calories: $1)) }
    )
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
