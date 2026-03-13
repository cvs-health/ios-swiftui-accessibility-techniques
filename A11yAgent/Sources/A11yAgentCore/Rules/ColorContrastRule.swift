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

    /// Views that directly render text. Container/layout views are excluded
    /// because their ModifierCollector walks closure bodies and would pair
    /// foreground/background colors from different child views (false positive).
    private static let textBearingViews: Set<String> = [
        "Text", "Label", "Button", "Link", "NavigationLink",
        "TextField", "SecureField", "TextEditor",
        "Toggle", "Slider", "Stepper", "Picker", "DatePicker", "ColorPicker",
        "Menu", "DisclosureGroup", "ProgressView", "Gauge",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        let threshold = context.configOptions.contrastRatio ?? ContrastCalculator.aaNormalText

        for view in visitor.detectedViews {
            guard Self.textBearingViews.contains(view.viewType) else { continue }

            let mods = view.modifiers

            // Find foreground color — only from the view's direct modifier chain
            let fgMod = Self.foregroundModifiers.compactMap { mods.modifiers(named: $0).first }.first
            // Find background color — only from the view's direct modifier chain
            let bgMod = Self.backgroundModifiers.compactMap { mods.modifiers(named: $0).first }.first

            guard let fg = fgMod, let bg = bgMod else { continue }

            // Both modifiers must be on the same direct chain (not from different
            // child views inside a closure). Verify neither sits inside a closure
            // that is a descendant of the view call — that would mean it belongs
            // to a child view, not this view's own chain.
            if isInsideClosure(fg.callExpr, relativeTo: view.callExpr) { continue }
            if isInsideClosure(bg.callExpr, relativeTo: view.callExpr) { continue }

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
                    node: fg.reportNode,
                    context: context,
                    suggestion: "Choose colors with a contrast ratio of at least \(ContrastCalculator.formatRatio(requiredRatio))"
                ))
            }
        }

        return diagnostics
    }

    /// Returns true when `modifier` lives inside a closure body that is a
    /// descendant of `viewCall`. This catches modifiers on child views inside
    /// a container's trailing closure which should not be attributed to the
    /// container itself.
    private func isInsideClosure(
        _ modifier: FunctionCallExprSyntax,
        relativeTo viewCall: FunctionCallExprSyntax
    ) -> Bool {
        var node: Syntax? = Syntax(modifier)
        while let current = node {
            if current.id == Syntax(viewCall).id { return false }
            if current.is(ClosureExprSyntax.self) { return true }
            node = current.parent
        }
        return false
    }
}
