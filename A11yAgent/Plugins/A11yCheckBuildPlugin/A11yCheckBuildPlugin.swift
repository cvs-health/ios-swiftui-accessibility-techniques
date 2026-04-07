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
                arguments: [sourcePath, "--format", "xcode"],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}
