// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.31"
let checksum = "2a7fe848dbfdac1c630e6ebf57d5d50acb6902052a8264662dec75811cad0195"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.0.31/DianyaaiASR.xcframework.zip"

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
