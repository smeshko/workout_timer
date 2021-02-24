// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RunningTimer",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
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
