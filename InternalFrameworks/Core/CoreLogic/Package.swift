// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreLogic",
    platforms: [
//        .macOS(.v10_14),
        .iOS(.v14)
//        , .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CoreLogic",
            type: .dynamic,
            targets: ["CoreLogic"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreLogic",
            dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture")]),
        .testTarget(
            name: "CoreLogicTests",
            dependencies: ["CoreLogic"]),
    ]
)
