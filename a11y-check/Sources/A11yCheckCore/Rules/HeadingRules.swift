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

// MARK: - Heading Trait Missing Rule

/// Flags `Text` with heading font styles that are missing `.accessibilityAddTraits(.isHeader)`.
///
/// Recognises Apple's built-in styles (.title, .title2, .title3, .largeTitle, .headline) and,
/// by name, design-system heading tokens such as `.themeHeadingXL` or `.appTitleLarge` — most
/// apps style headings through their own type scale rather than the system styles, and a rule
/// that only knew the built-ins would see nothing in those codebases. Extend or narrow the set
/// with `heading_fonts` / `heading_font_deny` in `.a11ycheck.yml`.
///
/// A font injected as a variable is resolved to the token it holds, so the decision rests on
/// the declared value rather than the variable's name.
///
/// Skips Text that is the label of a Button, Link, or Toggle — headline-style labels
/// on controls are not structural headings and should not get the header trait.
/// Skips long or multi-line text (paragraphs) — only suggests the trait for short,
/// single-line text that is likely a structural heading.
///
/// WCAG 2.4.6 Headings and Labels
/// Reference: HeadingsView.swift
public struct HeadingTraitMissingRule: A11yRule {
    public let id = "heading-trait-missing"
    public let name = "Heading Trait Missing"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.4.6"]
    public let description = "Text styled with heading fonts should use .accessibilityAddTraits(.isHeader) so VoiceOver users can navigate by headings. Covers built-in styles and design-system heading tokens such as .themeHeadingXL."

    public init() {}

    /// Max character count for suggesting heading trait. Longer text is treated as paragraph.
    private static let maxHeadingLength = 120

    /// Apple's built-in font styles that indicate a heading.
    private static let builtInHeadingFonts: Set<String> = [
        "title", "title2", "title3", "largeTitle", "headline",
    ]

    /// Name fragments that mark a design-system token as a heading tier.
    ///
    /// `sub` tiers are deliberately included: a subheading is a heading, and WCAG 1.3.1 asks
    /// for anything that appears to be a heading to be marked up as one, with no exemption for
    /// subordinate ones. So `.subheadline`, `.subtitle` and `.themeSubheadingM` all count.
    ///
    /// Supporting text held in a variable — `subtitleFont`, `valueFont` — is not excluded by
    /// name but by resolving the variable to the token it actually holds. See `isHeadingFont`.
    private static let headingNameFragments = ["heading", "header", "title", "headline", "display"]

    /// View types where the Text is used as a label/title of the control, not a structural heading.
    private static let labelConsumerViews: Set<String> = ["Button", "Link", "Toggle"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        let fontConstants = FontConstantCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Text") {
            // Skip if this Text is inside a Button/Link/Toggle (it's a control label, not a heading)
            if isTextInsideLabelConsumer(view.callExpr) { continue }

            // Skip long or multi-line text (paragraphs) — only flag short, single-line text as potential headings
            if !isShortSingleLineText(view.firstStringArgument) { continue }

            let mods = view.modifiers

            // Check if it has a heading-style font
            let fontMods = mods.modifiers(named: "font")
            let hasHeadingFont = fontMods.contains { mod in
                isHeadingFont(
                    mod.arguments.first?.text ?? "",
                    options: context.configOptions,
                    fontConstants: fontConstants
                )
            }
            guard hasHeadingFont else { continue }

            // Check if it already has .isHeader trait
            let hasHeaderTrait = mods.modifiers(named: "accessibilityAddTraits").contains { mod in
                mod.arguments.contains { $0.text.contains("isHeader") }
            }
            // Also check older API
            let hasOldHeaderTrait = mods.modifiers(named: "accessibility").contains { mod in
                mod.arguments.contains { $0.label == "addTraits" && $0.text.contains("isHeader") }
            }

            if !hasHeaderTrait && !hasOldHeaderTrait {
                let fix = makeModifierFix(
                    chainRoot: view.chainRoot,
                    modifier: ".accessibilityAddTraits(.isHeader)",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "Text with heading font style is missing .accessibilityAddTraits(.isHeader). VoiceOver users won't be able to navigate to this heading.",
                    node: view.callExpr,
                    context: context,
                    fix: fix,
                    suggestion: "Add .accessibilityAddTraits(.isHeader)"
                ))
            }
        }
        return diagnostics
    }

    /// Whether a `.font()` argument names a heading style.
    ///
    /// Matching is on the leading token only, so a weight chain or a sized constructor does not
    /// change the answer: `.themeHeadingL.weight(.bold)` is still `themeHeadingL`, and
    /// `.custom("AetnaSans", size: 17)` is `custom` and never a heading.
    ///
    /// A font passed in by variable is resolved to the token it holds first, so the decision
    /// rests on the declared value rather than the variable's name. The name is unreliable in
    /// both directions: `subtitleFont` holds `.themeParagraphXS` in one real component, while
    /// `titleFont` holds a heading token in some components and a paragraph token in others.
    private func isHeadingFont(
        _ argumentText: String,
        options: A11yConfig.ConfigOptions,
        fontConstants: [String: String]
    ) -> Bool {
        let resolved = FontConstantCollector.resolve(argumentText, constants: fontConstants)
        let tokens = Self.fontTokens(in: resolved)
        guard !tokens.isEmpty else { return false }

        for token in tokens {
            let lowered = token.lowercased()
            // Explicit project overrides win, deny before allow.
            if options.headingFontDeny.contains(where: { $0.lowercased() == lowered }) { continue }
            if options.headingFonts.contains(where: { $0.lowercased() == lowered }) { return true }

            if Self.builtInHeadingFonts.contains(token) { return true }
            if Self.headingNameFragments.contains(where: { lowered.contains($0) }) { return true }
        }
        return false
    }

    /// Every font token in a `.font()` argument.
    ///
    /// Scans for member-access names rather than taking the leading identifier, so that an
    /// expression choosing between fonts is judged on the fonts and not on whatever decides
    /// between them. `isHeader ? .themeParagraphMStrong : .themeParagraphM` yields the two
    /// paragraph tokens and *not* `isHeader` — reading the condition as the font is how a
    /// paragraph row ends up reported as an unmarked heading.
    ///
    /// A chain contributes each of its names (`.themeHeadingL.weight(.bold)` gives
    /// `themeHeadingL`, `weight`, `bold`), which costs nothing: the caller asks whether *any*
    /// token is a heading, and modifier names are not heading names. For the same reason a
    /// token appearing in either branch of a conditional is enough — a font that is a heading
    /// half the time still needs the trait.
    ///
    /// Falls back to a bare leading identifier when there is no member access at all, so an
    /// unresolved `.font(titleFont)` is still judged, by name, rather than skipped.
    static func fontTokens(in argumentText: String) -> [String] {
        let text = argumentText.trimmingCharacters(in: .whitespacesAndNewlines)
        var tokens: [String] = []
        var index = text.startIndex

        while let dot = text[index...].firstIndex(of: ".") {
            let afterDot = text.index(after: dot)
            guard afterDot < text.endIndex else { break }
            let name = text[afterDot...].prefix { $0.isLetter || $0.isNumber || $0 == "_" }
            if !name.isEmpty {
                tokens.append(String(name))
                index = text.index(afterDot, offsetBy: name.count)
            } else {
                index = afterDot
            }
        }

        if tokens.isEmpty {
            let bare = text.prefix { $0.isLetter || $0.isNumber || $0 == "_" }
            if !bare.isEmpty { tokens.append(String(bare)) }
        }
        return tokens
    }

    /// True if the text is suitable to treat as a potential heading: single line and under max length.
    /// Nil (e.g. Text(localized:) or variable) is treated as short so we don't miss real headings.
    private func isShortSingleLineText(_ content: String?) -> Bool {
        guard let content = content else { return true }
        if content.contains("\n") { return false }
        return content.count <= Self.maxHeadingLength
    }

    /// Returns true if the given Text node is inside a Button, Link, or Toggle (used as that control's label).
    private func isTextInsideLabelConsumer(_ textNode: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(textNode).parent
        while let node = current {
            if let call = node.as(FunctionCallExprSyntax.self) {
                let name: String? = {
                    if let ref = call.calledExpression.as(DeclReferenceExprSyntax.self) {
                        return ref.baseName.text
                    }
                    if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
                       let base = member.base?.as(DeclReferenceExprSyntax.self),
                       member.declName.baseName.text == "init" {
                        return base.baseName.text
                    }
                    return nil
                }()
                if let name = name, Self.labelConsumerViews.contains(name) {
                    return true
                }
            }
            current = node.parent
        }
        return false
    }
}

// MARK: - Fake Heading In Label Rule

/// Flags `.accessibilityLabel()` values that contain the word "heading" —
/// this fakes a heading announcement instead of using the proper trait.
///
/// WCAG 1.3.1 Info and Relationships
/// Reference: HeadingsView.swift (bad example with "Store Hours heading" label)
public struct FakeHeadingInLabelRule: A11yRule {
    public let id = "fake-heading-in-label"
    public let name = "Fake Heading in Accessibility Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.3.1"]
    public let description = "Don't include 'heading' in .accessibilityLabel(). Use .accessibilityAddTraits(.isHeader) instead."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for mod in collector.modifiers(named: "accessibilityLabel") {
            guard let text = mod.firstStringArgument else { continue }
            if text.lowercased().contains("heading") {
                let fix = makeStringReplacementFix(
                    callExpr: mod.callExpr,
                    originalText: text,
                    word: "heading",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "Accessibility label \"\(text)\" contains 'heading'. Use .accessibilityAddTraits(.isHeader) instead of faking a heading in the label text.",
                    node: mod.reportNode,
                    context: context,
                    fix: fix,
                    suggestion: "Remove \"heading\" from label and add .accessibilityAddTraits(.isHeader)"
                ))
            }
        }
        return diagnostics
    }
}
