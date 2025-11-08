// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.14"
let checksum = "66bdca1792b1e84e0119223e7587ebaaa5cb3e624c7a25ea6e0ab484719161ef"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/1.0.14/DianyaaiASR.xcframework.zip"

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
