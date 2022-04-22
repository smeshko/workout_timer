import ServiceRegistry

class LocalStorageService: Store {
    private let client: DatabaseClientProtocol

    public init() {
        client = CoreDataClient.shared
    }

    init(client: DatabaseClientProtocol) {
        self.client = client
    }

    func fetchAll<T: DomainEntity>(_ type: T.Type) async throws -> [T] {
        try await client.fetchAll(type)
    }

    func delete<T: DomainEntity>(_ object: T) async throws -> String {
        try await client.delete(object)
    }

    func create<T: DomainEntity>(_ object: T) async throws -> T {
        try await client.insert(object)
    }

    func delete<T: DomainEntity>(_ objects: [T]) async throws -> [String] {
        try await objects.asyncMap { try await client.delete($0) }
    }

    func update<T: DomainEntity>(_ object: T) async throws -> T.EntityObject.Entity {
        try await client.update(object)
    }
}

extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
