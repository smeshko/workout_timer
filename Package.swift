// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "TimerApp",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        .library(name: "ServiceRegistry", targets: ["ServiceRegistry"]),
        .library(name: "TestMocks", targets: ["TestMocks"]),
        .library(name: "TestUtilities", targets: ["TestUtilities"]),
        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "LocalStorageClient", targets: ["LocalStorageClient"]),
        .library(name: "CalorieCalculatorClient", targets: ["CalorieCalculatorClient"]),
        .library(name: "SettingsClient", targets: ["SettingsClient"]),
        .library(name: "LocalNotificationClient", targets: ["LocalNotificationClient"]),

        .library(product: .entities),
        .library(product: .coreLogic),
        .library(product: .coreInterface),
        .library(product: .corePersistence),
        .library(product: .settingsFeature),
        .library(product: .runningTimerFeature),
        .library(product: .newTimerFeature),
        .library(product: .timersListFeature),
        .library(product: .appFeature),
    ],
    dependencies: [
        .package(dependency: .composableArchitecture),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "ServiceRegistry", dependencies: [.product(name: "Collections", package: "swift-collections")]),

        .target(name: "TestUtilities", dependencies: []),
        .target(name: "TestMocks", dependencies: ["TestUtilities", "ServiceRegistry"]),

        .target(name: "NetworkClient", dependencies: ["ServiceRegistry"]),
        .testTarget(name: "NetworkClientTests", dependencies: ["NetworkClient", "TestUtilities", "TestMocks"]),

        .target(name: "LocalStorageClient", dependencies: ["ServiceRegistry", "DomainEntities"]),
        .testTarget(name: "LocalStorageClientTests", dependencies: ["LocalStorageClient", "TestUtilities", "TestMocks"]),

        .target(name: "CalorieCalculatorClient", dependencies: ["ServiceRegistry"]),
        .testTarget(name: "CalorieCalculatorClientTests", dependencies: ["CalorieCalculatorClient", "TestUtilities", "TestMocks"]),

        .target(name: "SettingsClient", dependencies: ["ServiceRegistry"]),
        .testTarget(name: "SettingsClientTests", dependencies: ["SettingsClient", "TestUtilities", "TestMocks"]),

        .target(name: "LocalNotificationClient", dependencies: ["ServiceRegistry"]),
        .testTarget(name: "LocalNotificationClientTests", dependencies: ["LocalNotificationClient", "TestUtilities", "TestMocks"]),
        .target(product: .entities),
        .target(product: .corePersistence, dependencies: [Products.entities]),
        .target(product: .coreInterface, dependencies: [Products.entities, Dependencies.composableArchitecture]),
        .target(product: .coreLogic, dependencies: [Dependencies.composableArchitecture], resources: [.roundOver]),

        .target(product: .settingsFeature, dependencies: [Products.coreInterface, .coreLogic]),
        .target(product: .runningTimerFeature, dependencies: [Products.coreInterface, .corePersistence, .coreLogic]),
        .target(product: .newTimerFeature, dependencies: [Products.coreInterface, .corePersistence, .coreLogic]),
        .target(product: .timersListFeature, dependencies: [Products.settingsFeature, .runningTimerFeature, .newTimerFeature]),
        .target(product: .appFeature, dependencies: [Products.settingsFeature, .runningTimerFeature, .newTimerFeature, .timersListFeature]),

    ]
)

protocol AppDependency {
    var dependency: Target.Dependency { get }
}

enum Dependencies: AppDependency {
    case composableArchitecture

    var url: String {
        switch self {
        case .composableArchitecture: return "https://github.com/pointfreeco/swift-composable-architecture"
        }
    }

    var version: Version {
        switch self {
        case .composableArchitecture: return "0.33.0"
        }
    }

    var dependency: Target.Dependency {
        switch self {
        case .composableArchitecture:
            return .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        }

    }
}

enum Products: String, AppDependency {
    case entities = "DomainEntities"
    case coreLogic = "CoreLogic"
    case coreInterface = "CoreInterface"
    case corePersistence = "CorePersistence"
    case settingsFeature = "SettingsFeature"
    case runningTimerFeature = "RunningTimerFeature"
    case newTimerFeature = "NewTimerFeature"
    case timersListFeature = "TimersListFeature"
    case appFeature = "AppFeature"

    var dependency: Target.Dependency { Target.Dependency(stringLiteral: rawValue) }
}

enum Resources {
    case roundOver

    var resource: Resource {
        switch self {
        case .roundOver:
            return .process("Assets/round_over.m4a")
        }
    }
}

extension Package.Dependency {
    static func package(dependency: Dependencies) -> Package.Dependency {
        .package(url: dependency.url, from: dependency.version)
    }
}

extension Product {
    static func library(product: Products) -> Product {
        .library(name: product.rawValue, targets: [product.rawValue])
    }
}

extension Target {
    static func target(product: Products, dependencies: [AppDependency] = [], resources: [Resources] = []) -> Target {
        .target(name: product.rawValue, dependencies: dependencies.map(\.dependency), resources: resources.map(\.resource))
    }
}
