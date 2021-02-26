// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickWorkoutsList",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
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
