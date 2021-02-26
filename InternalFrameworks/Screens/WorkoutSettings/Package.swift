// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkoutSettings",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "WorkoutSettings",
            targets: ["WorkoutSettings"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.10.0"),
        .package(path: "../DomainEntities"),
        .package(path: "../CoreLogic"),
        .package(path: "../CoreInterface"),
    ],
    targets: [
        .target(
            name: "WorkoutSettings",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DomainEntities",
                "CoreLogic",
                "CoreInterface"
            ]),
        .testTarget(
            name: "WorkoutSettingsTests",
            dependencies: ["WorkoutSettings"]),
    ]
)
