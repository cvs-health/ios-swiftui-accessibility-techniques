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

import SwiftSyntax

// MARK: - Duplicate Button Label Rule

/// Flags Button views whose visible label is repeated in the same file without a unique
/// .accessibilityLabel(), and Buttons with static labels inside ForEach closures.
///
/// When multiple Buttons share the same visible label (e.g. two "View Details" buttons in a
/// list), VoiceOver users navigating by controls hear identical announcements and cannot
/// distinguish which button acts on which item. Each must have a unique .accessibilityLabel()
/// that includes context (e.g. "View Details for a11y-intelligence").
///
/// Note: this rule checks standard SwiftUI Button and any component with a `title:` argument
/// directly inside ForEach. Components whose buttons are inside a child view that is then
/// used in ForEach require cross-file analysis and must be audited manually.
///
/// WCAG 2.4.6 Headings and Labels
/// CVS test case: TLASTIATI-1552 — "Check that each repeated control with the same label text
/// speaks a unique and specific accessibility label to VoiceOver."
public struct DuplicateButtonLabelRule: A11yRule {
    public let id = "duplicate-button-label"
    public let name = "Duplicate Button Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.4.6"]
    public let description = "Repeated Buttons with the same visible label must each have a unique .accessibilityLabel() so VoiceOver users can distinguish them. Fails WCAG 2.4.6b Descriptive Labels."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        var diagnostics: [A11yDiagnostic] = []
        var flaggedPositions = Set<Int>()

        // --- Check 1: Button/title-arg calls directly inside ForEach without .accessibilityLabel() ---
        let forEachScanner = ForEachButtonScanner(viewMode: .sourceAccurate)
        forEachScanner.walk(syntax)

        for finding in forEachScanner.findings {
            let position = finding.node.positionAfterSkippingLeadingTrivia.utf8Offset
            flaggedPositions.insert(position)
            diagnostics.append(makeDiagnostic(
                message: "\"\(finding.labelText)\" inside ForEach will repeat the same label for every item. Add .accessibilityLabel() including the item's context (e.g. \"\(finding.labelText) for \\(item.name)\") so VoiceOver users can distinguish each control. [WCAG 2.4.6b]",
                node: finding.node,
                context: context,
                suggestion: "Add .accessibilityLabel(\"\\(finding.labelText) for \\(item.name)\")"
            ))
        }

        // --- Check 2: Button("same text") appears 2+ times in the same file ---
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var buttonsByLabel: [String: [ViewHierarchyVisitor.DetectedView]] = [:]

        for button in visitor.views(ofType: "Button") {
            guard let labelText = button.firstStringArgument, !labelText.isEmpty else { continue }
            guard !button.modifiers.hasModifier("accessibilityLabel") else { continue }
            buttonsByLabel[labelText, default: []].append(button)
        }

        for (labelText, buttons) in buttonsByLabel where buttons.count > 1 {
            for button in buttons {
                let position = button.callExpr.positionAfterSkippingLeadingTrivia.utf8Offset
                guard !flaggedPositions.contains(position) else { continue }
                flaggedPositions.insert(position)
                diagnostics.append(makeDiagnostic(
                    message: "Button(\"\(labelText)\") appears \(buttons.count) times in this file with the same label and no .accessibilityLabel(). VoiceOver users cannot distinguish them. Add unique context to each (e.g. \"\(labelText) for [item name]\"). [WCAG 2.4.6b]",
                    node: button.callExpr,
                    context: context,
                    suggestion: "Add .accessibilityLabel(\"\\(labelText) for [specific context]\")"
                ))
            }
        }

        return diagnostics
    }
}

// MARK: - Shared Finding Type

private struct ButtonLabelFinding {
    let node: FunctionCallExprSyntax
    let labelText: String
}

// MARK: - ForEach Button Scanner

/// Walks the AST looking for ForEach calls. Inside each ForEach closure it finds:
/// - Standard `Button("static label")` views
/// - Any call with a `title: "static label"` argument (catches PSButton, custom components)
///
/// Reports calls that have a static string label but no `.accessibilityLabel()` modifier.
private final class ForEachButtonScanner: SyntaxVisitor {
    private(set) var findings: [ButtonLabelFinding] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let callee = node.calledExpression.as(DeclReferenceExprSyntax.self),
              callee.baseName.text == "ForEach" else {
            return .visitChildren
        }

        if let closure = node.trailingClosure {
            scanClosure(closure)
        }
        return .visitChildren
    }

    private func scanClosure(_ closure: ClosureExprSyntax) {
        let inner = InnerButtonScanner(viewMode: .sourceAccurate)
        inner.walk(closure)
        findings.append(contentsOf: inner.findings)
    }
}

// MARK: - Inner Button Scanner

/// Scans a syntax subtree for button-like calls with static string labels.
private final class InnerButtonScanner: SyntaxVisitor {
    private(set) var findings: [ButtonLabelFinding] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let labelText = extractButtonLabel(from: node) else {
            return .visitChildren
        }

        // Check the full modifier chain for .accessibilityLabel()
        let chainRoot = findChainRoot(for: ExprSyntax(node))
        let modifiers = ModifierCollector.collect(from: chainRoot)
        guard !modifiers.hasModifier("accessibilityLabel") else {
            return .visitChildren
        }

        findings.append(ButtonLabelFinding(node: node, labelText: labelText))
        return .visitChildren
    }

    /// Extracts a static string label from a Button or any call with a `title:` argument.
    private func extractButtonLabel(from node: FunctionCallExprSyntax) -> String? {
        let callee = node.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text ?? ""

        // Standard Button("label") { } — first unlabeled argument
        if callee == "Button" {
            if let first = node.arguments.first, first.label == nil {
                return extractStaticString(from: first.expression)
            }
        }

        // Any component with title: "label" (e.g. PSButton, custom buttons)
        if let titleArg = node.arguments.first(where: { $0.label?.text == "title" }) {
            return extractStaticString(from: titleArg.expression)
        }

        return nil
    }

    /// Returns the string value if the expression is a string literal or String(localized: "...").
    /// Returns nil for interpolated strings or dynamic values — those are runtime-unique by definition.
    private func extractStaticString(from expr: ExprSyntax?) -> String? {
        guard let expr else { return nil }

        // Direct literal: "View Details"
        if let strLit = expr.as(StringLiteralExprSyntax.self) {
            // Reject interpolated strings — they are dynamic and likely already unique
            let hasInterpolation = strLit.segments.contains { $0.is(ExpressionSegmentSyntax.self) }
            guard !hasInterpolation else { return nil }
            return strLit.segments.compactMap { $0.as(StringSegmentSyntax.self)?.content.text }.joined()
        }

        // String(localized: "View Details")
        if let call = expr.as(FunctionCallExprSyntax.self),
           call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text == "String",
           let localizedArg = call.arguments.first(where: { $0.label?.text == "localized" }),
           let strLit = localizedArg.expression.as(StringLiteralExprSyntax.self) {
            let hasInterpolation = strLit.segments.contains { $0.is(ExpressionSegmentSyntax.self) }
            guard !hasInterpolation else { return nil }
            return strLit.segments.compactMap { $0.as(StringSegmentSyntax.self)?.content.text }.joined()
        }

        return nil
    }

    /// Walks up the AST to find the outermost expression in a modifier chain.
    private func findChainRoot(for expr: ExprSyntax) -> ExprSyntax {
        var current = expr
        while let parent = current.parent {
            if let memberAccess = parent.as(MemberAccessExprSyntax.self),
               let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self),
               memberAccess.base?.id == current.id {
                current = ExprSyntax(grandparent)
                continue
            }
            if let funcCall = parent.as(FunctionCallExprSyntax.self),
               let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
               memberAccess.base?.id == current.id {
                current = ExprSyntax(funcCall)
                continue
            }
            break
        }
        return current
    }
}
