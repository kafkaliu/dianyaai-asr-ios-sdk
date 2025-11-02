// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.10"
let checksum = "99f8f49c7813181c87a4a81012bae33ef6bbbf240dc5840cdd0af43e8ecca2dc"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk-source/releases/download/v0.0.10/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "DianyaaiASR", targets: ["DianyaaiASR"])
    ],
    targets: [
        .binaryTarget(
            name: "DianyaaiASR",
            url: url,
            checksum: checksum
        )
    ]
)
