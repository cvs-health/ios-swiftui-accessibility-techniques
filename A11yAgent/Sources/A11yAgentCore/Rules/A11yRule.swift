import Foundation
import SwiftSyntax

/// Context passed to each rule during analysis.
public struct RuleContext {
    /// Absolute path to the file being analyzed.
    public let filePath: String
    /// Full source text of the file.
    public let sourceText: String
    /// The parsed source location converter for mapping offsets to lines/columns.
    public let locationConverter: SourceLocationConverter
    /// Per-rule configuration overrides (ruleID → enabled).
    public let disabledRules: Set<String>
    /// Severity overrides from configuration file.
    public let severityOverrides: [String: A11ySeverity]
    /// Project configuration options.
    public let configOptions: A11yConfig.ConfigOptions
    /// Asset catalog colors resolved for the project (name → RGBA).
    public let assetColors: [String: (r: Double, g: Double, b: Double, a: Double)]

    public init(
        filePath: String,
        sourceText: String,
        locationConverter: SourceLocationConverter,
        disabledRules: Set<String> = [],
        severityOverrides: [String: A11ySeverity] = [:],
        configOptions: A11yConfig.ConfigOptions = .init(),
        assetColors: [String: (r: Double, g: Double, b: Double, a: Double)] = [:]
    ) {
        self.filePath = filePath
        self.sourceText = sourceText
        self.locationConverter = locationConverter
        self.disabledRules = disabledRules
        self.severityOverrides = severityOverrides
        self.configOptions = configOptions
        self.assetColors = assetColors
    }

    /// Convert a syntax node's position to a 1-based line number.
    public func line(for position: AbsolutePosition) -> Int {
        let loc = locationConverter.location(for: position)
        return loc.line
    }

    /// Convert a syntax node's position to a 1-based column number.
    public func column(for position: AbsolutePosition) -> Int {
        let loc = locationConverter.location(for: position)
        return loc.column
    }
}

/// Protocol that all accessibility rules must conform to.
public protocol A11yRule {
    /// Unique identifier, e.g. "image-missing-label".
    var id: String { get }
    /// Human-readable name, e.g. "Image Missing Accessibility Label".
    var name: String { get }
    /// Default severity.
    var severity: A11ySeverity { get }
    /// WCAG 2.2 success criteria this rule checks.
    var wcagCriteria: [String] { get }
    /// One-line description of what the rule checks.
    var description: String { get }

    /// Analyze the given source file and return diagnostics.
    func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic]
}

/// Extension with a helper to create diagnostics from within a rule.
extension A11yRule {
    public func makeDiagnostic(
        message: String,
        node: some SyntaxProtocol,
        context: RuleContext,
        severityOverride: A11ySeverity? = nil,
        fix: A11yFix? = nil,
        suggestion: String? = nil
    ) -> A11yDiagnostic {
        let effectiveSeverity = severityOverride
            ?? context.severityOverrides[id]
            ?? severity
        return A11yDiagnostic(
            ruleID: id,
            severity: effectiveSeverity,
            message: message,
            filePath: context.filePath,
            line: context.line(for: node.positionAfterSkippingLeadingTrivia),
            column: context.column(for: node.positionAfterSkippingLeadingTrivia),
            wcagCriteria: wcagCriteria,
            fix: fix,
            suggestion: suggestion
        )
    }
}
