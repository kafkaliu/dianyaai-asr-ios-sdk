// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.4"
let checksum = "42f03b34ae4dcd788cd977193da1de120f1b19d3ed1aebd15f3aae74971e4351"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.4/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DianyaaiASR",
            type: .dynamic,
            targets: ["DianyaaiASR"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DianyaaiASR",
            dependencies: ["Starscream"]
        ),
        .testTarget(
            name: "DianyaaiASRTests",
            dependencies: ["DianyaaiASR"],
            resources: [
                .copy("IntegrationTestData")
            ]
        ),
    ]
)
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DianyaaiASR"
            type: .dynamic
            targets: ["DianyaaiASR"]
        )
    ]
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ]
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DianyaaiASR"
            dependencies: ["Starscream"]
        )
        .testTarget(
            name: "DianyaaiASRTests"
            dependencies: ["DianyaaiASR"]
            resources: [
                .copy("IntegrationTestData")
            ]
        )
    ]
),
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DianyaaiASR",
            dependencies: ["Starscream"]
        ),
        .testTarget(
            name: "DianyaaiASRTests",
            dependencies: ["DianyaaiASR"],
            resources: [
                .copy("IntegrationTestData")
            ]
        ),
    ]
)
    targets: [
        .binaryTarget(
            name: "DianyaaiASRBinary",
            url: url,
            checksum: checksum
        ),
        .target(
            name: "DianyaaiASR",
            dependencies: [
                "DianyaaiASRBinary"
            ]
        )
    ]
)
