import ArgumentParser
import Foundation
import A11yAgentCore

@main
struct A11yCheck: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "a11y-check",
        abstract: "SwiftUI Accessibility Checker — static analysis for iOS accessibility issues.",
        discussion: """
        Analyzes Swift/SwiftUI source files for accessibility issues using \
        SwiftSyntax-based rules mapped to WCAG 2.2 success criteria.

        Examples:
          a11y-check Sources/MyView.swift
          a11y-check Sources/ --format json
          a11y-check . --disable image-missing-label,fixed-font-size
          a11y-check . --only error
        """,
        version: "0.1.0"
    )

    @Argument(help: "File or directory paths to analyze.")
    var paths: [String] = ["."]

    @Option(name: .long, help: "Output format: terminal, json, xcode, html")
    var format: OutputFormat = .terminal

    @Option(name: .long, help: "Comma-separated rule IDs to disable.")
    var disable: String?

    @Option(name: .long, help: "Only show diagnostics at or above this severity: info, warning, error")
    var only: A11ySeverity?

    @Flag(name: .long, help: "List all available rules and exit.")
    var listRules = false

    @Flag(name: .long, help: "Suppress file path in output (useful for single-file checks).")
    var compact = false

    @Option(name: .long, help: "Path to a .a11ycheck.yml config file. Auto-detected if not specified.")
    var config: String?

    @Flag(name: .long, help: "Only report diagnostics on lines changed in the current git diff.")
    var diff = false

    @Option(name: .long, help: "Git ref to diff against (default: HEAD). Used with --diff.")
    var diffBase: String?

    func run() throws {
        let registry = RuleRegistry()

        // Handle --list-rules
        if listRules {
            print("Available rules (\(registry.rules.count)):\n")
            for rule in registry.rules.sorted(by: { $0.id < $1.id }) {
                let wcag = rule.wcagCriteria.joined(separator: ", ")
                print("  \(rule.id)")
                print("    \(rule.name) [\(rule.severity.rawValue)] WCAG \(wcag)")
                print("    \(rule.description)\n")
            }
            return
        }

        // Load config
        if let configPath = config {
            let loadedConfig = try ConfigLoader.load(atPath: resolvePath(configPath))
            registry.applyConfig(loadedConfig)
        } else {
            let searchDir = resolvePath(paths.first ?? ".")
            let loadedConfig = try ConfigLoader.load(from: searchDir)
            registry.applyConfig(loadedConfig)
        }

        // Apply --disable (additive on top of config)
        if let disableList = disable {
            let ids = disableList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            registry.disabledRuleIDs.formUnion(ids)
        }

        // Discover asset catalog colors for contrast checking
        let projectRoot = resolvePath(paths.first ?? ".")
        registry.assetColors = AssetCatalogParser.discoverColors(in: projectRoot)

        // Collect diagnostics
        var allDiagnostics: [A11yDiagnostic] = []

        for path in paths {
            let resolvedPath = resolvePath(path)
            var isDir: ObjCBool = false

            guard FileManager.default.fileExists(atPath: resolvedPath, isDirectory: &isDir) else {
                printError("Path not found: \(resolvedPath)")
                continue
            }

            if isDir.boolValue {
                let diagnostics = try registry.analyzeDirectory(at: resolvedPath)
                allDiagnostics.append(contentsOf: diagnostics)
            } else {
                let diagnostics = try registry.analyzeFile(at: resolvedPath)
                allDiagnostics.append(contentsOf: diagnostics)
            }
        }

        // Apply --diff filter
        if diff {
            let workDir = resolvePath(paths.first ?? ".")
            let changedLines = DiffFilter.changedLines(in: workDir, baseBranch: diffBase)
            allDiagnostics = DiffFilter.filter(allDiagnostics, changedLines: changedLines)
        }

        // Apply --only severity filter
        if let minSeverity = only {
            allDiagnostics = allDiagnostics.filter { $0.severity >= minSeverity }
        }

        // Output results
        switch format {
        case .terminal:
            let basePath = paths.count == 1 ? resolvePath(paths[0]) : nil
            let formatter = TerminalFormatter()
            print(formatter.format(allDiagnostics, relativeTo: basePath))

        case .json:
            let formatter = JSONFormatter()
            let output = try formatter.format(allDiagnostics)
            print(output)

        case .xcode:
            let formatter = XcodeFormatter()
            print(formatter.format(allDiagnostics), terminator: "")

        case .html:
            let formatter = HTMLFormatter()
            print(formatter.format(allDiagnostics, allRules: registry.rules))
        }

        // Exit with error code if there are errors
        let errorCount = allDiagnostics.filter { $0.severity == .error }.count
        if errorCount > 0 {
            throw ExitCode(1)
        }
    }

    private func resolvePath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return path
        }
        let cwd = FileManager.default.currentDirectoryPath
        return (cwd as NSString).appendingPathComponent(path)
    }

    private func printError(_ message: String) {
        FileHandle.standardError.write(Data("\u{001B}[31merror: \(message)\u{001B}[0m\n".utf8))
    }
}

enum OutputFormat: String, ExpressibleByArgument {
    case terminal
    case json
    case xcode
    case html
}

// Make A11ySeverity conform to ExpressibleByArgument for CLI parsing
extension A11ySeverity: ExpressibleByArgument {}
