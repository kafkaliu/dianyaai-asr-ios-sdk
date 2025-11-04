// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.2"
let checksum = "15cbf68f4419f4f9051e3cc9fc7f768becb62dd11ae165047583aa3cc42b6968"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.2/DianyaaiASR.xcframework.zip"

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
