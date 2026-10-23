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

    /// Where a suppression was declared. Reported separately so a run is never silently
    /// quieter than it looks — a directive written for another tool is the one a reader is
    /// least likely to have in mind when they wonder where a finding went.
    enum Origin {
        case own
        case swiftLint
    }

    struct Suppression {
        let line: Int
        let ruleIDs: Set<String>?  // nil means suppress all rules
        let origin: Origin
        /// Whether the suppression covers the whole statement starting at `line` rather than
        /// that line alone. Set for directives imported from SwiftLint: it reports a rule at a
        /// different node of a view chain than this tool does, so matching one line misses.
        let coversStatement: Bool

        init(
            line: Int,
            ruleIDs: Set<String>?,
            coversStatement: Bool = false,
            origin: Origin = .own
        ) {
            self.line = line
            self.ruleIDs = ruleIDs
            self.coversStatement = coversStatement
            self.origin = origin
        }
    }

    /// Filter diagnostics, removing any that are suppressed by inline comments.
    ///
    /// `statementRanges` maps a line to the span of the statement beginning there. It is only
    /// needed for directives imported from SwiftLint — see `Suppression.coversStatement` — so
    /// callers without a parsed tree may omit it and those directives then match a single line.
    /// Diagnostics that survived, with a count of what was dropped and how much of that came
    /// from a directive written for SwiftLint.
    public struct Outcome {
        public let kept: [A11yDiagnostic]
        public let suppressed: Int
        public let suppressedBySwiftLint: Int
    }

    public static func filter(
        _ diagnostics: [A11yDiagnostic],
        sourceText: String,
        statementRanges: [Int: ClosedRange<Int>] = [:]
    ) -> [A11yDiagnostic] {
        apply(diagnostics, sourceText: sourceText, statementRanges: statementRanges).kept
    }

    public static func apply(
        _ diagnostics: [A11yDiagnostic],
        sourceText: String,
        statementRanges: [Int: ClosedRange<Int>] = [:]
    ) -> Outcome {
        let kept = filterInternal(diagnostics, sourceText: sourceText, statementRanges: statementRanges)
        guard kept.count != diagnostics.count else {
            return Outcome(kept: kept, suppressed: 0, suppressedBySwiftLint: 0)
        }
        // Re-run with the imported mapping empty to separate the two origins. Cheap: it is a
        // line scan over one file, and only when something was actually suppressed.
        let withoutImported = filterInternal(
            diagnostics,
            sourceText: sourceText,
            statementRanges: statementRanges,
            honourSwiftLint: false
        )
        return Outcome(
            kept: kept,
            suppressed: diagnostics.count - kept.count,
            suppressedBySwiftLint: withoutImported.count - kept.count
        )
    }

    private static func filterInternal(
        _ diagnostics: [A11yDiagnostic],
        sourceText: String,
        statementRanges: [Int: ClosedRange<Int>] = [:],
        honourSwiftLint: Bool = true
    ) -> [A11yDiagnostic] {
        let fileLevel = parseFileSuppressions(sourceText)
        if fileLevel.contains(where: { $0 == nil }) { return [] }

        let suppressions = parseSuppressionsFromSource(sourceText)
            .filter { honourSwiftLint || $0.origin == .own }
        guard !suppressions.isEmpty || !fileLevel.isEmpty
            || (honourSwiftLint && !parseSwiftLintRegions(sourceText).isEmpty)
        else { return diagnostics }

        let fileSuppressedRules = Set(fileLevel.compactMap { $0 }.flatMap { $0 })
        let regions = honourSwiftLint ? parseSwiftLintRegions(sourceText) : []

        return diagnostics.filter { diag in
            if fileSuppressedRules.contains(diag.ruleID) { return false }
            if regions.contains(where: { $0.rules.contains(diag.ruleID) && $0.lines.contains(diag.line) }) {
                return false
            }
            return
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

    /// Closed SwiftLint `disable` … `enable` regions, mapped to our rule IDs.
    ///
    /// The region form was initially not inherited on the grounds that it can silence a whole
    /// file. That is true of an *unclosed* region, and false of every real one examined: three
    /// regions in one app each wrapped a single function in 8 to 17 lines and closed properly,
    /// which is the same quality of declared intent as the `:next` form. So a closed region is
    /// honoured and an unclosed one is not — the latter being exactly the blanket case, for
    /// which `a11y-check:disable-file` is the explicit tool.
    ///
    /// `disable` is matched with a following space so `disable:next` does not read as a region.
    static func parseSwiftLintRegions(_ source: String) -> [(rules: Set<String>, lines: ClosedRange<Int>)] {
        var open: [String: Int] = [:]          // our rule ID → line the region opened on
        var closed: [(rules: Set<String>, lines: ClosedRange<Int>)] = []

        func mappedRules(_ text: Substring) -> [String] {
            text.split(whereSeparator: { $0 == " " || $0 == "," })
                .compactMap { swiftLintEquivalents[String($0)] }
        }

        for (index, line) in source.components(separatedBy: .newlines).enumerated() {
            let lineNumber = index + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if let range = trimmed.range(of: "// swiftlint:disable ") {
                for rule in mappedRules(trimmed[range.upperBound...]) where open[rule] == nil {
                    open[rule] = lineNumber
                }
            }
            if let range = trimmed.range(of: "// swiftlint:enable ") {
                for rule in mappedRules(trimmed[range.upperBound...]) {
                    guard let start = open.removeValue(forKey: rule), start <= lineNumber else { continue }
                    closed.append((rules: [rule], lines: start...lineNumber))
                }
            }
        }
        // Anything still open was never closed: deliberately dropped.
        return closed
    }

    /// Rule sets suppressed for the whole file. A `nil` element means every rule.
    static func parseFileSuppressions(_ source: String) -> [Set<String>?] {
        var fileLevel: [Set<String>?] = []
        for line in source.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard let range = trimmed.range(of: "// a11y-check:disable-file") else { continue }
            let after = trimmed[range.upperBound...].trimmingCharacters(in: .whitespaces)
            fileLevel.append(parseRuleIDs(after))
        }
        return fileLevel
    }

    static func parseSuppressionsFromSource(_ source: String) -> [Suppression] {
        var suppressions: [Suppression] = []
        var fileLevel: [Set<String>?] = []
        _ = fileLevel  // collected separately by parseFileSuppressions
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
                            coversStatement: true,
                            origin: .swiftLint
                        )
                    )
                }
            }

            // File-level. Deliberately position-independent: the directive says "file", so it
            // reads the same wherever it sits and does not depend on being above the code it
            // covers. Must be tested before the line forms, since "disable" prefixes it.
            if let range = trimmed.range(of: "// a11y-check:disable-file") {
                let after = trimmed[range.upperBound...].trimmingCharacters(in: .whitespaces)
                fileLevel.append(parseRuleIDs(after))
                continue
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
                // Make sure we didn't match a longer directive partially
                if afterDirective.hasPrefix("-next-line") || afterDirective.hasPrefix("-file") { continue }
                let ruleIDs = parseRuleIDs(afterDirective)
                suppressions.append(Suppression(line: lineNumber, ruleIDs: ruleIDs))
            }
        }

        return suppressions
    }

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
