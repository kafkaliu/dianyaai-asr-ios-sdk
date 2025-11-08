// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.16"
let checksum = "51152db1bc9df2f77f8a98f8bf2295348b491ba5851f7211c5b6fe1f208b9fb8"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/1.0.16/DianyaaiASR.xcframework.zip"

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
