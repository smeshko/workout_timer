// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreInterface",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "CoreInterface",
            targets: ["CoreInterface"]),
    ],
    dependencies: [
        .package(path: "../DomainEntities"),
        .package(path: "../CoreLogic"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.10.0"),
    ],
    targets: [
        .target(
            name: "CoreInterface",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DomainEntities",
                "CoreLogic"
            ]),
        .testTarget(
            name: "CoreInterfaceTests",
            dependencies: ["CoreInterface"]),
    ]
)
