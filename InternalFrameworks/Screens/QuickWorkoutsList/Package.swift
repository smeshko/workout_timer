// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickWorkoutsList",
    platforms: [
//        .macOS(.v10_14),
        .iOS(.v14)
//        , .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "QuickWorkoutsList",
            targets: ["QuickWorkoutsList"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.10.0"),
//        .package(path: "../DomainEntities"),
        .package(path: "../WorkoutSettings"),
        .package(path: "../RunningTimer"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "QuickWorkoutsList",
            dependencies: [
                "RunningTimer",
                "WorkoutSettings"
            ]),
        .testTarget(
            name: "QuickWorkoutsListTests",
            dependencies: ["QuickWorkoutsList"]),
    ]
)
