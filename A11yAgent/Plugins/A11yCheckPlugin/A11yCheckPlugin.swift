import PackagePlugin
import Foundation

@main
struct A11yCheckPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "a11y-check")

        // Collect source directories from all Swift source module targets
        var targetPaths: [String] = []
        for target in context.package.targets {
            guard let sourceModule = target as? SourceModuleTarget else { continue }
            targetPaths.append(sourceModule.directory.string)
        }

        // Allow user to override paths via arguments; if none provided, use all targets
        var userArgs = arguments
        let hasExplicitPaths = !userArgs.isEmpty && !userArgs.first!.hasPrefix("-")

        var commandArgs: [String] = []
        if hasExplicitPaths {
            // Split user args into paths and flags
            while !userArgs.isEmpty && !userArgs.first!.hasPrefix("-") {
                commandArgs.append(userArgs.removeFirst())
            }
        } else {
            commandArgs = targetPaths.isEmpty ? ["."] : targetPaths
        }
        commandArgs.append(contentsOf: userArgs)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool.path.string)
        process.arguments = commandArgs

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        if let output = String(data: outputData, encoding: .utf8), !output.isEmpty {
            print(output, terminator: "")
        }
        if let error = String(data: errorData, encoding: .utf8), !error.isEmpty {
            Diagnostics.warning(error)
        }

        if process.terminationStatus != 0 {
            Diagnostics.error("a11y-check found accessibility errors (exit code \(process.terminationStatus))")
        }
    }
}
