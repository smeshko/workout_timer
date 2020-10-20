import Combine

public class QuickTimerRepository {

    private let store: LocalStore

    public init() {
        store = LocalStore(client: .shared)
    }

    public func fetchAllSets() -> AnyPublisher<[QuickTimerSet], PersistenceError> {
        store.fetchAll(QuickTimerSet.self)
    }

    public func createTimerSet(_ set: QuickTimerSet) -> AnyPublisher<QuickTimerSet, PersistenceError> {
        store.create(set)
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

    public func delete(_ workout: QuickWorkout) -> AnyPublisher<Void, PersistenceError> {
        store.delete(workout)
    }
}
