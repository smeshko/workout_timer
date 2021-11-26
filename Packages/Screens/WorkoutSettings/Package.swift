// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkoutSettings",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "WorkoutSettings",
            targets: ["WorkoutSettings"]),
    ],
    dependencies: [
        .package(path: "../CoreInterface"),
    ],
    targets: [
        .target(
            name: "WorkoutSettings",
            dependencies: [
                "CoreInterface"
            ]),
        .testTarget(
            name: "WorkoutSettingsTests",
            dependencies: ["WorkoutSettings"]),
    ]
)
