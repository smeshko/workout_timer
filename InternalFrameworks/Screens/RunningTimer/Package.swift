// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RunningTimer",
    platforms: [
//        .macOS(.v10_14),
        .iOS(.v14)
//        , .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RunningTimer",
            targets: ["RunningTimer"]),
    ],
    dependencies: [
        .package(path: "../DomainEntities"),
        .package(path: "../CoreLogic"),
        .package(path: "../CoreInterface"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RunningTimer",
            dependencies: [
                "DomainEntities",
                "CoreLogic",
                "CoreInterface"
            ]),
        .testTarget(
            name: "RunningTimerTests",
            dependencies: ["RunningTimer"]),
    ]
)
