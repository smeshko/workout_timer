// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RunningTimer",
    platforms: [
        .macOS(.v10_15),
        .iOS("15.0"),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "RunningTimer",
            targets: ["RunningTimer"]),
    ],
    dependencies: [
        .package(path: "../CoreInterface"),
        .package(path: "../CorePersistence"),

    ],
    targets: [
        .target(
            name: "RunningTimer",
            dependencies: [
                "CoreInterface",
                "CorePersistence"
            ]),
        .testTarget(
            name: "RunningTimerTests",
            dependencies: ["RunningTimer"]),
    ]
)
