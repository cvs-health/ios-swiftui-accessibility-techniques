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
    private func selfContainedPairPositions(
        syntax: SourceFileSyntax,
        colorConstants: [String: String]
    ) -> Set<AbsolutePosition> {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var positions: Set<AbsolutePosition> = []
        for view in visitor.detectedViews {
            let mods = ModifierCollector.collectChainOnly(from: view.chainRoot, callExpr: view.callExpr)
            let fgMods = Self.foregroundModifiers.flatMap { mods.modifiers(named: $0) }
            let bgMods = ["background", "backgroundStyle"].flatMap { mods.modifiers(named: $0) }
            guard !fgMods.isEmpty, !bgMods.isEmpty else { continue }
            // Both sides must actually be fixed colours for the pair to be self-contained.
            // Resolve constants first, or `.background(darkRed)` reads as an unknown
            // identifier and the pair is missed.
            let pinned = (fgMods + bgMods).filter {
                Self.pinsColor($0.arguments.first?.text ?? "", constants: colorConstants)
            }
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

    /// Colours that track the system appearance rather than naming one.
    ///
    /// These must never count towards a self-contained pair. `.foregroundColor(.black)` over
    /// `Color(.systemBackground)` is precisely the Dark Mode bug this rule exists to catch:
    /// the surface flips to black and the text disappears.
    private static let appearanceFollowingColors: Set<String> = [
        ".primary", ".secondary", "Color.primary", "Color.secondary",
        "Color(.label)", "Color(.secondaryLabel)", "Color(.tertiaryLabel)",
        "Color(.quaternaryLabel)", "Color(.placeholderText)", "Color(.separator)",
        "Color(.opaqueSeparator)", "Color(.systemBackground)",
        "Color(.secondarySystemBackground)", "Color(.tertiarySystemBackground)",
        "Color(.systemGroupedBackground)", "Color(.secondarySystemGroupedBackground)",
        "Color(.tertiarySystemGroupedBackground)", "Color(.systemFill)",
        ".background", ".foreground",
    ]

    /// Whether an expression pins a specific colour, as opposed to following the appearance.
    ///
    /// Used only to decide whether a foreground/background pair is self-contained. A named
    /// accent such as `Color.blue` or `Color(.systemRed)` counts: it may shift slightly
    /// between appearances, but it is a deliberate choice and the pair moves with it. A
    /// ternary counts when every branch counts, which is how `colorScheme`-switched colours
    /// are written.
    private static func pinsColor(_ text: String, constants: [String: String]) -> Bool {
        let resolved = ColorConstantCollector
            .resolve(text, constants: constants)
            .trimmingCharacters(in: .whitespaces)
        if resolved.isEmpty { return false }
        if appearanceFollowingColors.contains(resolved) { return false }

        if let branches = ternaryBranches(resolved) {
            return branches.allSatisfy { pinsColor($0, constants: constants) }
        }
        if isFixedColor(resolved) { return true }
        if ColorParser.systemColors[resolved] != nil { return true }
        if resolved == "Color.accentColor" || resolved == ".accentColor" { return true }
        // UIColor-backed system accents, e.g. Color(.systemRed). Surface and label
        // semantics were already excluded above.
        if resolved.hasPrefix("Color(.") { return true }
        // Asset catalog colour: variants are defined deliberately in the catalog.
        if resolved.hasPrefix("Color(\"") { return true }
        return false
    }

    /// The two branches of a ternary, or nil when the text is not one.
    ///
    /// Scans for the `:` at paren depth zero so labelled arguments inside
    /// `Color(red:green:blue:)` are not mistaken for the ternary's separator.
    private static func ternaryBranches(_ text: String) -> [String]? {
        guard let q = text.firstIndex(of: "?") else { return nil }
        let after = text[text.index(after: q)...]
        var depth = 0
        var separator: String.Index?
        for i in after.indices {
            switch after[i] {
            case "(", "[": depth += 1
            case ")", "]": depth -= 1
            case ":" where depth == 0: separator = i
            default: break
            }
            if separator != nil { break }
        }
        guard let colon = separator else { return nil }
        let first = after[after.startIndex..<colon].trimmingCharacters(in: .whitespaces)
        let second = after[after.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        guard !first.isEmpty, !second.isEmpty else { return nil }
        return [first, second]
    }

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        let colorConstants = ColorConstantCollector.collect(from: syntax)
        let pairedPositions = selfContainedPairPositions(syntax: syntax, colorConstants: colorConstants)
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
