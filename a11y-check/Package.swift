// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "a11y-check",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "a11y-check", targets: ["A11yCheckCLI"]),
        .library(name: "A11yCheckCore", targets: ["A11yCheckCore"]),
        .plugin(name: "A11yCheckPlugin", targets: ["A11yCheckPlugin"]),
        .plugin(name: "A11yCheckBuildPlugin", targets: ["A11yCheckBuildPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
        // Pinned below 1.6 to avoid Swift 6.2 SendableMetatype path (fails under Homebrew's SDK; apple/swift-argument-parser#827).
        .package(url: "https://github.com/apple/swift-argument-parser.git", "1.3.0"..<"1.6.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "A11yCheckCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
        .executableTarget(
            name: "A11yCheckCLI",
            dependencies: [
                "A11yCheckCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "A11yCheckLLM",
            dependencies: ["A11yCheckCore"]
        ),
        .plugin(
            name: "A11yCheckPlugin",
            capability: .command(
                intent: .custom(verb: "a11y-check", description: "Run SwiftUI accessibility checks on source files"),
                permissions: [.writeToPackageDirectory(reason: "Write HTML report files when using --format html")]
            ),
            dependencies: [
                .target(name: "A11yCheckCLI"),
            ]
        ),
        .plugin(
            name: "A11yCheckBuildPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "A11yCheckCLI"),
            ]
        ),
        .testTarget(
            name: "A11yCheckCoreTests",
            dependencies: [
                "A11yCheckCore",
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            resources: [
                .copy("Fixtures"),
            ]
        ),
    ]
)
