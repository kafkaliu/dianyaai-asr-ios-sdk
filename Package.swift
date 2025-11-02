// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.17"
let checksum = "40b43fd599d6f1f4e2bfa5336fe7d7a861cae080f8f52e539176736c71754ef8"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/v0.0.17/DianyaaiASR.xcframework.zip"

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
