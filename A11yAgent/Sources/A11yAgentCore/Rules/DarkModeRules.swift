import SwiftSyntax

// MARK: - Hardcoded Color Rule

/// Flags hardcoded color values like `.foregroundColor(.black)`, `.background(.white)`,
/// or custom `Color(red:green:blue:)` that may not adapt to Dark Mode or
/// meet contrast requirements.
///
/// WCAG 1.4.3 Contrast (Minimum)
/// Reference: DarkModeView.swift — bad example uses hardcoded .tint(.blue), .background(.black)
public struct HardcodedColorRule: A11yRule {
    public let id = "hardcoded-color"
    public let name = "Hardcoded Color (No Dark Mode Support)"
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["1.4.3"]
    public let description = "Hardcoded colors may not meet contrast requirements in both light and dark mode. Use semantic colors from an asset catalog with dark mode variants."

    public init() {}

    /// Hardcoded color references that are suspicious.
    private static let hardcodedColors: Set<String> = [
        ".black", ".white", "Color.black", "Color.white",
    ]

    /// Color modifiers to check.
    private static let colorModifiers = ["foregroundColor", "foregroundStyle", "background", "tint"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for modName in Self.colorModifiers {
            for mod in collector.modifiers(named: modName) {
                let argText = mod.arguments.first?.text ?? ""

                // Flag hardcoded .black / .white
                if Self.hardcodedColors.contains(argText) {
                    diagnostics.append(makeDiagnostic(
                        message: "Hardcoded color \(argText) in .\(modName)() may not adapt to Dark Mode. Use semantic colors from asset catalog.",
                        node: mod.callExpr,
                        context: context
                    ))
                }

                // Flag Color(red:green:blue:) inline definitions
                if argText.contains("Color(red:") || argText.contains("Color(uiColor:") {
                    diagnostics.append(makeDiagnostic(
                        message: "Inline color definition in .\(modName)() — consider using a named color from asset catalog with Dark Mode variants to ensure contrast in both modes.",
                        node: mod.callExpr,
                        context: context
                    ))
                }
            }
        }
        return diagnostics
    }
}
