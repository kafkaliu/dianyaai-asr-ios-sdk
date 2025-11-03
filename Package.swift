// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.30"
let checksum = "f2df4ecbcbc31b683ec3c67d4aeea960284c2289a686bdfc668dc209450d59ef"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.0.30/DianyaaiASR.xcframework.zip"

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
