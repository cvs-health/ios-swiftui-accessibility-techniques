/*
   Copyright 2026 CVS Health and/or one of its affiliates

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

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
    /// Asset catalog colors resolved for the project, including dark-mode and high-contrast variants.
    public let assetColors: AssetCatalogParser.ThemedColorMap

    public init(
        filePath: String,
        sourceText: String,
        locationConverter: SourceLocationConverter,
        disabledRules: Set<String> = [],
        severityOverrides: [String: A11ySeverity] = [:],
        configOptions: A11yConfig.ConfigOptions = .init(),
        assetColors: AssetCatalogParser.ThemedColorMap = [:]
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
    /// Impact on users (critical/serious/moderate/minor).
    var impact: A11yImpact { get }
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
        wcagCriteriaOverride: [String]? = nil,
        fix: A11yFix? = nil,
        suggestion: String? = nil
    ) -> A11yDiagnostic {
        let effectiveSeverity = severityOverride
            ?? context.severityOverrides[id]
            ?? severity
        return A11yDiagnostic(
            ruleID: id,
            severity: effectiveSeverity,
            impact: impact,
            message: message,
            filePath: context.filePath,
            line: context.line(for: node.positionAfterSkippingLeadingTrivia),
            column: context.column(for: node.positionAfterSkippingLeadingTrivia),
            wcagCriteria: wcagCriteriaOverride ?? wcagCriteria,
            fix: fix,
            suggestion: suggestion
        )
    }

    public func makeModifierFix(
        chainRoot: ExprSyntax,
        modifier: String,
        sourceFile: SourceFileSyntax
    ) -> A11yFix? {
        let endPosition = chainRoot.endPositionBeforeTrailingTrivia
        let offset = sourceFile.position.utf8Offset
        let insertOffset = endPosition.utf8Offset - offset

        let indentEnd = chainRoot.positionAfterSkippingLeadingTrivia
        let lineStart = chainRoot.position
        let leadingTrivia = sourceFile.description[
            sourceFile.description.utf8.index(sourceFile.description.utf8.startIndex, offsetBy: lineStart.utf8Offset - offset)
            ..<
            sourceFile.description.utf8.index(sourceFile.description.utf8.startIndex, offsetBy: indentEnd.utf8Offset - offset)
        ]
        let indent = leadingTrivia.filter { $0 == " " || $0 == "\t" }

        let replacement = "\n\(indent)    \(modifier)"

        return A11yFix(
            description: "Add \(modifier)",
            replacementText: replacement,
            startOffset: insertOffset,
            endOffset: insertOffset
        )
    }

    public func makeReplacementFix(
        node: some SyntaxProtocol,
        replacementText: String,
        description: String,
        sourceFile: SourceFileSyntax
    ) -> A11yFix? {
        let offset = sourceFile.position.utf8Offset
        let startOffset = node.positionAfterSkippingLeadingTrivia.utf8Offset - offset
        let endOffset = node.endPositionBeforeTrailingTrivia.utf8Offset - offset
        return A11yFix(
            description: description,
            replacementText: replacementText,
            startOffset: startOffset,
            endOffset: endOffset
        )
    }

    public func makeStringReplacementFix(
        callExpr: FunctionCallExprSyntax,
        originalText: String,
        word: String,
        sourceFile: SourceFileSyntax
    ) -> A11yFix? {
        guard let firstArg = callExpr.arguments.first,
              let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
              let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }

        var cleaned = originalText
        if let range = cleaned.range(of: word, options: .caseInsensitive) {
            cleaned.removeSubrange(range)
        }
        cleaned = cleaned.split(separator: " ").joined(separator: " ")
        cleaned = cleaned.trimmingCharacters(in: .whitespaces)

        let offset = sourceFile.position.utf8Offset
        let startOffset = segment.positionAfterSkippingLeadingTrivia.utf8Offset - offset
        let endOffset = segment.endPositionBeforeTrailingTrivia.utf8Offset - offset

        return A11yFix(
            description: "Remove \"\(word)\" from label",
            replacementText: cleaned,
            startOffset: startOffset,
            endOffset: endOffset
        )
    }
}
