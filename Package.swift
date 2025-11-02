// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.6"
let checksum = "386d960a6fd6e9a27b1ace1bf069f0adcfd5023bf602fe82ac95b3da475f06b2"
let url = "https://kafkaliu.github.io/dianyaai-asr-ios-sdk/binaries/0.0.6/DianyaaiASR.xcframework.zip"

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
