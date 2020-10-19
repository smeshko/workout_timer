import Combine

public enum PersistenceError: Error {
    case generalError
}

protocol Store {
    func create<T: DomainEntity>(_ object: T) -> AnyPublisher<T, PersistenceError>
    func delete<T: DomainEntity>(_ object: T) -> AnyPublisher<Void, PersistenceError>
    func fetchAll<T: DomainEntity>(_ type: T.Type) -> AnyPublisher<[T], PersistenceError>
}
