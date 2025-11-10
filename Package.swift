// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.17"
let checksum = "c8073146122695f65afa6df3c5ab80d328d126c471d73a3462b21c8cdc883675"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/1.0.17/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "DianyaaiASR", targets: ["DianyaaiASR"])
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ],
    targets: [
        .binaryTarget(
            name: "DianyaaiASRFramework",
            url: url,
            checksum: checksum
        ),
        .target(
            name: "DianyaaiASR",
            dependencies: [
                "DianyaaiASRFramework",
                .product(name: "Starscream", package: "Starscream")
            ]
        )
    ]
)
