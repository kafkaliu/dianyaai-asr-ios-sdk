// swift-tools-version:6.1
import PackageDescription

let version = "0.0.4"
let checksum = "c940530348154c986db7a6f4dc1ccca25a61c345e269e0a87d9a62345a08bf10"
let url = "https://kafkaliu.github.io/dianyaai-asr-ios-sdk/binaries/0.0.4/DianyaaiASR.xcframework.zip"

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
