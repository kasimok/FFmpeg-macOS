// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FFmpeg-macOS",
    platforms: [.iOS(.v9)],
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
        .binaryTarget(name: "avcodec", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.01/avcodec.zip", checksum: "a1928af96dffd41b8c8fa05ec2b4f6b0795a7b64f909a3e625f36626ebfda169"),
        .binaryTarget(name: "avutil", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.01/avutil.zip", checksum: "1e96a3d0847fd9471b71eb8681c385bff888d4a35df42a4af4aa7a1e0491a9a9"),
        .binaryTarget(name: "avformat", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.01/avformat.zip", checksum: "4772a0dc37fbc5c82737f6345aad6ed2043907bc13afca0e6ce0c72cdeaa5cc5"),
        .binaryTarget(name: "avfilter", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.01/avfilter.zip", checksum: "311282c13527622c5cadad1730e0da2e707a9f9b802586b02d9737ee45655120"),
        .binaryTarget(name: "avdevice", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.01/avdevice.zip", checksum: "ca4f806c0e6c4414abd7e262895b70641831e1193bb78b69618bb20b7c2f4a70"),
        .binaryTarget(name: "swscale", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.01/swscale.zip", checksum: "388f493609a6a023fc6c5bbceb0bedd39e2a8de18aa27a786682cff733acd665"),
        .binaryTarget(name: "swresample", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.01/swresample.zip", checksum: "a443604a007f801ae7831c236cd5c58c78ac7598e1142e3f5e04c69c97d670e8"),
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
