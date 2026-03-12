// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "A11yAgent",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "a11y-check", targets: ["A11yAgentCLI"]),
        .library(name: "A11yAgentCore", targets: ["A11yAgentCore"]),
        .plugin(name: "A11yCheckPlugin", targets: ["A11yCheckPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
        // Pinned below 1.6 to avoid Swift 6.2 SendableMetatype path (fails under Homebrew's SDK; apple/swift-argument-parser#827).
        .package(url: "https://github.com/apple/swift-argument-parser.git", "1.3.0"..<"1.6.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "A11yAgentCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
        .executableTarget(
            name: "A11yAgentCLI",
            dependencies: [
                "A11yAgentCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "A11yAgentLLM",
            dependencies: ["A11yAgentCore"]
        ),
        .plugin(
            name: "A11yCheckPlugin",
            capability: .command(
                intent: .custom(verb: "a11y-check", description: "Run SwiftUI accessibility checks on source files"),
                permissions: [.writeToPackageDirectory(reason: "Write HTML report files when using --format html")]
            ),
            dependencies: [
                .target(name: "A11yAgentCLI"),
            ]
        ),
        .testTarget(
            name: "A11yAgentCoreTests",
            dependencies: [
                "A11yAgentCore",
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            resources: [
                .copy("Fixtures"),
            ]
        ),
    ]
)
