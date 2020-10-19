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
}
