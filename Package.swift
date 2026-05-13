// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ios-swiftui-accessibility-techniques",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
    products: [
        .library(name: "A11yCheckCore", targets: ["A11yCheckCore"]),
        .plugin(name: "A11yCheckBuildPlugin", targets: ["A11yCheckBuildPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
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
            ],
            path: "a11y-check/Sources/A11yCheckCore"
        ),
        .executableTarget(
            name: "A11yCheckCLI",
            dependencies: [
                "A11yCheckCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "a11y-check/Sources/A11yCheckCLI"
        ),
        .target(
            name: "A11yCheckLLM",
            dependencies: ["A11yCheckCore"],
            path: "a11y-check/Sources/A11yCheckLLM"
        ),
        .plugin(
            name: "A11yCheckPlugin",
            capability: .command(
                intent: .custom(verb: "a11y-check", description: "Run SwiftUI accessibility checks on source files"),
                permissions: [.writeToPackageDirectory(reason: "Write HTML report files when using --format html")]
            ),
            dependencies: [
                .target(name: "A11yCheckCLI"),
            ],
            path: "a11y-check/Plugins/A11yCheckPlugin"
        ),
        .plugin(
            name: "A11yCheckBuildPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "A11yCheckCLI"),
            ],
            path: "a11y-check/Plugins/A11yCheckBuildPlugin"
        ),
        .testTarget(
            name: "A11yCheckCoreTests",
            dependencies: [
                "A11yCheckCore",
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "a11y-check/Tests/A11yCheckCoreTests",
            resources: [
                .copy("Fixtures"),
            ]
        ),
    ]
)
