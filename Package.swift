// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.23"
let checksum = "bc191bc94847c8e39065f4c19614a2f7a2aff0e6669bc1ca2614cbf9da719bed"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/v0.0.23/DianyaaiASR.xcframework.zip"

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
