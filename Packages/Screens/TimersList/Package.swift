// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimersList",
    platforms: [
        .iOS(.v15),
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
        .package(path: "../NewTimerForm"),
        .package(path: "../CoreInterface")
    ],
    targets: [
        .target(
            name: "TimersList",
            dependencies: [
                "NewTimerForm",
                "RunningTimer",
                "WorkoutSettings",
                "CoreInterface"
            ]),
        .testTarget(
            name: "TimersListTests",
            dependencies: ["TimersList"]),
    ]
)
