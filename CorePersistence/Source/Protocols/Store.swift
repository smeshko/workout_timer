import Combine

public enum PersistenceError: Error {
    case generalError
}

protocol Store {
    func create<T: DomainEntity>(_ object: T) -> AnyPublisher<T, PersistenceError>
    func delete<T: DomainEntity>(_ object: T) -> AnyPublisher<Void, PersistenceError>
}

public class Repository {
    let store: LocalStore

    init() {
        store = LocalStore.init(client: .shared)
    }

    func createSet(_ set: QuickTimerSet) {
        let _ = store.create(set)
    }
}
