// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimersList",
    platforms: [
        .iOS("15.0"),
        .macOS(.v10_15),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "TimersList",
            targets: ["TimersList"]),
    ],
    dependencies: [
        .package(path: "../WorkoutSettings"),
        .package(path: "../RunningTimer"),
        .package(path: "../QuickWorkoutForm"),
        .package(path: "../CoreInterface")
    ],
    targets: [
        .target(
            name: "TimersList",
            dependencies: [
                "QuickWorkoutForm",
                "RunningTimer",
                "WorkoutSettings",
                "CoreInterface"
            ]),
        .testTarget(
            name: "TimersListTests",
            dependencies: ["TimersList"]),
    ]
)
