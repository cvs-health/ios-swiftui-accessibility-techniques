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
    public let severity = A11ySeverity.warning
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
                diagnostics.append(makeDiagnostic(
                    message: "Fixed font size doesn't scale with Dynamic Type. Use semantic text styles like .font(.body) or .font(.title) instead.",
                    node: mod.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
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
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["1.4.4"]
    public let description = ".lineLimit(1) truncates text at larger Dynamic Type sizes. Remove it or use a higher limit."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for mod in collector.modifiers(named: "lineLimit") {
            let argText = mod.arguments.first?.text ?? ""
            if argText == "1" {
                diagnostics.append(makeDiagnostic(
                    message: ".lineLimit(1) will truncate text at larger Dynamic Type sizes. Remove the limit or use a higher value.",
                    node: mod.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}
