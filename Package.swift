// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.8"
let checksum = "c56f454b0a6e6c69324d767001d274d2789297b17ab94b36d1023aca66bd3a9e"
let url = "https://kafkaliu.github.io/dianyaai-asr-ios-sdk/binaries/0.0.8/DianyaaiASR.xcframework.zip"

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
