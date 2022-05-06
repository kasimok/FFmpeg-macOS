// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FFmpeg-macOS",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "FFmpeg-macOS",
            targets: [
                "avcodec", "avutil", "avformat", "avfilter", "swscale", "swresample", "Depend"]),
        .executable(name: "ffmpeg-macos", targets: ["Tool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
    ],
    targets: [
        .binaryTarget(name: "avcodec", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.0.5/avcodec.zip", checksum: "28ee95f74b13a6115107a5e5545364e092c32ab19c8ad337771a231dd51c2d1b"),
        .binaryTarget(name: "avutil", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.0.5/avutil.zip", checksum: "cbad714845d729f1743cfa14abb84604fed4df0505f492711dc79d746c25d1fb"),
        .binaryTarget(name: "avformat", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.0.5/avformat.zip", checksum: "fed613b37985889c0239afaca5fec9c859740d710fe315d5f52e8fb2c4619dd7"),
        .binaryTarget(name: "avfilter", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.0.5/avfilter.zip", checksum: "0767107807028a2cc91659ec9f730f430f3ebd28fa8171ba85715b9925320868"),
        .binaryTarget(name: "avdevice", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.0.5/avdevice.zip", checksum: "15b3f685b5224a7c85f4466d603b86bf85ddefa4f2f64dfab71c59c78796d8d6"),
        .binaryTarget(name: "swscale", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.0.5/swscale.zip", checksum: "44871fae5ade40aa231aa95b8a4abb584f1dfdd6bd481d968db730b2e461124c"),
        .binaryTarget(name: "swresample", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.0.5/swresample.zip", checksum: "74e6087dab9ba1cd3aab3ad4a2a0b9ea5aebda72901641a153b40caa21907e9f"),
        .target(name: "Tool", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .target(name: "Depend",
                linkerSettings: [
                    .linkedLibrary("z"),
                    .linkedLibrary("bz2"),
                    .linkedLibrary("iconv"),
                ]
        ),
    ]
)
