// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "DianyaaiASR",
    platforms: [
        .iOS(.v14) // 确保这是你支持的最低版本
    ],
    products: [
        // 这是你的 App 最终要链接的库
        .library(
            name: "DianyaaiASR",
            targets: ["DianyaaiASRWrapper"]) // 指向下面的“包装 Target”
    ],
    dependencies: [
        // 包的依赖
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8")
    ],
    targets: [
        // 1. “包装 Target”（粘合剂）
        // 它会告诉 Xcode：任何链接我的人，也必须链接我的依赖。
        .target(
            name: "DianyaaiASRWrapper",
            dependencies: [
                .target(name: "DianyaaiASRBinary"), // 依赖 1: 你的二进制文件
                .product(name: "Starscream", package: "Starscream") // 依赖 2: Starscream
            ],
            path: "Sources/DianyaaiASRWrapper" // 指向你刚创建的文件夹
        ),
        
        // 2. 你的二进制文件 Target
        .binaryTarget(
            name: "DianyaaiASRBinary",
            path: "./DianyaaiASR.xcframework" // 相对于 Package.swift 的路径
        )
    ]
)
