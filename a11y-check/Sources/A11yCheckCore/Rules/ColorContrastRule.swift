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

// MARK: - Color Contrast Rule

/// Flags foreground/background color pairs that fail WCAG 1.4.3 contrast minimums.
/// Checks when both colors can be statically resolved (system colors, RGB literals,
/// hex values, or asset catalog colors).
///
/// WCAG 1.4.3 Contrast (Minimum)
///   - 4.5:1 for normal text
///   - 3.0:1 for large text (18pt+ or 14pt+ bold)
///
/// Appearance themes checked: Light Mode, Dark Mode, Increase Contrast, Dark + Increase Contrast.
/// A diagnostic is emitted for each theme that fails (naming the theme when it isn't Light Mode).
public struct ColorContrastRule: A11yRule {
    public let id = "color-contrast-insufficient"
    public let name = "Insufficient Color Contrast"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.4.3"]
    public let description = "Foreground and background color pair does not meet the WCAG 1.4.3 minimum contrast ratio."

    public init() {}

    private static let foregroundModifiers: Set<String> = ["foregroundColor", "foregroundStyle", "tint"]
    private static let backgroundModifiers: Set<String> = ["background"]

    private static let largeFontStyles: Set<String> = [
        ".largeTitle", ".title", ".title2", ".title3",
        "Font.largeTitle", "Font.title", "Font.title2", "Font.title3",
    ]

    private static let boldWeights: Set<String> = [
        ".bold", ".semibold", ".heavy", ".black",
        "Font.Weight.bold", "Font.Weight.semibold", "Font.Weight.heavy", "Font.Weight.black",
        "bold", "semibold", "heavy", "black",
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

    /// Container view types eligible for ancestor-background pairing (Gap 2).
    private static let containerViews: Set<String> = [
        "VStack", "HStack", "ZStack", "LazyVStack", "LazyHStack",
        "ScrollView", "List", "Form", "Section", "Group", "GroupBox",
        "NavigationStack", "NavigationView", "NavigationSplitView",
        "GeometryReader",
    ]

    // MARK: - Appearance themes to check

    private struct AppearanceTheme {
        let label: String
        let darkMode: Bool
        let contrastMode: Bool
    }

    private static let themes: [AppearanceTheme] = [
        AppearanceTheme(label: "Light Mode", darkMode: false, contrastMode: false),
        AppearanceTheme(label: "Dark Mode", darkMode: true, contrastMode: false),
        AppearanceTheme(label: "Increase Contrast", darkMode: false, contrastMode: true),
        AppearanceTheme(label: "Dark Mode + Increase Contrast", darkMode: true, contrastMode: true),
    ]

    /// Shown in diagnostics when no background is declared anywhere up the tree.
    private static let systemBackgroundExpression = "assumed system background"

    /// Modifiers that paint a background this rule cannot evaluate.
    ///
    /// `Button("Save") {}.buttonStyle(.borderedProminent)` has a filled background and no
    /// `.background` modifier anywhere, so assuming the system background produced a bogus
    /// "1.0:1 white on white". When one of these is in scope the background is *unknown*,
    /// which means skipping — a miss is the safe direction for a linter, a false error is not.
    private static let stylingBackgroundModifiers: Set<String> = [
        "buttonStyle", "listRowBackground", "toolbarBackground",
    ]

    /// Button styles that paint nothing, so they do not hide a background.
    private static let transparentButtonStyles: Set<String> = [
        ".plain", ".borderless", "PlainButtonStyle()", "BorderlessButtonStyle()",
    ]

    /// What SwiftUI renders behind unadorned content: white in light mode, black in dark.
    private static let systemBackground = AssetCatalogParser.ThemedColor(
        light: ContrastCalculator.RGBA(r: 1, g: 1, b: 1),
        dark: ContrastCalculator.RGBA(r: 0, g: 0, b: 0)
    )

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []
        let colorConstants = ColorConstantCollector.collect(from: syntax)
        let assumeDefaultBackground = context.configOptions.assumeDefaultBackground ?? false

        // Lookup from callExpr position → DetectedView for every view, so the ancestor walk
        // can reach a background on any enclosing view. Restricting this to VStack-style
        // containers meant `Button { Text(…).foregroundColor(.white) }.background(.blue)`
        // never found its background and fell through to the assumed one. Siblings are still
        // unreachable because the walk only follows parent nodes.
        var containerByPosition: [AbsolutePosition: ViewHierarchyVisitor.DetectedView] = [:]
        for v in visitor.detectedViews {
            containerByPosition[v.callExpr.positionAfterSkippingLeadingTrivia] = v
        }

        let threshold = context.configOptions.contrastRatio ?? ContrastCalculator.aaNormalText

        for view in visitor.detectedViews {
            guard Self.textBearingViews.contains(view.viewType) else { continue }

            // Use chain-only collection so child-closure modifiers (e.g. Image inside Button)
            // are never mistakenly paired with this view's own background.
            let mods = ModifierCollector.collectChainOnly(from: view.chainRoot, callExpr: view.callExpr)

            let fgMod = Self.foregroundModifiers.compactMap { mods.modifiers(named: $0).first }.first
            guard let fg = fgMod else { continue }

            // Try same-chain background first; fall back to nearest ancestor container (Gap 2)
            let bgMod = Self.backgroundModifiers.compactMap { mods.modifiers(named: $0).first }.first
            let (bg, bgIsAncestor): (ModifierCollector.CollectedModifier?, Bool)
            if let sameBg = bgMod {
                (bg, bgIsAncestor) = (sameBg, false)
            } else if let ancestorBg = findAncestorBackground(
                for: view.callExpr,
                containerByPosition: containerByPosition
            ) {
                (bg, bgIsAncestor) = (ancestorBg, true)
            } else if assumeDefaultBackground,
                      !hasStyleProvidedBackground(
                          for: view.callExpr,
                          ownMods: mods,
                          containerByPosition: containerByPosition
                      ) {
                // No background anywhere up the tree. Assume the system background,
                // which is what SwiftUI actually renders behind unadorned content.
                (bg, bgIsAncestor) = (nil, false)
            } else {
                continue
            }

            let fgText = fg.arguments.first?.text ?? ""
            let bgText = bg?.arguments.first?.text ?? Self.systemBackgroundExpression

            // See through file-local constants: `.foregroundColor(darkGreen)` carries no
            // colour on its own, but the declaration of `darkGreen` does.
            let fgResolved = ColorConstantCollector.resolve(fgText, constants: colorConstants)
            let bgResolved = ColorConstantCollector.resolve(bgText, constants: colorConstants)

            guard let fgThemed = ColorParser.parseThemed(fgResolved, assetColors: context.assetColors) else {
                continue
            }
            let bgThemed: AssetCatalogParser.ThemedColor
            if bg == nil {
                bgThemed = Self.systemBackground
            } else if let parsed = ColorParser.parseThemed(bgResolved, assetColors: context.assetColors) {
                bgThemed = parsed
            } else {
                continue
            }

            // Determine if large text (Gap 3: numeric size detection)
            let isLargeText = detectLargeText(mods: mods)
            let requiredRatio = isLargeText ? ContrastCalculator.aaLargeText : threshold
            let textSize = isLargeText ? "large" : "normal"

            // Check each appearance theme (Gap 1)
            for theme in Self.themes {
                // Only check dark/highContrast variants when at least one side has them
                if theme.darkMode && !fgThemed.hasDarkVariant && !bgThemed.hasDarkVariant { continue }
                if theme.contrastMode && !fgThemed.hasHighContrastVariant && !bgThemed.hasHighContrastVariant { continue }

                let fgColor = fgThemed.resolve(darkMode: theme.darkMode, contrastMode: theme.contrastMode)
                let bgColor = bgThemed.resolve(darkMode: theme.darkMode, contrastMode: theme.contrastMode)

                let ratio = ContrastCalculator.contrastRatio(fgColor, bgColor)
                if ratio < requiredRatio {
                    let themeSuffix = theme.label == "Light Mode" ? "" : " in \(theme.label)"
                    let ancestorNote: String
                    if bg == nil {
                        ancestorNote = " No background is declared, so the system background was assumed"
                            + " — set assume_default_background: false in .a11ycheck.yml to skip these."
                    } else if bgIsAncestor {
                        ancestorNote = " (background inherited from enclosing container)"
                    } else {
                        ancestorNote = ""
                    }
                    diagnostics.append(makeDiagnostic(
                        message: "Contrast ratio \(ContrastCalculator.formatRatio(ratio)) between foreground (\(fgText)) and background (\(bgText)) is below the \(ContrastCalculator.formatRatio(requiredRatio)) minimum for \(textSize) text\(themeSuffix) (WCAG 1.4.3).\(ancestorNote)",
                        node: fg.reportNode,
                        context: context,
                        suggestion: "Choose colors with a contrast ratio of at least \(ContrastCalculator.formatRatio(requiredRatio))"
                    ))
                }
            }
        }

        return diagnostics
    }

    /// Whether the view, or anything enclosing it, carries a modifier that paints a
    /// background this rule cannot read. If so the background is unknown rather than
    /// absent, and assuming the system background would invent a failure.
    private func hasStyleProvidedBackground(
        for callExpr: FunctionCallExprSyntax,
        ownMods: ModifierCollector,
        containerByPosition: [AbsolutePosition: ViewHierarchyVisitor.DetectedView]
    ) -> Bool {
        if Self.carriesStylingBackground(ownMods) { return true }
        var node: Syntax? = Syntax(callExpr).parent
        while let current = node {
            if let funcCall = current.as(FunctionCallExprSyntax.self),
               let view = containerByPosition[funcCall.positionAfterSkippingLeadingTrivia] {
                let chainMods = ModifierCollector.collectChainOnly(
                    from: view.chainRoot,
                    callExpr: view.callExpr
                )
                if Self.carriesStylingBackground(chainMods) { return true }
            }
            node = current.parent
        }
        return false
    }

    private static func carriesStylingBackground(_ mods: ModifierCollector) -> Bool {
        for name in stylingBackgroundModifiers {
            for mod in mods.modifiers(named: name) {
                if name == "buttonStyle",
                   transparentButtonStyles.contains(mod.arguments.first?.text ?? "") {
                    continue
                }
                return true
            }
        }
        return false
    }

    // MARK: - Gap 2: Ancestor container background search

    /// Walk up the syntax tree from a text view's call expression to find the nearest
    /// enclosing container view whose DIRECT modifier chain carries a `.background`.
    /// Only containers (VStack, HStack, etc.) are considered — siblings are never reached
    /// because we only walk upward through parent nodes.
    /// Chain-only collection is used so a sibling view's `.background` inside the same
    /// closure body is never mistaken for the container's own background.
    private func findAncestorBackground(
        for textCallExpr: FunctionCallExprSyntax,
        containerByPosition: [AbsolutePosition: ViewHierarchyVisitor.DetectedView]
    ) -> ModifierCollector.CollectedModifier? {
        var node: Syntax? = Syntax(textCallExpr).parent
        while let current = node {
            if let funcCall = current.as(FunctionCallExprSyntax.self) {
                let pos = funcCall.positionAfterSkippingLeadingTrivia
                if let container = containerByPosition[pos] {
                    // Use chain-only collection so modifiers inside the container's
                    // closure body (belonging to sibling views) are excluded.
                    let chainMods = ModifierCollector.collectChainOnly(
                        from: container.chainRoot,
                        callExpr: container.callExpr
                    )
                    let bgMod = Self.backgroundModifiers
                        .compactMap { chainMods.modifiers(named: $0).first }
                        .first
                    if let bg = bgMod {
                        return bg
                    }
                }
            }
            node = current.parent
        }
        return nil
    }

    // MARK: - Gap 3: Large-text detection

    /// Returns true when the view's modifier chain indicates large text per WCAG 1.4.3
    /// (named large font styles, or `.system(size:)` ≥ 18pt, or ≥ 14pt with bold weight).
    private func detectLargeText(mods: ModifierCollector) -> Bool {
        for mod in mods.modifiers(named: "font") {
            let fontArg = mod.arguments.first?.text ?? ""

            // Named large font styles
            if Self.largeFontStyles.contains(fontArg) { return true }

            // Numeric .system(size:) — extract size and optional weight
            if isLargeNumericFont(fontArg) { return true }
        }

        // .bold() modifier combined with a numeric system font
        if hasBoldModifier(mods: mods) {
            for mod in mods.modifiers(named: "font") {
                let fontArg = mod.arguments.first?.text ?? ""
                if let size = extractSystemFontSize(fontArg), size >= 14 { return true }
            }
        }

        return false
    }

    /// Parse `.system(size: N)` or `.system(size: N, weight: .bold)` and return true if large.
    private func isLargeNumericFont(_ fontArg: String) -> Bool {
        guard fontArg.contains("system") && fontArg.contains("size:") else { return false }
        guard let size = extractSystemFontSize(fontArg) else { return false }
        if size >= 18 { return true }
        if size >= 14 && containsBoldWeight(fontArg) { return true }
        return false
    }

    private func extractSystemFontSize(_ fontArg: String) -> Double? {
        guard let sizeRange = fontArg.range(of: "size:") else { return nil }
        let afterSize = String(fontArg[sizeRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        // Take up to the first comma or closing paren
        let sizeToken = afterSize
            .split(omittingEmptySubsequences: true) { $0 == "," || $0 == ")" }
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespaces) ?? afterSize
        return Double(sizeToken)
    }

    private func containsBoldWeight(_ text: String) -> Bool {
        Self.boldWeights.contains { text.contains($0) }
    }

    private func hasBoldModifier(mods: ModifierCollector) -> Bool {
        mods.modifiers(named: "bold").isEmpty == false ||
        mods.modifiers(named: "fontWeight").contains { mod in
            let arg = mod.arguments.first?.text ?? ""
            return containsBoldWeight(arg)
        }
    }

}

