// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NewTimerForm",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "NewTimerForm",
            targets: ["NewTimerForm"]),
    ],
    dependencies: [
        .package(path: "../CorePersistence"),
        .package(path: "../CoreInterface"),
    ],
    targets: [
        .target(
            name: "NewTimerForm",
            dependencies: [
                "CorePersistence",
                "CoreInterface"
            ]),
        .testTarget(
            name: "NewTimerFormTests",
            dependencies: ["NewTimerForm"]),
    ]
)
