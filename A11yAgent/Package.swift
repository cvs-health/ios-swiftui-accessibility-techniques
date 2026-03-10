// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "A11yAgent",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "a11y-check", targets: ["A11yAgentCLI"]),
        .library(name: "A11yAgentCore", targets: ["A11yAgentCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "A11yAgentCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
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
