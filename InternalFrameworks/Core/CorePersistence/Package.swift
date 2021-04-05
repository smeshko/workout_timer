// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CorePersistence",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "CorePersistence",
            targets: ["CorePersistence"]),
    ],
    dependencies: [
        .package(path: "../DomainEntities")
    ],
    targets: [
        .target(
            name: "CorePersistence",
            dependencies: [
                "DomainEntities"
            ]),
        .testTarget(
            name: "CorePersistenceTests",
            dependencies: ["CorePersistence"],
            resources: [
                .process("CoreData/WorkoutTimer.xcdatamodel")
            ]),
    ]
)