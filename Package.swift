// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.3"
let checksum = "580f1be03c9b8e41b420571351d0a4fa2049b8d9db16344247a1f5f8983fbdcd"
let url = "https://github.com/kafkaliu/dianyaai-asr-ios-sdk/releases/download/0.1.3/DianyaaiASR.xcframework.zip"

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DianyaaiASR"
            type: .dynamic
            targets: ["DianyaaiASR"],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ],
            dependencies: ["Starscream"]
            dependencies: ["DianyaaiASR"],
    targets: [
        .binaryTarget(
            name: "DianyaaiASRBinary",
            url: url,
            checksum: checksum
        ),
        .target(
            name: "DianyaaiASR",
            dependencies: [
                "DianyaaiASRBinary"
                          .product(name: ".package(url:", package: ".package(url:")
                          .product(name: "https://github.com/daltoniam/Starscream.git", package: "https://github.com/daltoniam/Starscream.git")
                          .product(name: "from:", package: "from:")
                          .product(name: "4.0.8)", package: "4.0.8)")
            ]
        )
    ]
)
