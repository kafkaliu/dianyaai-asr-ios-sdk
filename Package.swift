// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.10"
let checksum = "ec19d9a1d9e8aa0742c5403d9308e3e3943af45b8befa102c48eb3bf60e5daed"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.7/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "dianyaai-asr-ios-sdk",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "DianyaaiASR",
            targets: ["DianyaaiASRWrapper"]
        )
    ],

    targets: [
        .target(
            name: "DianyaaiASRWrapper",
            dependencies: [
                .target(name: "DianyaaiASRBinary")
            ]
        ),
        .binaryTarget(
            name: "DianyaaiASRBinary",
            url: url,
            checksum: checksum
        )
    ]
)
