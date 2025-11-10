// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.19"
let checksum = "1e8c546d6a1cabd98c8ee2ad8aebb7eff551b75bb1b90ebcb653a704788e59d7"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/1.0.19/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v14)
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
