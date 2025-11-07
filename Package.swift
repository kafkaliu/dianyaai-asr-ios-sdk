// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.13"
let checksum = "f3fb40c06c68779cde51857587da6374ae65e5b73a38ab2f597bb016b69d0355"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/1.0.13/DianyaaiASR.xcframework.zip"

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
