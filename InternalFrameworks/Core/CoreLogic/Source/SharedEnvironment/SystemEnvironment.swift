import ComposableArchitecture

@dynamicMemberLookup
public struct SystemEnvironment<Environment> {
    public let environment: Environment
    public let mainQueue: () -> AnySchedulerOf<DispatchQueue>
    public let uuid: () -> UUID

    public subscript<Dependency>(dynamicMember keyPath: KeyPath<Environment, Dependency>) -> Dependency {
        environment[keyPath: keyPath]
//        set { self.environment[keyPath: keyPath] = newValue }
    }

    /// Creates a live system environment with the wrapped environment provided.
    ///
    /// - Parameter environment: An environment to be wrapped in the system environment.
    /// - Returns: A new system environment.
    public static func live(environment: Environment) -> Self {
        Self(
            environment: environment,
            mainQueue: { DispatchQueue.main.eraseToAnyScheduler() },
            uuid: UUID.init
        )
    }

    /// Transforms the underlying wrapped environment.
    public func map<NewEnvironment>(_ transform: @escaping (Environment) -> NewEnvironment) -> SystemEnvironment<NewEnvironment> {
        .init(
            environment: transform(environment),
            mainQueue: mainQueue,
            uuid: uuid
        )
    }
}

#if DEBUG
public extension SystemEnvironment {
    static func mock(
        environment: Environment,
        mainQueue: @escaping () -> AnySchedulerOf<DispatchQueue> = { fatalError() },
        uuid: @escaping () -> UUID = { fatalError("UUID dependency is unimplemented.") }
    ) -> Self {
        Self(
            environment: environment,
            mainQueue: { mainQueue().eraseToAnyScheduler() },
            uuid: uuid
        )
    }
}
#endif
