// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.17"
let checksum = "c8073146122695f65afa6df3c5ab80d328d126c471d73a3462b21c8cdc883675"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/1.0.17/DianyaaiASR.xcframework.zip"

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
