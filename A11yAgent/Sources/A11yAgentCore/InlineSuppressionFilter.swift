import Foundation

/// Filters diagnostics based on inline suppression comments in source code.
///
/// Supported formats:
///   `// a11y-check:disable rule-id, rule-id`   — suppress on this line
///   `// a11y-check:disable`                     — suppress all rules on this line
///   `// a11y-check:disable-next-line rule-id`   — suppress on the next line
///   `// a11y-check:disable-next-line`           — suppress all rules on the next line
public enum InlineSuppressionFilter {

    struct Suppression {
        let line: Int
        let ruleIDs: Set<String>?  // nil means suppress all rules
    }

    /// Filter diagnostics, removing any that are suppressed by inline comments.
    public static func filter(_ diagnostics: [A11yDiagnostic], sourceText: String) -> [A11yDiagnostic] {
        let suppressions = parseSuppressionsFromSource(sourceText)
        guard !suppressions.isEmpty else { return diagnostics }

        return diagnostics.filter { diag in
            !suppressions.contains { sup in
                sup.line == diag.line && (sup.ruleIDs == nil || sup.ruleIDs!.contains(diag.ruleID))
            }
        }
    }

    static func parseSuppressionsFromSource(_ source: String) -> [Suppression] {
        var suppressions: [Suppression] = []
        let lines = source.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1  // 1-based
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Check for disable-next-line (must come before disable check)
            if let range = trimmed.range(of: "// a11y-check:disable-next-line") {
                let afterDirective = trimmed[range.upperBound...].trimmingCharacters(in: .whitespaces)
                let ruleIDs = parseRuleIDs(afterDirective)
                suppressions.append(Suppression(line: lineNumber + 1, ruleIDs: ruleIDs))
                continue
            }

            // Check for same-line disable (comment can be at end of code line or standalone)
            if let range = trimmed.range(of: "// a11y-check:disable") {
                let afterDirective = trimmed[range.upperBound...].trimmingCharacters(in: .whitespaces)
                // Make sure we didn't match "disable-next-line" partially
                if afterDirective.hasPrefix("-next-line") { continue }
                let ruleIDs = parseRuleIDs(afterDirective)
                suppressions.append(Suppression(line: lineNumber, ruleIDs: ruleIDs))
            }
        }

        return suppressions
    }

    /// Parse comma-separated rule IDs. Returns nil if empty (meaning suppress all).
    private static func parseRuleIDs(_ text: String) -> Set<String>? {
        let ids = text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return ids.isEmpty ? nil : Set(ids)
    }
}
