// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.29"
let checksum = "9050af347cb8389fa7f0aaa041acd7b77696bc3bacf968c9301e114fd18ee00c"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.0.29/DianyaaiASR.xcframework.zip"

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
