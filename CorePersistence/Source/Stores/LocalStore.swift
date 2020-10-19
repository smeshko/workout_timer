import Combine

struct LocalStore: Store {
    private let client: CoreDataClient

    init(client: CoreDataClient) {
        self.client = client
    }

    func delete<T>(_ object: T) -> AnyPublisher<Void, PersistenceError> where T : DomainEntity {
        client
            .delete(object)
            .mapError { _ in PersistenceError.generalError }
            .eraseToAnyPublisher()
    }

    func create<T>(_ object: T) -> AnyPublisher<T, PersistenceError> where T : DomainEntity {
        
        client
            .insert(object)
            .mapError { _ in PersistenceError.generalError }
            .eraseToAnyPublisher()

    }
}
