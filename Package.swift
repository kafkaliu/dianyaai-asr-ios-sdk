// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.0"
let checksum = "5d6fd3f211ae77814a93dbcd76aec4a18b9ceb9acb786b22e8ad358fb0786e26"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.0/DianyaaiASR.xcframework.zip"

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
