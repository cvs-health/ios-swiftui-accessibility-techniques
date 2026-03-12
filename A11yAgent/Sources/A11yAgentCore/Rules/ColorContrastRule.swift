import SwiftSyntax

// MARK: - Color Contrast Rule

/// Flags foreground/background color pairs that fail WCAG 1.4.3 contrast minimums.
/// Checks when both colors can be statically resolved (system colors, RGB literals,
/// hex values, or asset catalog colors).
///
/// WCAG 1.4.3 Contrast (Minimum)
///   - 4.5:1 for normal text
///   - 3.0:1 for large text (18pt+ or 14pt+ bold)
public struct ColorContrastRule: A11yRule {
    public let id = "color-contrast-insufficient"
    public let name = "Insufficient Color Contrast"
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["1.4.3"]
    public let description = "Foreground and background color pair does not meet the WCAG 1.4.3 minimum contrast ratio."

    public init() {}

    private static let foregroundModifiers: Set<String> = ["foregroundColor", "foregroundStyle", "tint"]
    private static let backgroundModifiers: Set<String> = ["background"]
    private static let largeFontStyles: Set<String> = [
        ".largeTitle", ".title", ".title2", ".title3",
        "Font.largeTitle", "Font.title", "Font.title2", "Font.title3",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        let threshold = context.configOptions.contrastRatio ?? ContrastCalculator.aaNormalText

        for view in visitor.detectedViews {
            let mods = view.modifiers

            // Find foreground color
            let fgMod = Self.foregroundModifiers.compactMap { mods.modifiers(named: $0).first }.first
            // Find background color
            let bgMod = Self.backgroundModifiers.compactMap { mods.modifiers(named: $0).first }.first

            guard let fg = fgMod, let bg = bgMod else { continue }

            let fgText = fg.arguments.first?.text ?? ""
            let bgText = bg.arguments.first?.text ?? ""

            guard let fgColor = ColorParser.parse(fgText, assetColors: context.assetColors),
                  let bgColor = ColorParser.parse(bgText, assetColors: context.assetColors) else {
                continue
            }

            let ratio = ContrastCalculator.contrastRatio(fgColor, bgColor)

            // Determine if large text
            let isLargeText = mods.modifiers(named: "font").contains { mod in
                let fontArg = mod.arguments.first?.text ?? ""
                return Self.largeFontStyles.contains(fontArg)
            }
            let requiredRatio = isLargeText ? ContrastCalculator.aaLargeText : threshold

            if ratio < requiredRatio {
                let textSize = isLargeText ? "large" : "normal"
                diagnostics.append(makeDiagnostic(
                    message: "Contrast ratio \(ContrastCalculator.formatRatio(ratio)) between foreground (\(fgText)) and background (\(bgText)) is below the \(ContrastCalculator.formatRatio(requiredRatio)) minimum for \(textSize) text (WCAG 1.4.3).",
                    node: fg.callExpr,
                    context: context
                ))
            }
        }

        return diagnostics
    }
}
