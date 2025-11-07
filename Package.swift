// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.8"
let checksum = "ec19d9a1d9e8aa0742c5403d9308e3e3943af45b8befa102c48eb3bf60e5daed"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.7/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "dianyaai-asr-ios-sdk",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "DianyaaiASR",
            targets: ["DianyaaiASR"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ],
    targets: [
        .target(
            name: "DianyaaiASR",
            dependencies: [
                .target(name: "DianyaaiASRBinary"),
                .product(name: "Starscream", package: "Starscream")
            ]
        ),
        .binaryTarget(
            name: "DianyaaiASRBinary",
            url: url,
            checksum: checksum
        )
    ]
)
