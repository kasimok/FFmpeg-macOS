// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FFmpegKit",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "FFmpeg-macOS",
            targets: ["ffmpegkit",
                      "libavcodec",
                      "libavutil",
                      "libavdevice",
                      "libavformat",
                      "libavfilter",
                      "libswscale",
                      "libswresample",
                      "Depend"]),
        .executable(name: "ffmpeg-macos", targets: ["Tool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
    ],
    targets: [
        /* prebuild ffmpeg with below command
         ./macos.sh --enable-freetype \
         --enable-gpl \
         --enable-libvpx \
         --enable-macos-avfoundation \
         --enable-srt \
         --xcframework \
         --enable-x264 \
         --lts
         */
        
        
        .binaryTarget(name: "ffmpegkit", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/ffmpegkit.zip", checksum: "28155c41f2a9d034d932d4640f16f6795ba6b99c72afde9e1d94db51d1c58f05"),
        .binaryTarget(name: "libavcodec", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/libavcodec.zip", checksum: "d8167e14fba36d55c6fb86fd6ee4118dbf15ccc7e3fb99cd02984a48b0f42d53"),
        .binaryTarget(name: "libavdevice", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/libavdevice.zip", checksum: "5b0861bcf9c9fd1d5d82dc5a4019b6fd48a988ed7fee8e172837a4e00501df9d"),
        .binaryTarget(name: "libavutil", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/libavutil.zip", checksum: "64529147fc93d35f840dc2315610250cdb916e50af6ec51a0352a78aa78c32ce"),
        .binaryTarget(name: "libavformat", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/libavformat.zip", checksum: "42e8489273285f33df30c8036df1dd0d4b2b15ada03cc1df183d7f0dc131a1da"),
        .binaryTarget(name: "libavfilter", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/libavfilter.zip", checksum: "f2615d9ce563fb508ac250ccb4b56733410345f3496385d3f8387cc64a2da910"),
        .binaryTarget(name: "libswscale", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/libswscale.zip", checksum: "a25a2b1d6595230b98766f77510c33c5bf73a0d01535643f483777b7029fa5d7"),
        .binaryTarget(name: "libswresample", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.08/libswresample.zip", checksum: "56af28e79a34e2618cbf00c6ecb1c63ff49bd300ab35f894f8122437cd250168"),
        
        .target(name: "Tool", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .target(name: "Depend",
                linkerSettings: [
                    .linkedLibrary("z"),
                    .linkedLibrary("bz2"),
                    .linkedLibrary("iconv"),
                    .linkedLibrary("c++"),
                ]
               ),
    ]
)

