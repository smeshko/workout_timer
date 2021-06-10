// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreLogic",
    platforms: [
        .macOS(.v10_15),
        .iOS("15.0"),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "CoreLogic",
            targets: ["CoreLogic"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.15.0"),
    ],
    targets: [
        .target(
            name: "CoreLogic",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [
                .process("Assets/round_over.m4a")
            ]
        ),
        .testTarget(
            name: "CoreLogicTests",
            dependencies: ["CoreLogic"]),
    ]
)
