import ComposableArchitecture

@dynamicMemberLookup
public struct SystemEnvironment<Environment> {
    public let environment: Environment
    public let mainQueue: () -> AnySchedulerOf<DispatchQueue>
    public let settings: SettingsClient
    public let uuid: () -> UUID

    public subscript<Dependency>(dynamicMember keyPath: KeyPath<Environment, Dependency>) -> Dependency {
        environment[keyPath: keyPath]
    }

    /// Creates a live system environment with the wrapped environment provided.
    ///
    /// - Parameter environment: An environment to be wrapped in the system environment.
    /// - Returns: A new system environment.
    public static func live(environment: Environment) -> Self {
        Self(
            environment: environment,
            mainQueue: { DispatchQueue.main.eraseToAnyScheduler() },
            settings: .live,
            uuid: UUID.init
        )
    }

    /// Transforms the underlying wrapped environment.
    public func map<NewEnvironment>(_ transform: @escaping (Environment) -> NewEnvironment) -> SystemEnvironment<NewEnvironment> {
        .init(
            environment: transform(environment),
            mainQueue: mainQueue,
            settings: settings,
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
            settings: .mock,
            uuid: uuid
        )
    }
}
#endif
