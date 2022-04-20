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
        .binaryTarget(name: "avcodec", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.03/avcodec.zip", checksum: "a8f7b40f4f8c508c109b843d062b6df68e124a8eacac3a4a74793c0429489753"),
        .binaryTarget(name: "avutil", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.03/avutil.zip", checksum: "2a2f1091658187dfacdc8eb22c2bfb5032805be0fca4e8714a2b6e02e1d0dd8d"),
        .binaryTarget(name: "avformat", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.03/avformat.zip", checksum: "33085a982864a14377403eefc6669767981acbb022773d6a532b3765ecf9b517"),
        .binaryTarget(name: "avfilter", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.03/avfilter.zip", checksum: "4c380b1e55cd2953e26474b44a2553c312d9481f5e3d41ecb7c78ccceb887f9f"),
        .binaryTarget(name: "avdevice", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.03/avdevice.zip", checksum: "3f93278845c93a9d7fa84f5b898114192594816b57f54b1269d6ae1c04395cb8"),
        .binaryTarget(name: "swscale", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.03/swscale.zip", checksum: "0686d9bb7ef12e40fcf276579247e4e108de392709b76d01f50f3c3b92f08caa"),
        .binaryTarget(name: "swresample", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.03/swresample.zip", checksum: "e16c135186d67bc9fb5aec5e997174f7334a0830cf04e967f9ce1ad64d693427"),
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
