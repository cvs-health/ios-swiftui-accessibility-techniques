import SwiftSyntax

// MARK: - Fixed Font Size Rule

/// Flags `.font(.system(size: N))` which doesn't scale with Dynamic Type.
/// Users should use semantic text styles like `.font(.body)` instead.
///
/// WCAG 1.4.4 Resize Text
/// Reference: DynamicTypeView.swift — bad example uses .font(.system(size: 30))
public struct FixedFontSizeRule: A11yRule {
    public let id = "fixed-font-size"
    public let name = "Fixed Font Size (No Dynamic Type)"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.4.4"]
    public let description = "Use Dynamic Type text styles (.font(.body), .font(.title), etc.) instead of fixed font sizes so text scales with user preferences."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for mod in collector.modifiers(named: "font") {
            let argText = mod.arguments.first?.text ?? ""
            // Detect .system(size: N) pattern
            if argText.contains("system(size:") || argText.contains(".system(size:") {
                let fix = makeReplacementFix(
                    node: mod.callExpr,
                    replacementText: ".font(.body)",
                    description: "Replace with .font(.body)",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "Fixed font size doesn't scale with Dynamic Type. Use semantic text styles like .font(.body) or .font(.title) instead.",
                    node: mod.reportNode,
                    context: context,
                    fix: fix,
                    suggestion: "Replace .font(.system(size:)) with .font(.body) or another text style"
                ))
                continue
            }

            // A custom typeface at a fixed size never scales unless it is anchored to a
            // text style with `relativeTo:`. This is worse than `.system(size:)`, which at
            // least tracks the system font, so it is reported the same way.
            if Self.isCustomFont(argText), !argText.contains("relativeTo:") {
                diagnostics.append(makeDiagnostic(
                    message: "Custom font at a fixed size doesn't scale with Dynamic Type. Add a `relativeTo:` text style, e.g. .font(.custom(\"Name\", size: 17, relativeTo: .body)).",
                    node: mod.reportNode,
                    context: context,
                    suggestion: "Add relativeTo: to anchor the custom font to a Dynamic Type text style"
                ))
                continue
            }

            // A UIFont at a fixed size has the same problem, and needs UIFontMetrics to
            // scale. `UIFont.preferredFont(forTextStyle:)` already scales, so it is exempt.
            if Self.isUnscaledUIFont(argText) {
                diagnostics.append(makeDiagnostic(
                    message: "UIFont at a fixed size doesn't scale with Dynamic Type. Scale it with UIFontMetrics, or use a SwiftUI text style such as .font(.body).",
                    node: mod.reportNode,
                    context: context,
                    suggestion: "Wrap the UIFont in UIFontMetrics, or use a SwiftUI text style"
                ))
            }
        }
        return diagnostics
    }

    /// `.custom("Name", size: 17)` or `Font.custom(...)`, in any spelling.
    private static func isCustomFont(_ text: String) -> Bool {
        (text.contains(".custom(") || text.hasPrefix("custom("))
            && text.contains("size:")
    }

    /// A UIFont built at an explicit size, which does not scale on its own.
    /// `preferredFont(forTextStyle:)` and anything already wrapped in UIFontMetrics scale.
    private static func isUnscaledUIFont(_ text: String) -> Bool {
        guard text.contains("UIFont") else { return false }
        if text.contains("UIFontMetrics") || text.contains("preferredFont") { return false }
        return text.contains("UIFont(name:")
            || text.contains("systemFont(ofSize:")
            || text.contains("monospacedSystemFont(ofSize:")
            || text.contains("boldSystemFont(ofSize:")
    }
}

// MARK: - Line Limit 1 Rule

/// Flags `.lineLimit(1)` which truncates text and prevents Dynamic Type scaling.
///
/// WCAG 1.4.4 Resize Text
/// Reference: DynamicTypeView.swift — bad example uses .lineLimit(1)
public struct LineLimit1Rule: A11yRule {
    public let id = "line-limit-1"
    public let name = "lineLimit(1) Truncates Text"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.4.4"]
    public let description = ".lineLimit(1) truncates text at larger Dynamic Type sizes. Remove it or use a higher limit."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for mod in collector.modifiers(named: "lineLimit") {
            let argText = mod.arguments.first?.text ?? ""
            if argText == "1" {
                var fix: A11yFix? = nil
                if let memberAccess = mod.callExpr.calledExpression.as(MemberAccessExprSyntax.self) {
                    let offset = syntax.position.utf8Offset
                    let startOffset = memberAccess.period.position.utf8Offset - offset
                    let endOffset = mod.callExpr.endPositionBeforeTrailingTrivia.utf8Offset - offset
                    fix = A11yFix(
                        description: "Remove .lineLimit(1)",
                        replacementText: "",
                        startOffset: startOffset,
                        endOffset: endOffset
                    )
                }
                diagnostics.append(makeDiagnostic(
                    message: ".lineLimit(1) will truncate text at larger Dynamic Type sizes. Remove the limit or use a higher value.",
                    node: mod.reportNode,
                    context: context,
                    fix: fix,
                    suggestion: "Remove .lineLimit(1) or increase to .lineLimit(3) or higher"
                ))
            }
        }
        return diagnostics
    }
}
