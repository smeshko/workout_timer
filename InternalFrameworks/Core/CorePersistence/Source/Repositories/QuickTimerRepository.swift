import Combine
import Foundation
import DomainEntities

public struct QuickWorkoutsRepository {

    public var fetchAllWorkouts: () -> AnyPublisher<[QuickWorkout], PersistenceError>
    public var createWorkout: (QuickWorkout) -> AnyPublisher<QuickWorkout, PersistenceError>
    public var createSegment: (QuickWorkoutSegment) -> AnyPublisher<QuickWorkoutSegment, PersistenceError>
    public var updateWorkout: (QuickWorkout) -> AnyPublisher<QuickWorkout, PersistenceError>
    public var delete: (QuickWorkout) -> AnyPublisher<String, PersistenceError>
    public var deleteMultiple: ([QuickWorkout]) -> AnyPublisher<[String], PersistenceError>
}

public extension QuickWorkoutsRepository {
    static let live = QuickWorkoutsRepository(
        fetchAllWorkouts: { LocalStore(client: .shared).fetchAll(QuickWorkout.self) },
        createWorkout: LocalStore(client: .shared).create(_:),
        createSegment: LocalStore(client: .shared).create(_:),
        updateWorkout: LocalStore(client: .shared).update(_:),
        delete: LocalStore(client: .shared).delete(_:),
        deleteMultiple: LocalStore(client: .shared).delete(_:)
    )

    static let mock = QuickWorkoutsRepository(
        fetchAllWorkouts: { LocalStore(client: .preview).fetchAll(QuickWorkout.self) },
        createWorkout: LocalStore(client: .preview).create(_:),
        createSegment: LocalStore(client: .preview).create(_:),
        updateWorkout: LocalStore(client: .shared).update(_:),
        delete: LocalStore(client: .preview).delete(_:),
        deleteMultiple: LocalStore(client: .preview).delete(_:)
    )
}
