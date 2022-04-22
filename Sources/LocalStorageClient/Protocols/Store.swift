public enum PersistenceError: Error {
    case generalError
}

protocol Store {
    func create<T: DomainEntity>(_ object: T) async throws -> T
    func delete<T: DomainEntity>(_ object: T) async throws -> String
    func delete<T: DomainEntity>(_ objects: [T]) async throws -> [String]
    func fetchAll<T: DomainEntity>(_ type: T.Type) async throws -> [T]
    func update<T: DomainEntity>(_ object: T) async throws -> T.EntityObject.Entity
}
