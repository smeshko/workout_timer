// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickWorkoutsList",
    platforms: [
        .iOS("15.0"),
        .macOS(.v10_15),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "QuickWorkoutsList",
            targets: ["QuickWorkoutsList"]),
    ],
    dependencies: [
        .package(path: "../WorkoutSettings"),
        .package(path: "../RunningTimer"),
        .package(path: "../QuickWorkoutForm"),
    ],
    targets: [
        .target(
            name: "QuickWorkoutsList",
            dependencies: [
                "QuickWorkoutForm",
                "RunningTimer",
                "WorkoutSettings"
            ]),
        .testTarget(
            name: "QuickWorkoutsListTests",
            dependencies: ["QuickWorkoutsList"]),
    ]
)
