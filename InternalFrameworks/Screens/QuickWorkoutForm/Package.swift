// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickWorkoutForm",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "QuickWorkoutForm",
            targets: ["QuickWorkoutForm"]),
    ],
    dependencies: [
        .package(path: "../CorePersistence"),
        .package(path: "../CoreLogic"),
        .package(path: "../CoreInterface"),
    ],
    targets: [
        .target(
            name: "QuickWorkoutForm",
            dependencies: [
                "CorePersistence",
                "CoreLogic",
                "CoreInterface"
            ]),
        .testTarget(
            name: "QuickWorkoutFormTests",
            dependencies: ["QuickWorkoutForm"]),
    ]
)
