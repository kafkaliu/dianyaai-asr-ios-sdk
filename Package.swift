// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.27"
let checksum = "53ffd52157f409c7827f72bbbe4acf93f3665df6ff4002d0a6e2239efdb2305c"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/v0.0.27/DianyaaiASR.xcframework.zip"

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
