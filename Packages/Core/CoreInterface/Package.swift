// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreInterface",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15),
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
    ],
    targets: [
        .target(
            name: "CoreInterface",
            dependencies: [
                "DomainEntities",
                "CoreLogic"
            ]),
        .testTarget(
            name: "CoreInterfaceTests",
            dependencies: ["CoreInterface"]),
    ]
)
