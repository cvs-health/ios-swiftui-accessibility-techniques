import Foundation
import SwiftSyntax

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
        /// Whether the suppression covers the whole statement starting at `line` rather than
        /// that line alone. Set for directives imported from SwiftLint: it reports a rule at a
        /// different node of a view chain than this tool does, so matching one line misses.
        let coversStatement: Bool

        init(line: Int, ruleIDs: Set<String>?, coversStatement: Bool = false) {
            self.line = line
            self.ruleIDs = ruleIDs
            self.coversStatement = coversStatement
        }
    }

    /// Filter diagnostics, removing any that are suppressed by inline comments.
    ///
    /// `statementRanges` maps a line to the span of the statement beginning there. It is only
    /// needed for directives imported from SwiftLint — see `Suppression.coversStatement` — so
    /// callers without a parsed tree may omit it and those directives then match a single line.
    public static func filter(
        _ diagnostics: [A11yDiagnostic],
        sourceText: String,
        statementRanges: [Int: ClosedRange<Int>] = [:]
    ) -> [A11yDiagnostic] {
        let suppressions = parseSuppressionsFromSource(sourceText)
        guard !suppressions.isEmpty else { return diagnostics }

        return diagnostics.filter { diag in
            !suppressions.contains { sup in
                guard sup.ruleIDs == nil || sup.ruleIDs!.contains(diag.ruleID) else { return false }
                if sup.coversStatement, let range = statementRanges[sup.line] {
                    return range.contains(diag.line)
                }
                return sup.line == diag.line
            }
        }
    }

    /// Line → span of the statement starting on that line.
    ///
    /// A SwiftUI view is one statement spread over many lines, and the two linters report inside
    /// it at different points: SwiftLint flags `accessibility_trait_for_button` at the view, this
    /// tool flags it at the `.onTapGesture` several lines further down. Matching a single line
    /// therefore honoured none of the real directives in one app — 7 findings carried one, at
    /// gaps of 3 to 9 lines.
    public static func statementRanges(
        syntax: SourceFileSyntax,
        converter: SourceLocationConverter
    ) -> [Int: ClosedRange<Int>] {
        var ranges: [Int: ClosedRange<Int>] = [:]
        let collector = StatementCollector(viewMode: .sourceAccurate)
        collector.walk(syntax)
        for item in collector.items {
            let start = converter.location(for: item.positionAfterSkippingLeadingTrivia).line
            let end = converter.location(for: item.endPositionBeforeTrailingTrivia).line
            guard start <= end else { continue }
            // An outer statement encloses inner ones; keep the innermost so a directive before a
            // nested view does not silence the whole surrounding body.
            if let existing = ranges[start], existing.count <= (end - start + 1) { continue }
            ranges[start] = start...end
        }
        return ranges
    }

    private final class StatementCollector: SyntaxVisitor {
        var items: [CodeBlockItemSyntax] = []
        override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
            items.append(node)
            return .visitChildren
        }
    }

    /// SwiftLint accessibility rules that check the same thing as one of ours.
    ///
    /// SwiftLint ships exactly two accessibility rules, and both have an exact counterpart here.
    /// An author who wrote `// swiftlint:disable:next accessibility_label_for_image` has already
    /// declared that this image is intentionally unlabelled — in the vocabulary of the linter
    /// their project had at the time. Making them restate it in a second, near-identical
    /// directive is friction that yields no new information, and the declaration is sitting in
    /// the code already. One real app carried 25 of these.
    ///
    /// Deliberately limited to the line-scoped forms — `:next`, `:this`, `:previous`. SwiftLint's
    /// region form (`disable` … `enable`) can silence a whole file, and inheriting that silently
    /// would blind this tool across code nobody meant to exempt from it.
    static let swiftLintEquivalents: [String: String] = [
        "accessibility_label_for_image": "image-missing-label",
        "accessibility_trait_for_button": "tap-gesture-missing-button-trait",
    ]

    static func parseSuppressionsFromSource(_ source: String) -> [Suppression] {
        var suppressions: [Suppression] = []
        let lines = source.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1  // 1-based
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Honour an equivalent SwiftLint directive, line-scoped forms only.
            for (scope, offset) in [("next", 1), ("this", 0), ("previous", -1)] {
                guard let range = trimmed.range(of: "// swiftlint:disable:\(scope)") else { continue }
                let after = trimmed[range.upperBound...]
                let mapped = after
                    .split(whereSeparator: { $0 == " " || $0 == "," })
                    .compactMap { swiftLintEquivalents[String($0)] }
                if !mapped.isEmpty {
                    suppressions.append(
                        Suppression(
                            line: lineNumber + offset,
                            ruleIDs: Set(mapped),
                            coversStatement: true
                        )
                    )
                }
            }

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
    /// Parse comma-separated rule IDs. Returns nil if empty (meaning suppress all).
    ///
    /// Only the leading rule-ID-shaped token of each comma-separated piece is read, so a note
    /// after the IDs does not change which rules are suppressed:
    ///
    ///     // a11y-check:disable-next-line sheet-focus-return  (restored via Combine)
    ///
    /// Previously the whole piece became the ID, so that line silently suppressed nothing —
    /// the directive looked right and the diagnostic still fired. A rule ID is lowercase
    /// letters, digits and hyphens, which no prose starts with by accident.
    private static func parseRuleIDs(_ text: String) -> Set<String>? {
        let ids = text.split(separator: ",")
            .compactMap { piece -> String? in
                let token = piece
                    .trimmingCharacters(in: .whitespaces)
                    .prefix { $0.isLowercase && $0.isLetter || $0.isNumber || $0 == "-" }
                return token.isEmpty ? nil : String(token)
            }
        return ids.isEmpty ? nil : Set(ids)
    }
}
