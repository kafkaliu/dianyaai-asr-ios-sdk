// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.26"
let checksum = "94518fecaa25245c8312991a1d64a7eeea007c13fd6f6e0c590b7587007b34f2"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/v0.0.26/DianyaaiASR.xcframework.zip"

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
