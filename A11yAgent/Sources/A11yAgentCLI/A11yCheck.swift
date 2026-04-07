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
        SwiftSyntax-based rules mapped to WCAG 2.2 success criteria. \
        Every run automatically includes a WCAG 2.2 accessibility score.

        Examples:
          a11y-check Sources/MyView.swift
          a11y-check Sources/ --format json
          a11y-check . --disable image-missing-label,fixed-font-size
          a11y-check . --only error
          a11y-check . --min-score 80
          a11y-check MyView.swift --lines 50-120
          a11y-check . --fix
          a11y-check . --fix --dry-run
          a11y-check . --per-view
          a11y-check . --no-trend
        """,
        version: "0.2.0"
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

    @Option(name: .long, help: "Minimum passing score (0–100). Exit with error if score is below this threshold.")
    var minScore: Double?

    @Option(name: .long, help: "Only check lines in a range, e.g. 50-120. Can be comma-separated for multiple ranges: 10-30,80-100")
    var lines: String?

    @Flag(name: .long, help: "Automatically apply available fixes to source files.")
    var fix = false

    @Flag(name: .long, help: "Show what --fix would change without modifying files.")
    var dryRun = false

    @Flag(name: .long, inversion: .prefixedNo, help: "Track score over time. Enabled by default; use --no-trend to disable.")
    var trend = true

    @Flag(name: .long, help: "Show per-SwiftUI-View scores in addition to the overall score.")
    var perView = false

    @Flag(name: .long, help: "Save current issues as the baseline. Future runs with --baseline will only show new issues.")
    var baselineSave = false

    @Flag(name: .long, help: "Filter out issues that are in the baseline (.a11y-baseline.json). Only new regressions are reported.")
    var baseline = false

    func run() throws {
        let registry = RuleRegistry()

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

        // Collect diagnostics
        var allDiagnostics: [A11yDiagnostic] = []
        var filePaths: [String] = []

        for path in paths {
            let resolvedPath = resolvePath(path)
            var isDir: ObjCBool = false

            guard FileManager.default.fileExists(atPath: resolvedPath, isDirectory: &isDir) else {
                printError("Path not found: \(resolvedPath)")
                continue
            }

            if isDir.boolValue {
                let discovered = discoverSwiftFiles(at: resolvedPath, config: registry.config)
                filePaths.append(contentsOf: discovered)
                let diagnostics = try registry.analyzeDirectory(at: resolvedPath)
                allDiagnostics.append(contentsOf: diagnostics)
            } else {
                filePaths.append(resolvedPath)
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

        // Apply --lines filter
        if let linesSpec = lines {
            let ranges = parseLineRanges(linesSpec)
            if !ranges.isEmpty {
                allDiagnostics = allDiagnostics.filter { diag in
                    ranges.contains { diag.line >= $0.lowerBound && diag.line <= $0.upperBound }
                }
            }
        }

        // Apply --only severity filter
        if let minSeverity = only {
            allDiagnostics = allDiagnostics.filter { $0.severity >= minSeverity }
        }

        // Save baseline if requested
        if baselineSave {
            let calculator = ScoreCalculator()
            let preScore = calculator.calculate(
                diagnostics: allDiagnostics,
                rules: registry.enabledRules,
                filePaths: filePaths
            )
            let baselineData = Baseline.from(diagnostics: allDiagnostics, score: preScore.score)
            try baselineData.save(to: resolvePath(paths.first ?? "."))
            print("Baseline saved with \(allDiagnostics.count) issues (score: \(String(format: "%.1f", preScore.score)))")
            print("Future runs with --baseline will only report new issues.")
            return
        }

        // Apply baseline filter
        if baseline {
            let searchDir = resolvePath(paths.first ?? ".")
            if let baselineData = Baseline.load(from: searchDir) {
                let before = allDiagnostics.count
                allDiagnostics = baselineData.filterNew(diagnostics: allDiagnostics)
                let suppressed = before - allDiagnostics.count
                if suppressed > 0 {
                    printError("Baseline: \(suppressed) known issues suppressed, \(allDiagnostics.count) new issues")
                }
            }
        }

        // Compute score
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: allDiagnostics,
            rules: registry.enabledRules,
            filePaths: filePaths
        )

        // Apply --fix
        if fix || dryRun {
            let fixer = AutoFixer()
            let result = fixer.applyFixes(diagnostics: allDiagnostics, dryRun: dryRun)
            print(fixer.formatResult(result, dryRun: dryRun))

            if fix && !dryRun && result.totalFixesApplied > 0 {
                // Re-analyze after fixes to get updated diagnostics and score
                allDiagnostics = []
                for path in filePaths {
                    let diagnostics = try registry.analyzeFile(at: path)
                    allDiagnostics.append(contentsOf: diagnostics)
                }
                if let minSeverity = only {
                    allDiagnostics = allDiagnostics.filter { $0.severity >= minSeverity }
                }
                let updatedScore = calculator.calculate(
                    diagnostics: allDiagnostics,
                    rules: registry.enabledRules,
                    filePaths: filePaths
                )
                // Show updated results
                let basePath = paths.count == 1 ? resolvePath(paths[0]) : nil
                let formatter = TerminalFormatter()
                print(formatter.format(allDiagnostics, relativeTo: basePath, score: updatedScore))

                // Record trend after fix
                if trend {
                    var trendDir = resolvePath(paths.first ?? ".")
                    var isDirFlag: ObjCBool = false
                    if FileManager.default.fileExists(atPath: trendDir, isDirectory: &isDirFlag), !isDirFlag.boolValue {
                        trendDir = (trendDir as NSString).deletingLastPathComponent
                    }
                    let tracker = TrendTracker(directory: trendDir)
                    let trendOutput = tracker.formatTrend(currentScore: updatedScore)
                    tracker.record(score: updatedScore)
                    print(trendOutput)
                }

                let errorCount = allDiagnostics.filter { $0.severity == .error }.count
                if errorCount > 0 { throw ExitCode(1) }
                if let threshold = minScore, updatedScore.score < threshold {
                    printError("Score \(String(format: "%.1f", updatedScore.score)) is below minimum threshold \(String(format: "%.1f", threshold))")
                    throw ExitCode(1)
                }
                return
            }
        }

        // Load trend history (before output so formatters can use it)
        var trendEntries: [TrendTracker.Entry] = []
        var tracker: TrendTracker? = nil
        if trend {
            var trendDir = resolvePath(paths.first ?? ".")
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: trendDir, isDirectory: &isDir), !isDir.boolValue {
                trendDir = (trendDir as NSString).deletingLastPathComponent
            }
            let t = TrendTracker(directory: trendDir)
            tracker = t
            trendEntries = t.load().entries
        }

        // Output results
        switch format {
        case .terminal:
            let basePath = paths.count == 1 ? resolvePath(paths[0]) : nil
            let formatter = TerminalFormatter()
            print(formatter.format(allDiagnostics, relativeTo: basePath, score: score))

        case .json:
            let formatter = JSONFormatter()
            let output = try formatter.format(allDiagnostics, score: score, trendEntries: trendEntries)
            print(output)

        case .xcode:
            let formatter = XcodeFormatter()
            print(formatter.format(allDiagnostics, score: score), terminator: "")

        case .html:
            let formatter = HTMLFormatter()
            print(formatter.format(allDiagnostics, allRules: registry.rules, score: score, trendEntries: trendEntries))
        }

        // Per-view scoring
        if perView {
            let viewScorer = ViewScorer()
            let views = viewScorer.detectViews(filePaths: filePaths)
            let viewScores = viewScorer.scoreViews(views: views, diagnostics: allDiagnostics, rules: registry.enabledRules)
            let basePath = paths.count == 1 ? resolvePath(paths[0]) : nil
            print(viewScorer.formatViewScores(viewScores, relativeTo: basePath))
        }

        // Trend: show terminal output + record
        if let tracker = tracker {
            if format == .terminal && !trendEntries.isEmpty {
                print(tracker.formatTrend(currentScore: score))
            }
            tracker.record(score: score)
        }

        // Exit with error code if there are errors
        let errorCount = allDiagnostics.filter { $0.severity == .error }.count
        if errorCount > 0 {
            throw ExitCode(1)
        }

        // Exit with error if below minimum score
        if let threshold = minScore, score.score < threshold {
            printError("Score \(String(format: "%.1f", score.score)) is below minimum threshold \(String(format: "%.1f", threshold))")
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

/// Parse a line range specification like "50-120" or "10-30,80-100" into ClosedRange<Int> array.
func parseLineRanges(_ spec: String) -> [ClosedRange<Int>] {
    var ranges: [ClosedRange<Int>] = []
    for part in spec.split(separator: ",") {
        let trimmed = part.trimmingCharacters(in: .whitespaces)
        let components = trimmed.split(separator: "-", maxSplits: 1)
        if components.count == 2,
           let start = Int(components[0]),
           let end = Int(components[1]),
           start <= end {
            ranges.append(start...end)
        } else if components.count == 1, let line = Int(components[0]) {
            ranges.append(line...line)
        }
    }
    return ranges
}

/// Discover all .swift file paths in a directory, respecting config exclusions.
func discoverSwiftFiles(at path: String, config: A11yConfig) -> [String] {
    let fileManager = FileManager.default
    var results: [String] = []
    guard let enumerator = fileManager.enumerator(atPath: path) else { return [] }
    while let relativePath = enumerator.nextObject() as? String {
        guard relativePath.hasSuffix(".swift") else { continue }
        if config.shouldExclude(relativePath: relativePath) { continue }
        results.append((path as NSString).appendingPathComponent(relativePath))
    }
    return results
}

enum OutputFormat: String, ExpressibleByArgument {
    case terminal
    case json
    case xcode
    case html
}

// Make A11ySeverity conform to ExpressibleByArgument for CLI parsing
extension A11ySeverity: ExpressibleByArgument {}
