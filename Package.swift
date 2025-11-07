// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.5"
let checksum = "9b73e36f99918028d242d7a2a2e9e4ba65326f65900d379597a80a2ed888ff3a"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.5/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "DianyaaiASR",
            type: .dynamic,
            targets: ["DianyaaiASR"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ],
    targets: [
        .binaryTarget(
            name: "DianyaaiASRBinary",
            url: url,
            checksum: checksum
        ),
        .target(
            name: "DianyaaiASR",
            dependencies: [
                "DianyaaiASRBinary",
                .product(name: "Starscream", package: "Starscream")
            ]
        )
    ]
)
