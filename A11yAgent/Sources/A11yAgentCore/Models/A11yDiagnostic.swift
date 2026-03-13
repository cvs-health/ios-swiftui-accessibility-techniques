import Foundation

/// Severity level for accessibility diagnostics.
public enum A11ySeverity: String, Codable, Comparable, Sendable {
    case error
    case warning
    case info

    public static func < (lhs: A11ySeverity, rhs: A11ySeverity) -> Bool {
        let order: [A11ySeverity] = [.info, .warning, .error]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

/// A suggested fix for an accessibility issue.
public struct A11yFix: Sendable {
    /// Human-readable description of the fix.
    public let description: String
    /// The text to replace the problematic code with.
    public let replacementText: String
    /// The byte range in the source file to replace (..<endOffset).
    public let startOffset: Int
    public let endOffset: Int

    public init(description: String, replacementText: String, startOffset: Int, endOffset: Int) {
        self.description = description
        self.replacementText = replacementText
        self.startOffset = startOffset
        self.endOffset = endOffset
    }
}

/// A single accessibility diagnostic produced by a rule.
public struct A11yDiagnostic: Sendable {
    /// The rule that produced this diagnostic.
    public let ruleID: String
    /// Severity of the issue.
    public let severity: A11ySeverity
    /// Human-readable message describing the issue.
    public let message: String
    /// Path to the source file.
    public let filePath: String
    /// 1-based line number.
    public let line: Int
    /// 1-based column number.
    public let column: Int
    /// WCAG 2.2 success criteria this relates to (e.g., ["1.1.1", "4.1.2"]).
    public let wcagCriteria: [String]
    /// Optional auto-fix.
    public let fix: A11yFix?
    /// Short suggestion for how to fix the issue (shown in reports).
    public let suggestion: String?
    /// Source lines around the diagnostic (populated after analysis).
    public var sourceSnippet: String?

    public init(
        ruleID: String,
        severity: A11ySeverity,
        message: String,
        filePath: String,
        line: Int,
        column: Int,
        wcagCriteria: [String] = [],
        fix: A11yFix? = nil,
        suggestion: String? = nil,
        sourceSnippet: String? = nil
    ) {
        self.ruleID = ruleID
        self.severity = severity
        self.message = message
        self.filePath = filePath
        self.line = line
        self.column = column
        self.wcagCriteria = wcagCriteria
        self.fix = fix
        self.suggestion = suggestion
        self.sourceSnippet = sourceSnippet
    }
}
