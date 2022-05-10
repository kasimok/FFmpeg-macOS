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
        
        
        .binaryTarget(name: "ffmpegkit", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/ffmpegkit.zip", checksum: "b9b0dd85c04e6fc1868b9f4c8ce462a7696aa107d0d5f3ec8bb61979fdc680f3"),
        .binaryTarget(name: "libavcodec", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/libavcodec.zip", checksum: "10552392cb35b095d7d965529fb7f2578ee1d96295dbef77efe44d85427b55b3"),
        .binaryTarget(name: "libavutil", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/libavutil.zip", checksum: "8d1d2c8420ad198e437294e6dae20c6ecb28e5da19064e7ccba7ff7581d03b92"),
        .binaryTarget(name: "libavformat", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/libavformat.zip", checksum: "a91b9681277994cb1d4734c103bb11b40ab758909b6351d8a2516b8de0e0ecea"),
        .binaryTarget(name: "libavfilter", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/libavfilter.zip", checksum: "594df6435e0379113174f65bbcfd5e859060a38cc74fc9bed5794360ed5cf2f2"),
        .binaryTarget(name: "libavdevice", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/libavdevice.zip", checksum: "909db22873069b5beaba19cae491a823e5b3ec202e20989bfd8b7389633098e7"),
        .binaryTarget(name: "libswscale", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/libswscale.zip", checksum: "d8cc5708415f5373578a986a6fc6753af95416d4cb22dd617dd54fd31489fae8"),
        .binaryTarget(name: "libswresample", url: "https://github.com/kasimok/FFmpeg-macOS/releases/download/0.07/libswresample.zip", checksum: "756ed6928c1b19faa503e585c9cc80337b9bc968fbf2f0d24f023726edfd80e6"),
        
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


