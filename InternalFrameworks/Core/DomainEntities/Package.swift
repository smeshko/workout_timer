// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DomainEntities",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "DomainEntities",
            targets: ["DomainEntities"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DomainEntities",
            dependencies: []),
        .testTarget(
            name: "DomainEntitiesTests",
            dependencies: ["DomainEntities"]),
    ]
)
