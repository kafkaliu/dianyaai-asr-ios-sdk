// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.1"
let checksum = "a974c2e4733d573623e08fccddf975a18878d6ab105ce9bfa8d45bacc60b608e"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.1/DianyaaiASR.xcframework.zip"

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
