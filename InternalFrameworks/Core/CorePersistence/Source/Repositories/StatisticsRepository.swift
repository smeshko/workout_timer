import Combine
import Foundation
import DomainEntities

public struct StatisticsRepository {

    public var fetchAll: () -> AnyPublisher<[Statistic], PersistenceError>
    public var finish: (QuickWorkout) -> AnyPublisher<Statistic, PersistenceError>
}

public extension StatisticsRepository {
    static let live = StatisticsRepository(
        fetchAll: { LocalStore(client: .shared).fetchAll(Statistic.self) },
        finish: { LocalStore(client: .shared).create(Statistic(workout: $0)) }
    )

    static let mock = StatisticsRepository(
        fetchAll: { LocalStore(client: .preview).fetchAll(Statistic.self) },
        finish: { LocalStore(client: .preview).create(Statistic(workout: $0)) }
    )
}

private extension Statistic {
    init(workout: QuickWorkout) {
        self.init(
            id: UUID(),
            date: Date(),
            workoutName: workout.name,
            workoutDuration: Double(workout.duration)
        )
    }
}
