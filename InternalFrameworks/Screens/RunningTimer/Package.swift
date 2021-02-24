// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RunningTimer",
    platforms: [
//        .macOS(.v10_14),
        .iOS(.v14)
//        , .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RunningTimer",
            targets: ["RunningTimer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.10.0"),
        .package(path: "../DomainEntities"),
        .package(path: "../CoreLogic"),
        .package(path: "../CoreInterface"),
        .package(path: "../CorePersistence"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RunningTimer",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DomainEntities",
                "CoreLogic",
                "CoreInterface",
                "CorePersistence"
            ]),
        .testTarget(
            name: "RunningTimerTests",
            dependencies: ["RunningTimer"]),
    ]
)
