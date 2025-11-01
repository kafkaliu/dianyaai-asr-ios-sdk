// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// 这些值将被自动化脚本更新
let version = "1.0.0"
let checksum = "YOUR_CHECKSUM_HERE" // 占位符
let url = "https://kafkaliu.github.io/dianyaai-asr-ios-sdk/binaries/\(version)/DianyaaiASR.xcframework.zip" // 占位符

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v15)
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