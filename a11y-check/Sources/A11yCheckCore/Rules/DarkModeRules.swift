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
    public let severity = A11ySeverity.info
    public let impact = A11yImpact.minor
    public let wcagCriteria = ["1.4.3"]
    public let description = "Hardcoded colors may not meet contrast requirements in both light and dark mode. Use semantic colors from an asset catalog with dark mode variants."

    public init() {}

    /// Hardcoded color references that are suspicious.
    private static let hardcodedColors: Set<String> = [
        ".black", ".white", "Color.black", "Color.white",
    ]

    /// Color modifiers to check.
    private static let colorModifiers = ["foregroundColor", "foregroundStyle", "background", "tint"]

    /// Modifiers that set text colour. A fixed colour here is a near-certain Dark Mode
    /// bug, so these are reported a level above the decorative cases.
    private static let foregroundModifiers: Set<String> = ["foregroundColor", "foregroundStyle"]

    /// Inline colour construction in any of its forms. `Color(red:` and `Color(uiColor:`
    /// were the only two recognised previously, so `Color(white:)`, HSB, hex, and
    /// `#colorLiteral` all passed unnoticed.
    private static let inlineColorPrefixes = [
        "Color(red:", "Color(white:", "Color(hue:", "Color(hex", "Color(uiColor:",
        "Color(.sRGB", "Color(.displayP3", "Color(cgColor:", "UIColor(", "#colorLiteral",
    ]

    /// Positions of colour modifiers that sit in a chain which pins both the foreground and
    /// the background.
    ///
    /// A self-contained pair renders identically in both appearances — white on black is
    /// white on black whatever the system theme — so "may not adapt to Dark Mode" is the
    /// wrong complaint. Whether the pair is legible is `color-contrast-insufficient`'s
    /// business, and it checks exactly this case.
    private func selfContainedPairPositions(syntax: SourceFileSyntax) -> Set<AbsolutePosition> {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var positions: Set<AbsolutePosition> = []
        for view in visitor.detectedViews {
            let mods = ModifierCollector.collectChainOnly(from: view.chainRoot, callExpr: view.callExpr)
            let fgMods = Self.foregroundModifiers.flatMap { mods.modifiers(named: $0) }
            let bgMods = ["background", "backgroundStyle"].flatMap { mods.modifiers(named: $0) }
            guard !fgMods.isEmpty, !bgMods.isEmpty else { continue }
            // Both sides must actually be fixed colours for the pair to be self-contained.
            let pinned = (fgMods + bgMods).filter { Self.isFixedColor($0.arguments.first?.text ?? "") }
            guard pinned.count == fgMods.count + bgMods.count else { continue }
            for mod in fgMods + bgMods {
                positions.insert(mod.reportNode.positionAfterSkippingLeadingTrivia)
            }
        }
        return positions
    }

    /// Whether an expression names a colour that does not vary with appearance.
    private static func isFixedColor(_ text: String) -> Bool {
        if hardcodedColors.contains(text) { return true }
        return inlineColorPrefixes.contains { text.contains($0) }
    }

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        let colorConstants = ColorConstantCollector.collect(from: syntax)
        let pairedPositions = selfContainedPairPositions(syntax: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for modName in Self.colorModifiers {
            for mod in collector.modifiers(named: modName) {
                let rawArg = mod.arguments.first?.text ?? ""
                // Follow a file-local constant to the colour it holds, so
                // `.foregroundColor(darkGreen)` is judged on its declaration.
                let argText = ColorConstantCollector.resolve(rawArg, constants: colorConstants)
                let viaConstant = argText != rawArg
                let constantNote = viaConstant ? " (via \(rawArg))" : ""
                let isForeground = Self.foregroundModifiers.contains(modName)

                // Skip chains that pin both foreground and background — the pair is
                // appearance-independent, so Dark Mode adaptation does not apply.
                if pairedPositions.contains(mod.reportNode.positionAfterSkippingLeadingTrivia) {
                    continue
                }

                // Flag hardcoded .black / .white
                if Self.hardcodedColors.contains(argText) {
                    var fix: A11yFix? = nil
                    // Only offer the removal fix when the colour is written inline. Deleting
                    // the modifier would not be equivalent when it reads from a constant.
                    if !viaConstant,
                       let memberAccess = mod.callExpr.calledExpression.as(MemberAccessExprSyntax.self) {
                        let offset = syntax.position.utf8Offset
                        let startOffset = memberAccess.period.position.utf8Offset - offset
                        let endOffset = mod.callExpr.endPositionBeforeTrailingTrivia.utf8Offset - offset
                        fix = A11yFix(
                            description: "Remove .\(modName)(\(argText))",
                            replacementText: "",
                            startOffset: startOffset,
                            endOffset: endOffset
                        )
                    }
                    diagnostics.append(makeDiagnostic(
                        message: "Hardcoded color \(argText)\(constantNote) in .\(modName)() may not adapt to Dark Mode. Remove the modifier to use SwiftUI's adaptive default, or use a named Color from your asset catalog.",
                        node: mod.reportNode,
                        context: context,
                        // A fixed text colour inverts against the background in the other
                        // appearance, so it is a defect rather than a suggestion.
                        severityOverride: isForeground ? .warning : nil,
                        fix: fix,
                        suggestion: "Remove .\(modName)(\(rawArg)) to use adaptive default colors"
                    ))
                }

                // Flag inline colour construction in any recognised form
                if Self.inlineColorPrefixes.contains(where: { argText.contains($0) }) {
                    diagnostics.append(makeDiagnostic(
                        message: "Inline color definition\(constantNote) in .\(modName)() — consider using a named color from asset catalog with Dark Mode variants to ensure contrast in both modes.",
                        node: mod.reportNode,
                        context: context,
                        suggestion: "Use a named Color from asset catalog with Dark Mode variants"
                    ))
                }
            }
        }
        return diagnostics
    }
}
