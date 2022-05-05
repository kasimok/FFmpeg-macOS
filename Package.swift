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
        .binaryTarget(name: "avcodec", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.04/avcodec.zip", checksum: "0e7174e527e3663da21bf6a2fe54396ed7e2f6a1d46bae70054576e1a5b5da4a"),
        .binaryTarget(name: "avutil", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.04/avutil.zip", checksum: "aaecc116e362b501c6c3b805629ffd26c6ef71acd4dc5699c7b18473847b4aec"),
        .binaryTarget(name: "avformat", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.04/avformat.zip", checksum: "c22efae71aff3be3cc52b44f0798794f4f63e445aeba0b72cc03429caa2fae24"),
        .binaryTarget(name: "avfilter", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.04/avfilter.zip", checksum: "0abd821b9f5e1fd565b89f4ffe7692b1646c1e37128ca1a32b51a1195a619ab7"),
        .binaryTarget(name: "avdevice", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.04/avdevice.zip", checksum: "52b73b18caccf13e61566d72d8d55c0e80ad33324e2465f27a79b0ce117190f3"),
        .binaryTarget(name: "swscale", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.04/swscale.zip", checksum: "26e96d74a62e95c5e9475887142be0de4528b56e57aae1d11b7652f8040623c4"),
        .binaryTarget(name: "swresample", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.04/swresample.zip", checksum: "85d52ef246655d08bda250a5f43118ea4f9271476f5ca309cfe655393045bf52"),
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
