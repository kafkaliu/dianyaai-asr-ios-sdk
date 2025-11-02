// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.11"
let checksum = "9847bd6acb9af8387dc7af6b7a210244d450791e51e82d2eafe290d37a7de4fb"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/v0.0.11/DianyaaiASR.xcframework.zip"

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
