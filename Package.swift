// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.18"
let checksum = "94ea11bf5974d6d7f6704239b34c44099163fcd1745412d0b632e751d179b9e9"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/1.0.18/DianyaaiASR.xcframework.zip"

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
