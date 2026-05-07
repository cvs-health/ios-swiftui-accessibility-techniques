// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ios-swiftui-accessibility-techniques",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
    products: [
        .library(name: "A11yAgentCore", targets: ["A11yAgentCore"]),
        .plugin(name: "A11yCheckBuildPlugin", targets: ["A11yCheckBuildPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
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
            ],
            path: "A11yAgent/Sources/A11yAgentCore"
        ),
        .executableTarget(
            name: "A11yAgentCLI",
            dependencies: [
                "A11yAgentCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "A11yAgent/Sources/A11yAgentCLI"
        ),
        .target(
            name: "A11yAgentLLM",
            dependencies: ["A11yAgentCore"],
            path: "A11yAgent/Sources/A11yAgentLLM"
        ),
        .plugin(
            name: "A11yCheckPlugin",
            capability: .command(
                intent: .custom(verb: "a11y-check", description: "Run SwiftUI accessibility checks on source files"),
                permissions: [.writeToPackageDirectory(reason: "Write HTML report files when using --format html")]
            ),
            dependencies: [
                .target(name: "A11yAgentCLI"),
            ],
            path: "A11yAgent/Plugins/A11yCheckPlugin"
        ),
        .plugin(
            name: "A11yCheckBuildPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "A11yAgentCLI"),
            ],
            path: "A11yAgent/Plugins/A11yCheckBuildPlugin"
        ),
        .testTarget(
            name: "A11yAgentCoreTests",
            dependencies: [
                "A11yAgentCore",
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "A11yAgent/Tests/A11yAgentCoreTests",
            resources: [
                .copy("Fixtures"),
            ]
        ),
    ]
)
