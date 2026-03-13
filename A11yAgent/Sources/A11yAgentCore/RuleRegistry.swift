import Foundation
import SwiftSyntax
import SwiftParser

/// Registry of all accessibility rules. Manages rule registration, configuration,
/// and execution against source files.
public final class RuleRegistry {

    /// All registered rules.
    public private(set) var rules: [any A11yRule] = []

    /// Rule IDs to disable.
    public var disabledRuleIDs: Set<String> = []

    /// Loaded project configuration.
    public var config: A11yConfig = .empty

    /// Asset catalog colors discovered for the project (name → RGBA).
    public var assetColors: [String: (r: Double, g: Double, b: Double, a: Double)] = [:]

    /// Create a registry with all built-in rules.
    public init() {
        registerBuiltInRules()
    }

    /// Register a single rule.
    public func register(_ rule: any A11yRule) {
        rules.append(rule)
    }

    /// Register all built-in rules.
    private func registerBuiltInRules() {
        // Images (WCAG 1.1.1)
        register(ImageMissingLabelRule())
        register(ImageLabelContainsImageRule())

        // Headings (WCAG 1.3.1)
        register(HeadingTraitMissingRule())
        register(FakeHeadingInLabelRule())

        // Buttons (WCAG 4.1.2, 2.4.6)
        register(ButtonLabelContainsRoleRule())
        register(IconOnlyButtonMissingLabelRule())
        register(VisuallyDisabledNotSemanticallyRule())

        // Traits (WCAG 4.1.2)
        register(TapGestureMissingButtonTraitRule())

        // Toggles (WCAG 4.1.2)
        register(ToggleMissingLabelRule())

        // Links (WCAG 4.1.2, 2.4.4)
        register(ButtonUsedAsLinkRule())
        register(GenericLinkTextRule())

        // Touch Targets (WCAG 2.5.8)
        register(SmallTouchTargetRule())

        // Dynamic Type (WCAG 1.4.4)
        register(FixedFontSizeRule())
        register(LineLimit1Rule())

        // Page Titles (WCAG 2.4.2)
        register(MissingNavigationTitleRule())

        // Accessibility Hidden (WCAG 4.1.2)
        register(HiddenOnParentWithControlsRule())

        // Dark Mode / Contrast (WCAG 1.4.3)
        register(HardcodedColorRule())
        register(ColorContrastRule())

        // Form Controls (WCAG 4.1.2)
        register(TextFieldMissingLabelRule())
        register(SliderMissingLabelRule())
        register(StepperMissingLabelRule())
        register(PickerMissingLabelRule())

        // Focus return (WCAG 2.4.3, 2.1.2)
        register(SheetFocusReturnRule())
    }

    /// Apply a config: merge disabled rules and enabled-only from config with CLI overrides.
    public func applyConfig(_ config: A11yConfig) {
        self.config = config
        disabledRuleIDs.formUnion(config.disabledRules)
    }

    /// Get all enabled rules (excluding disabled ones, respecting enabledOnly allowlist).
    public var enabledRules: [any A11yRule] {
        var filtered = rules.filter { !disabledRuleIDs.contains($0.id) }
        if !config.enabledOnly.isEmpty {
            filtered = filtered.filter { config.enabledOnly.contains($0.id) }
        }
        return filtered
    }

    /// Analyze a single source file and return all diagnostics.
    public func analyze(sourceText: String, filePath: String) -> [A11yDiagnostic] {
        let syntax = Parser.parse(source: sourceText)
        let converter = SourceLocationConverter(fileName: filePath, tree: syntax)
        let context = RuleContext(
            filePath: filePath,
            sourceText: sourceText,
            locationConverter: converter,
            disabledRules: disabledRuleIDs,
            severityOverrides: config.severityOverrides,
            configOptions: config.options,
            assetColors: assetColors
        )

        var allDiagnostics: [A11yDiagnostic] = []
        for rule in enabledRules {
            let diagnostics = rule.check(syntax: syntax, context: context)
            allDiagnostics.append(contentsOf: diagnostics)
        }

        // Filter out inline suppressions
        allDiagnostics = InlineSuppressionFilter.filter(allDiagnostics, sourceText: sourceText)

        // Populate source snippets (1 line before through 1 line after)
        let sourceLines = sourceText.components(separatedBy: "\n")
        for i in allDiagnostics.indices {
            let diagLine = allDiagnostics[i].line // 1-based
            let start = max(0, diagLine - 2)      // 1 line before (0-based)
            let end = min(sourceLines.count - 1, diagLine) // 1 line after (0-based)
            let snippet = (start...end).map { idx in
                let lineNum = idx + 1
                let marker = (lineNum == diagLine) ? ">" : " "
                return "\(marker) \(lineNum) | \(sourceLines[idx])"
            }.joined(separator: "\n")
            allDiagnostics[i].sourceSnippet = snippet
        }

        // Sort by line, then column
        allDiagnostics.sort { ($0.line, $0.column) < ($1.line, $1.column) }
        return allDiagnostics
    }

    /// Analyze a file at the given path.
    public func analyzeFile(at path: String) throws -> [A11yDiagnostic] {
        let sourceText = try String(contentsOfFile: path, encoding: .utf8)
        return analyze(sourceText: sourceText, filePath: path)
    }

    /// Analyze all .swift files in a directory (recursively).
    public func analyzeDirectory(at path: String) throws -> [A11yDiagnostic] {
        let fileManager = FileManager.default
        var allDiagnostics: [A11yDiagnostic] = []

        guard let enumerator = fileManager.enumerator(atPath: path) else {
            return []
        }

        while let relativePath = enumerator.nextObject() as? String {
            guard relativePath.hasSuffix(".swift") else { continue }
            if config.shouldExclude(relativePath: relativePath) { continue }
            let fullPath = (path as NSString).appendingPathComponent(relativePath)
            do {
                let diagnostics = try analyzeFile(at: fullPath)
                allDiagnostics.append(contentsOf: diagnostics)
            } catch {
                // Skip files that can't be read
                continue
            }
        }

        allDiagnostics.sort { ($0.filePath, $0.line, $0.column) < ($1.filePath, $1.line, $1.column) }
        return allDiagnostics
    }
}
