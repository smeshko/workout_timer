import Combine

public class QuickWorkoutsRepository {

    private let store: LocalStore

    public init() {
        store = LocalStore(client: .shared)
    }

    public func fetchAllWorkouts() -> AnyPublisher<[QuickWorkout], PersistenceError> {
        store.fetchAll(QuickWorkout.self)
    }

    public func createWorkout(_ workout: QuickWorkout) -> AnyPublisher<QuickWorkout, PersistenceError> {
        store.create(workout)
    }

    public func createSegment(_ segment: QuickWorkoutSegment) -> AnyPublisher<QuickWorkoutSegment, PersistenceError> {
        store.create(segment)
    }

    public func delete(_ workout: QuickWorkout) -> AnyPublisher<String, PersistenceError> {
        store.delete(workout)
    }

    public func delete(_ workouts: [QuickWorkout]) -> AnyPublisher<[String], PersistenceError> {
        store.delete(workouts)
    }
}
