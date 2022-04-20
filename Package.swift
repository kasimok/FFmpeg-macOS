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
        .binaryTarget(name: "avcodec", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.02/avcodec.zip", checksum: "836bb7cfc4cb968d90a0895fb2df06cf0228edf32ce3db4db57ec9d286a948d5"),
        .binaryTarget(name: "avutil", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.02/avutil.zip", checksum: "93d171d28a83a8531eafd921293ad9cd997bb5d3c1486456a1fe691843e0f2f8"),
        .binaryTarget(name: "avformat", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.02/avformat.zip", checksum: "872a6e1ff8fde573fcc0e50ed96aa070c745bd0623b6e0ae4bb31ebf2aa0f8bd"),
        .binaryTarget(name: "avfilter", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.02/avfilter.zip", checksum: "c34218e8ca1bfb30207bfcbb4c5320dfb679a87fddd5ca0fec10983e5c61600d"),
        .binaryTarget(name: "avdevice", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.02/avdevice.zip", checksum: "40e488270a7cf220a0d35459a6b4a8f56183b7193a4b35a4f9e8efd5c30c9438"),
        .binaryTarget(name: "swscale", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.02/swscale.zip", checksum: "b5f68cdee2352061c59b4ea1af07cc1cf093935965eb698694c91fbc884ad6a5"),
        .binaryTarget(name: "swresample", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.02/swresample.zip", checksum: "e58ba540eee642b6a8f0fe3fb6c14679372f4817309335431d2a1e4d930de384"),
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
