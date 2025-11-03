// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.28"
let checksum = "f9c481ee1048bca103c772888396ae9f66cd7ce52180d380883e28886f11f8e4"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.0.28/DianyaaiASR.xcframework.zip"

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
