import PackagePlugin
import Foundation

/// Build tool plugin that runs a11y-check automatically on every build.
/// Diagnostics appear inline in Xcode as warnings and errors.
@main
struct A11yCheckBuildPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let sourceModule = target as? SourceModuleTarget else {
            return []
        }

        let tool = try context.tool(named: "a11y-check")
        let sourcePath = sourceModule.directory.string

        return [
            .prebuildCommand(
                displayName: "a11y-check: \(target.name)",
                executable: tool.path,
                arguments: [sourcePath, "--format", "xcode", "--no-fail"],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension A11yCheckBuildPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let toolPath: Path
        if let tool = try? context.tool(named: "a11y-check") {
            toolPath = tool.path
        } else if let found = findToolInPath("a11y-check") {
            toolPath = found
        } else {
            Diagnostics.warning("a11y-check not found. Install via: brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check")
            return []
        }

        let sourcePath = context.xcodeProject.directory.string

        return [
            .prebuildCommand(
                displayName: "a11y-check: \(target.displayName)",
                executable: toolPath,
                arguments: [sourcePath, "--format", "xcode", "--no-fail"],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }

    private func findToolInPath(_ name: String) -> Path? {
        let searchPaths = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
        ]
        for dir in searchPaths {
            let path = "\(dir)/\(name)"
            if FileManager.default.isExecutableFile(atPath: path) {
                return Path(path)
            }
        }
        return nil
    }
}
#endif
