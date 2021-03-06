//
//  main.swift
//
//
//  Created by 안창범 on 2020/12/01.
//  Modified by kasimok to support macos and libvpx
//

import ArgumentParser
import Foundation

struct Tool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ffmpeg-macos",
        abstract: "Build FFmpeg libraries for macOS as xcframeworks",
        subcommands: [
            BuildCommand.self,
            XCFrameworkCommand.self,
            ModuleCommand.self,
            FatCommand.self,
            DepCommand.self,
            SourceCommand.self,
            ZipCommand.self,
//            Clean.self,
        ],
        defaultSubcommand: BuildCommand.self)
}

struct LibraryOptions: ParsableArguments {
}

struct SourceOptions: ParsableArguments {
    @Option(help: "Library source directory (default: ./<lib>)")
    var sourceDirectory: String?

    var sourceURL: URL { URL(fileURLWithPath: sourceDirectory ?? "./\(lib)") }

    var configureScriptExists: Bool {
        FileManager.default.fileExists(atPath: sourceURL.appendingPathComponent("configure").path)
    }

    @Argument(help: "ffmpeg, fdk-aac, vpx, lame or x264")
    var lib = "ffmpeg"
}

struct BuildOptions: ParsableArguments {
    @Option(help: "directory to contain build artifacts")
    var buildDirectory = "./build"

    @Option(help: "architectures to include")
    var arch = [
//        "arm64",
//        "arm64-iPhoneSimulator",
//        "x86_64",
//        "arm64-catalyst",
//        "x86_64-catalyst",
//        "arm64-AppleTVOS",
//        "arm64-AppleTVSimulator",
        "x86_64-MacOSX",
        "arm64-MacOSX"
//        "x86_64-AppleTVSimulator",
    ]
}

struct ConfigureOptions: ParsableArguments {
    @Option
    var deploymentTarget = "10.12"

    @Option(help: "additional options for configure script")
    var extraOptions: [String] = []
}

struct FatLibraryOptions: ParsableArguments {
    @Option(help: "default: <lib>-fat")
    var output: String?
}

struct XCFrameworkOptions: ParsableArguments {
    @Option
    var frameworks = "./Frameworks"
}

struct DownloadOptions: ParsableArguments {
    @Option(help: "FFmpeg release")
    var release = "4.4.2"

    @Option
    var url: String?
}

struct FdkAacOptions: ParsableArguments {
    @Option
    var fdkAacSource = "./fdk-aac-2.0.1"
}

struct X264Options: ParsableArguments {
    @Option
    var x264Source = "./x264-master"
}

struct LameOptions: ParsableArguments {
    @Option
    var lameSource = "./lame-3.100"
}


struct VPXOptions: ParsableArguments {
    @Option
    var vpxSource = "./libvpx-1.11.1"
}

extension Tool {
    struct BuildCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "build", abstract: "Build framework module")

        @Flag(help: "enable AAC de/encoding via libfdk-aac")
        var enableLibfdkAac = false

        @Flag(help: "enable H.264 encoding via x264")
        var enableLibx264 = false
        
        @Flag(help: "enable VP9 encoding via libvpx")
        /// see https://trac.ffmpeg.org/wiki/Encode/VP9 about more encoding supports
        var enableLibvpx = false

        @Flag(help: "enable MP3 encoding via libmp3lame")
        var enableLibmp3lame = false

        @Flag(help: "Create fat library instead of .xcframework")
        var disableXcframework = false

        @Flag
        var disableModule = false

        @Flag
        var disableZip = false

        @OptionGroup var sourceOptions: SourceOptions
        @OptionGroup var buildOptions: BuildOptions
        @OptionGroup var libraryOptions: LibraryOptions
        @OptionGroup var configureOptions: ConfigureOptions
        @OptionGroup var downloadOptions: DownloadOptions
        @OptionGroup var xcframeworkOptions: XCFrameworkOptions
        @OptionGroup var fatLibraryOptions: FatLibraryOptions
        @OptionGroup var fdkAacOptions: FdkAacOptions
        @OptionGroup var x264Options: X264Options
        @OptionGroup var lameOptions: LameOptions
        @OptionGroup var vpxOptions: VPXOptions

        mutating func run() throws {
            try DepCommand().run()

            if enableLibfdkAac {
                try build(lib: "fdk-aac", sourceDirectory: "./fdk-aac")

                configureOptions.extraOptions += ["--enable-libfdk-aac", "--enable-nonfree",]
            }

            if enableLibmp3lame {
                try build(lib: "lame", sourceDirectory: "./lame")

                configureOptions.extraOptions += ["--enable-libmp3lame",]
            }

            if enableLibx264 {
                try build(lib: "x264", sourceDirectory: "./x264")

                configureOptions.extraOptions += ["--enable-libx264", "--enable-gpl",]
            }
            
            if enableLibvpx {
                try build(lib: "vpx", sourceDirectory: "./vpx")
                
                configureOptions.extraOptions += ["--enable-libvpx",]
            }

            try build(lib: sourceOptions.lib, sourceDirectory: sourceOptions.sourceURL.path)

            if !disableXcframework {
                print("building xcframeworks...")
                var createXcframeworks = XCFrameworkCommand()
                createXcframeworks.buildOptions = buildOptions
                createXcframeworks.libraryOptions = libraryOptions
                createXcframeworks.xcframeworkOptions = xcframeworkOptions
                createXcframeworks.sourceOptions = sourceOptions
                try createXcframeworks.run()

                if !disableModule {
                    print("modularizing...")
                    var modularize = ModuleCommand()
                    modularize.buildOptions = buildOptions
                    modularize.libraryOptions = libraryOptions
                    modularize.xcframeworkOptions = xcframeworkOptions
                    modularize.sourceOptions = sourceOptions
                    try modularize.run()
                }

                if !disableZip {
                    print("zipping...")
                    var zip = ZipCommand()
                    zip.xcframeworkOptions = xcframeworkOptions
                    try zip.run()
                }
            } else {
                print("building fat binaries...")
                var fatCommand = FatCommand()
                fatCommand.buildOptions = buildOptions
                fatCommand.fatLibraryOptions = fatLibraryOptions
                fatCommand.libraryOptions = libraryOptions
                fatCommand.sourceOptions = sourceOptions
                try fatCommand.run()
            }

            print("Done")
        }

        func build(lib: String, sourceDirectory: String) throws {
            if !FileManager.default.fileExists(atPath: sourceDirectory) {
                print("\(lib) source not found. Trying to download...")
                var downloadSource = SourceCommand()
                downloadSource.sourceOptions = sourceOptions
                downloadSource.sourceOptions.sourceDirectory = sourceDirectory
                downloadSource.downloadOptions = downloadOptions
                try downloadSource.run()
            }

            switch lib {
            case "ffmpeg":
                try buildFFmpeg(sourceDirectory: sourceDirectory)
            case "fdk-aac":
                try buildFdkAac(sourceDirectory: sourceDirectory)
            case "lame":
                try buildLame(sourceDirectory: sourceDirectory)
            case "x264":
                try buildX264(sourceDirectory: sourceDirectory)
            case "vpx":
                try buildVPX(sourceDirectory: sourceDirectory)
            default:
                throw ExitCode.failure
            }
        }

        func buildFFmpeg(sourceDirectory: String) throws {
            class FFmpegConfiguration: ConfigurationHelper, Configuration {
                override var `as`: String { "gas-preprocessor.pl \(aarch64) -- \(cc)" }

                var options: [String] {
                    [
                        "--prefix=\(installPrefix)",
                        "--enable-cross-compile",
                        "--disable-debug",
                        "--disable-programs",
                        "--disable-doc",
                        "--enable-pic",
                        "--disable-audiotoolbox",
                        "--target-os=darwin",
                        "--arch=\(arch)",
                        "--cc=\(cc)",
                        "--as=\(`as`)",
                        "--extra-cflags=\(cFlags) -I\(installPrefix)/include",
                        "--extra-ldflags=\(ldFlags) -L\(installPrefix)/lib",
                    ]
                }
            }

            try buildLibrary(name: "FFmpeg", sourceDirectory: sourceDirectory, arch: buildOptions.arch, deploymentTarget: configureOptions.deploymentTarget, buildDirectory: buildOptions.buildDirectory, configuration: FFmpegConfiguration.self) {
                let platformOptions: [String]
                switch $0.platform {
                case "MacOSX":
                    platformOptions = [
                        "--disable-coreimage",
                        "--disable-securetransport",
                        "--disable-videotoolbox",
                    ]
                case "AppleTVOS", "AppleTVSimulator":
                    platformOptions = [
                        "--disable-avfoundation",
                    ]
                default:
                    platformOptions = []
                }
                return $0.options
                    + configureOptions.extraOptions
                    + platformOptions
            }
        }

        func buildFdkAac(sourceDirectory: String) throws {
            class FdkAacConfiguration: ConfigurationHelper, Configuration {
                override var `as`: String { "\(sourceDirectory)/extras/gas-preprocessor.pl \(aarch64) -- \(cc)" }

                var options: [String] {
                    [
                        "--host=\(host(arch))-apple-darwin",
                        "--prefix=\(installPrefix)",
                        "--enable-static",
                        "--disable-shared",
                        "--with-pic=yes",
                        "CC=\(cc)",
                        "CXX=\(cc)",
                        "CPP=\(cc) -E",
                        "AS=\(`as`)",
                        "CFLAGS=\(cFlags)",
                        "CPPFLAGS=\(cFlags)",
                        "LDFLAGS=\(ldFlags)",
                    ]
                }
            }

            try buildLibrary(name: "fdk-aac", sourceDirectory: sourceDirectory, arch: buildOptions.arch, deploymentTarget: configureOptions.deploymentTarget, buildDirectory: buildOptions.buildDirectory, configuration: FdkAacConfiguration.self)
        }

        func buildLame(sourceDirectory: String) throws {
            class LameConfiguration: ConfigurationHelper, Configuration {
                override var cc: String { "xcrun -sdk \(sdk) clang -arch \(arch)" }

                var options: [String] {
                    [
                        "--host=\(host(arch))-apple-darwin",
                        "--prefix=\(installPrefix)",
                        "--disable-frontend",
                        "--disable-shared",
                    ]
                }

                override var environment: [String : String]? {
                    [
                        "CC": cc,
                        "CPP": "\(cc) -E",
                        "CFLAGS": cFlags,
                        "LDFLAGS": ldFlags,
                    ]
                }
            }

            try buildLibrary(name: "lame", sourceDirectory: sourceDirectory, arch: buildOptions.arch, deploymentTarget: configureOptions.deploymentTarget, buildDirectory: buildOptions.buildDirectory, configuration: LameConfiguration.self)
        }

        func buildX264(sourceDirectory: String) throws {
            class X264Configuration: ConfigurationHelper, Configuration {
                override var `as`: String { "\(URL(fileURLWithPath: sourceDirectory).path)/tools/gas-preprocessor.pl \(aarch64) -- \(cc)" }

                var options: [String] {
                    [
                        "--host=\(host(arch))-apple-darwin",
                        "--prefix=\(installPrefix)",
                        "--enable-static",
                        "--disable-cli",
                        "--enable-pic",
                        "--extra-cflags=\(cFlags)",
                        "--extra-asflags=\(arch.hasPrefix("arm") ? cFlags : "")",
                        "--extra-ldflags=\(ldFlags)",
                    ]
                }

                override var environment: [String : String]? {
                    var env = [
                        "CC": cc,
                    ]
                    if arch.hasPrefix("arm") {
                        env["AS"] = `as`
                    }
                    return env
                }
            }

            try buildLibrary(name: "x264", sourceDirectory: sourceDirectory, arch: buildOptions.arch, deploymentTarget: configureOptions.deploymentTarget, buildDirectory: buildOptions.buildDirectory, configuration: X264Configuration.self)
        }
        
        
        func buildVPX(sourceDirectory: String) throws {
            class VPXConfiguration: ConfigurationHelper, Configuration {
                override var cc: String { "xcrun -sdk \(sdk) clang -arch \(arch)" }

                var options: [String] {
                    [
                        "--prefix=\(installPrefix)",
//                        "--enable-vp8",
                        "--enable-postproc",
//                        "--enable-vp9-postproc",
//                        "--enable-vp9-highbitdepth",
//                        "--disable-examples",
//                        "--disable-docs",
//                        "--enable-multi-res-encoding",
//                        "--disable-unit-tests",
                        "--enable-pic",
//                        "--extra-cflags=\(cFlags)",
                        "--enable-cross-compile",
                        "--disable-shared",
                        "--arch=\(arch)"
                    ]
                }

                override var environment: [String : String]? {
                    [
                        "CC": cc,
                        "CPP": "\(cc) -E",
                        "CFLAGS": cFlags,
                        "LDFLAGS": ldFlags,
                    ]
                }
            }
            
            try buildLibrary(name: "vpx", sourceDirectory: sourceDirectory, arch: buildOptions.arch, deploymentTarget: configureOptions.deploymentTarget, buildDirectory: buildOptions.buildDirectory, configuration: VPXConfiguration.self)
        }
        
        
        

        func buildLibrary<T>(name: String, sourceDirectory: String, arch: [String], deploymentTarget: String, buildDirectory: String, configuration: T.Type, customize: (T) -> [String] = { $0.options }) throws where T: Configuration {
            print("🛠: Building library: \(name)")
            let buildDir = URL(fileURLWithPath: buildDirectory)
                .appendingPathComponent(name)
            for archx in arch {
                print("🎭: Building for \(archx)...")
                let archDir = buildDir.appendingPathComponent(archx)
                try createDirectory(at: archDir.path)

                let prefix = buildDir
                    .deletingLastPathComponent()
                    .appendingPathComponent("install")
                    .appendingPathComponent(name)
                    .appendingPathComponent(archx)

                let array = archx.split(separator: "-")
                let platform: String?
                if array.count > 1 {
                    if array[1] == "catalyst" {
                        platform = "MacOSX"
                    } else {
                        platform = String(array[1])
                    }
                } else {
                    platform = nil
                }
                let conf = T(sourceDirectory: sourceDirectory, arch: String(array[0]), platform: platform, deploymentTarget: deploymentTarget, installPrefix: prefix.path)
                let options = customize(conf)
                try launch(launchPath: "\(sourceDirectory)/configure",
                           arguments: options,
                           currentDirectoryPath: archDir.path,
                           environment: conf.environment)

                try launch(launchPath: "/usr/bin/make",
                           arguments: [
                            "-j3",
                            "install",
                           ], // FIXME: GASPP_FIX_XCODE5=1 ?
                           currentDirectoryPath: archDir.path)

                let all = buildDir
                    .deletingLastPathComponent()
                    .appendingPathComponent("install")
                    .appendingPathComponent(archx)
                let include = all.appendingPathComponent("include").path
                let lib = all.appendingPathComponent("lib").path
                try createDirectory(at: include)
                try createDirectory(at: lib)
                try system("""
                    ln -sf \(prefix.path)/include/* \(include)
                    ln -sf \(prefix.path)/lib/* \(lib)
                    """)
                print("✅: Successfully built library: \(name)")
            }
        }
    }

    struct DepCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "dep", abstract: "Install build dependency")

        func run() throws {
            func installHomebrewIfNeeded() throws {
                if !which("brew") {
                    print("'brew' not found. Trying to install...")
                    try system(#"/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)""#)
                }
            }

            func installWithHomebrew(_ command: String) throws {
                if !which(command) {
                    print("'\(command)' not found")

                    try installHomebrewIfNeeded()

                    print("Trying to install '\(command)'...")
                    try system("arch -x86_64 brew install \(command)")
                }
            }

            try installWithHomebrew("yasm")
            try installWithHomebrew("nasm")

            if !which("gas-preprocessor.pl") {
                print("'gas-preprocessor.pl' not found. Trying to install...")
                try system("""
                    curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
                    -o /usr/local/bin/gas-preprocessor.pl \
                    && chmod +x /usr/local/bin/gas-preprocessor.pl
                    """)
            }
        }
    }

    struct SourceCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "source", abstract: "Download library source code")

        @OptionGroup var downloadOptions: DownloadOptions

        @OptionGroup var sourceOptions: SourceOptions

        var defaultURL: String {
            switch sourceOptions.lib {
            case "ffmpeg":
                return "http://www.ffmpeg.org/releases/ffmpeg-\(downloadOptions.release).tar.bz2"
            case "fdk-aac":
                return "https://sourceforge.net/projects/opencore-amr/files/latest/download"
            case "lame":
                return "https://sourceforge.net/projects/lame/files/latest/download"
            case "x264":
                return "https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.bz2"
            case "vpx":
                return "https://github.com/webmproject/libvpx/archive/v1.11.0.tar.gz"//TODO: update to latest
            default:
                fatalError("unknown library: \(sourceOptions.lib)")
            }
        }

        func run() throws {
            let url = downloadOptions.url ?? defaultURL
            let t = "/tmp/ffmpeg-macos"
            // FIXME: J for .xz
            try system("""
                mkdir \(t)
                curl -L \(url) | tar xjC \(t)
                mv \(t)/* \(sourceOptions.sourceURL.path)
                rmdir \(t)
                """)
        }
    }

    struct LibCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "lib", abstract: "Build a library")
        func run() throws {
            // FIXME: ...
        }
    }

    struct FatCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "fat", abstract: "Create fat library")

        @OptionGroup var libraryOptions: LibraryOptions

        @OptionGroup var buildOptions: BuildOptions

        @OptionGroup var fatLibraryOptions: FatLibraryOptions

        @OptionGroup var sourceOptions: SourceOptions

        mutating func run() throws {
            let output = URL(fileURLWithPath: fatLibraryOptions.output ?? (sourceOptions.lib + "-fat"))
            try createDirectory(at: output.appendingPathComponent("lib").path)

            let installDir = URL(fileURLWithPath: buildOptions.buildDirectory)
                .appendingPathComponent("install")
                .appendingPathComponent(sourceOptions.lib)
            try system("""
                cd \(installDir.path)/\(buildOptions.arch[0])/lib
                for LIB in *.a
                do
                    lipo `find \(installDir.path) -name $LIB` -create -output \(output.path)/lib/$LIB
                done
                """)

            let to = output.appendingPathComponent("include")

            try removeItem(at: to.path)

            try copyItem(at: installDir
                            .appendingPathComponent(buildOptions.arch[0])
                            .appendingPathComponent("include").path,
                         to: to.path)
        }
    }

    struct XCFrameworkCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "framework", abstract: "Create .xcframework")

        @OptionGroup var libraryOptions: LibraryOptions

        @OptionGroup var buildOptions: BuildOptions

        @OptionGroup var xcframeworkOptions: XCFrameworkOptions

        @OptionGroup var sourceOptions: SourceOptions

        func run() throws {
            let lib = URL(fileURLWithPath: buildOptions.buildDirectory).appendingPathComponent("install").appendingPathComponent(sourceOptions.lib)
            let contents = try FileManager.default.contentsOfDirectory(at: lib.appendingPathComponent(buildOptions.arch[0]).appendingPathComponent("lib"), includingPropertiesForKeys: nil, options: [])
            let modules = contents.filter { $0.pathExtension == "a" }.map { $0.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "lib", with: "") }

            for library in modules {
                func convert(_ arch: String) -> String {
                    let array = arch.split(separator: "-")
                    if array.count > 1 {
                        return array[1].lowercased()
                    }

                    switch arch {
                    case "arm64", "armv7":
                        return "macosx"
                    case "x86_64":
                        return "macosx"
                    default:
                        fatalError()
                    }
                }

                var dict: [String: Set<String>] = [:]

                for arch in buildOptions.arch {
                    let sdk = convert(arch)
                    var set = dict[sdk] ?? []
                    set.insert(arch)
                    dict[sdk] = set
                }

                var args: [String] = []

                for (sdk, set) in dict {
                    guard let arch = set.first else {
                        fatalError()
                    }
                    let dir = "\(lib.path)/\(arch)"

                    let xcf = "\(buildOptions.buildDirectory)/xcf/\(sdk)"
                    try createDirectory(at: xcf)

                    let fat = "\(xcf)/lib\(library).a"

                    try launch(launchPath: "/usr/bin/lipo",
                               arguments:
                                set.map { arch in "\(lib.path)/\(arch)/lib/lib\(library).a" }
                                + [
                                    "-create",
                                    "-output",
                                    fat,
                                ])

                    let include: String
                    if modules.count > 1 {
                        include = "\(xcf)/\(library)/include"
                        try removeItem(at: include)
                        try createDirectory(at: include)

                        let copy = "\(include)/lib\(library)"
                        try removeItem(at: copy)
                        try copyItem(at: "\(dir)/include/lib\(library)", to: copy)
                    } else {
                        include = "\(dir)/include"
                    }

                    args += [
                        "-library", fat,
                        "-headers", include,
                    ]
                }

                let output = "\(xcframeworkOptions.frameworks)/\(library).xcframework"

                try removeItem(at: output)

                try launch(launchPath: "/usr/bin/xcodebuild",
                           arguments:
                            ["-create-xcframework"]
                            + args
                            + [
                                "-output", output,
                            ])
            }
        }
    }

    struct ZipCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "zip", abstract: "Zip .xcframework")

        @OptionGroup var xcframeworkOptions: XCFrameworkOptions

        func run() throws {
            let contents = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: xcframeworkOptions.frameworks), includingPropertiesForKeys: nil)
            let frameworks = contents.filter { $0.pathExtension == "xcframework" }.map { $0.deletingPathExtension().lastPathComponent }

            for framework in frameworks {
                try system("cd \(xcframeworkOptions.frameworks) && rm -f \(framework).zip; zip -r \(framework).zip \(framework).xcframework")
            }
        }
    }

    struct ModuleCommand: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "module", abstract: "Enable modules to allow import from Swift")

        @OptionGroup var libraryOptions: LibraryOptions

        @OptionGroup var buildOptions: BuildOptions

        @OptionGroup var xcframeworkOptions: XCFrameworkOptions

        @OptionGroup var sourceOptions: SourceOptions

        func run() throws {
            let lib = URL(fileURLWithPath: buildOptions.buildDirectory).appendingPathComponent("install").appendingPathComponent(sourceOptions.lib)
            let contents = try FileManager.default.contentsOfDirectory(at: lib.appendingPathComponent(buildOptions.arch[0]).appendingPathComponent("lib"), includingPropertiesForKeys: nil, options: [])
            let modules = contents.filter { $0.pathExtension == "a" }.map { $0.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "lib", with: "") }

            for library in modules {
                let path = "\(xcframeworkOptions.frameworks)/\(library).xcframework"
                let data = try Data(contentsOf: URL(fileURLWithPath: "\(path)/Info.plist"))
                guard let info = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                      let libraries = info["AvailableLibraries"] as? [[String: Any]] else {
                    throw ExitCode.failure
                }

                for dict in libraries {
                    guard let headersPath = dict["HeadersPath"] as? String,
                          let libraryIdentifier = dict["LibraryIdentifier"] as? String else {
                        throw ExitCode.failure
                    }

                    let to = URL(fileURLWithPath: "\(path)/\(libraryIdentifier)/\(headersPath)/lib\(library)/module.modulemap")

                    try createDirectory(at: to.deletingLastPathComponent().path)

                    try removeItem(at: to.path)

                    do {
                        try copyItem(at: "ModuleMaps/\(library)/module.modulemap",
                                     to: to.path)
                    }
                    catch {
                        let nserror = error as NSError
                        guard let posixError = nserror.userInfo[NSUnderlyingErrorKey] as? POSIXError,
                              posixError.code == .ENOENT
                        else {
                            print(#line, error)
                            throw error
                        }

                        let content = """
                            module \(library) {
                                umbrella "."
                                export *
                            }
                            """
                        try content.write(to: to, atomically: false, encoding: .utf8)
                    }
                }
            }
        }
    }

    struct Lipo: ParsableCommand {
        @Argument
        var input: String

        @Option
        var arch: String

        @Option
        var output: String

        func run() throws {
            try launch(launchPath: "/usr/bin/lipo",
                       arguments: [
                        input,
                        "-thin",
                        arch,
                        "-output",
                        output,
                       ])
        }
    }

    struct Clean: ParsableCommand {
        func run() throws {
            // FIXME: ...
        }
    }
}

func launch(launchPath: String, arguments: [String], currentDirectoryPath: String? = nil, environment: [String: String]? = nil) throws {
    let process = Process()

    if #available(OSX 10.13, *) {
        process.executableURL = URL(fileURLWithPath: launchPath)
    } else {
        process.launchPath = launchPath
    }

    process.arguments = arguments

    currentDirectoryPath.map { path in
        if #available(OSX 10.13, *) {
            process.currentDirectoryURL = URL(fileURLWithPath: path)
        } else {
            process.currentDirectoryPath = path
        }
        print("current directory:", path)
    }

    environment.map { environment in
        process.environment = environment
        print("environment:", environment)
    }

    print(launchPath, arguments)
    process.launch()

    process.waitUntilExit()
    if process.terminationStatus != 0 {
        print("'\(launchPath)' exit code: \(process.terminationStatus)")
        throw ExitCode(process.terminationStatus)
    }
}

func createDirectory(at path: String, withIntermediateDirectories: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
    try FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    print("created directory:", path)
}

func copyItem(at src: String, to dst: String) throws {
    try FileManager.default.copyItem(at: URL(fileURLWithPath: src),
                                     to: URL(fileURLWithPath: dst))
    print("copied:", src, "to", dst)
}

func removeItem(at path: String) throws {
    do {
        try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
        print("removed:", path)
    }
    catch {
        let nserror = error as NSError
        guard let posixError = nserror.userInfo[NSUnderlyingErrorKey] as? POSIXError,
              posixError.code == .ENOENT
        else {
            print(#line, error)
            throw error
        }
    }

}
func which(_ command: String) -> Bool {
    do {
        try system("which \(command)")
        return true
    }
    catch {
        return false
    }
}

func system(_ command: String) throws {
    try spawn(["sh", "-c", command])
}

func spawn(_ args: [String]) throws {
    var pid: pid_t = -1
    var argv = args.map { strdup($0) }
    argv.append(nil)

    print(#function, args)
    let errno = posix_spawnp(&pid, args.first, nil, nil, argv, environ)
    print(#function, "posix_spawn()=\(errno) pid=\(pid)")

    argv.dropLast().forEach { free($0) }

    guard errno == 0 else {
        throw ExitCode.failure
    }

    var status: Int32 = 0
    let ret = waitpid(pid, &status, 0)
    print(#function, "waitpid()=\(ret) status=\(status)")
    guard WIFEXITED(status) else {
        throw ExitCode.failure
    }
    status = WEXITSTATUS(status)
    if status != 0 {
        print(#function, "exit status:", status)
        throw ExitCode.failure
    }
}

// FIXME: rename
func host(_ arch: String) -> String {
    switch arch {
    case "armv7":
        return "arm"
    case "arm64":
        return "aarch64"
    default:
        return arch
    }
}

protocol Configuration {
    var options: [String] { get }

    var environment: [String: String]? { get }

    init(sourceDirectory: String, arch: String, platform: String?, deploymentTarget: String, installPrefix: String)
}

class ConfigurationHelper {
    let sourceDirectory: String

    let arch: String

    let platform: String

    var sdk: String { platform.lowercased() }

    var cc: String { "xcrun -sdk \(sdk) clang" }

    var aarch64: String { arch == "arm64" ? "-arch aarch64" : "" }

    var `as`: String { "\(sourceDirectory)/extras/gas-preprocessor.pl \(aarch64) -- \(cc)" }

    var cFlags: String

    var ldFlags: String { cFlags }

    let installPrefix: String

    var environment: [String: String]? { nil }

    required init(sourceDirectory: String, arch: String, platform: String? = nil, deploymentTarget: String, installPrefix: String) {
        self.sourceDirectory = sourceDirectory
        self.arch = arch
        self.installPrefix = installPrefix

        cFlags = "-arch \(arch)"

        if let platform = platform {
            self.platform = platform
        } else {
            switch arch {
            case "x86_64", "i386":
                self.platform = "MacOSX"
            default:
                self.platform = "MacOSX"
            }
        }

        switch self.platform {
        case "iPhoneSimulator":
            cFlags.append(" -mios-simulator-version-min=\(deploymentTarget)")
        case "iPhoneOS":
            cFlags.append(" -mios-version-min=\(deploymentTarget) -fembed-bitcode")
        case "MacOSX":
            cFlags.append(" -mmacosx-version-min=\(deploymentTarget) -fembed-bitcode")
        case "AppleTVOS":
            cFlags.append(" -mtvos-version-min=\(deploymentTarget) -fembed-bitcode")
        case "AppleTVSimulator":
            cFlags.append(" -mtvos-simulator-version-min=\(deploymentTarget)")
        default:
            fatalError("Unknown platform: \(self.platform)")
        }
    }
}

// https://github.com/aciidb0mb3r/Configuration/blob/master/Sources/POSIX/system.swift

private func _WSTATUS(_ status: CInt) -> CInt {
    return status & 0x7f
}

private func WIFEXITED(_ status: CInt) -> Bool {
    return _WSTATUS(status) == 0
}

private func WEXITSTATUS(_ status: CInt) -> CInt {
    return (status >> 8) & 0xff
}

Tool.main()
