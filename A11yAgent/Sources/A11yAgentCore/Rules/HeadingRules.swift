import SwiftSyntax

// MARK: - Heading Trait Missing Rule

/// Flags `Text` with large font styles (.title, .title2, .title3, .largeTitle, .headline)
/// that are missing `.accessibilityAddTraits(.isHeader)`.
/// Skips Text that is the label of a Button, Link, or Toggle — headline-style labels
/// on controls are not structural headings and should not get the header trait.
/// Skips long or multi-line text (paragraphs) — only suggests the trait for short,
/// single-line text that is likely a structural heading.
///
/// WCAG 1.3.1 Info and Relationships
/// Reference: HeadingsView.swift
public struct HeadingTraitMissingRule: A11yRule {
    public let id = "heading-trait-missing"
    public let name = "Heading Trait Missing"
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["1.3.1"]
    public let description = "Text styled with heading fonts should use .accessibilityAddTraits(.isHeader) so VoiceOver users can navigate by headings."

    public init() {}

    /// Max character count for suggesting heading trait. Longer text is treated as paragraph.
    private static let maxHeadingLength = 120

    /// Font styles that typically indicate headings.
    private static let headingFonts: Set<String> = [
        ".title", ".title2", ".title3", ".largeTitle", ".headline",
        "title", "title2", "title3", "largeTitle", "headline",
    ]

    /// View types where the Text is used as a label/title of the control, not a structural heading.
    private static let labelConsumerViews: Set<String> = ["Button", "Link", "Toggle"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
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
                let text = mod.arguments.first?.text ?? ""
                return Self.headingFonts.contains(text) || Self.headingFonts.contains(where: { text.contains($0) })
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
                diagnostics.append(makeDiagnostic(
                    message: "Text with heading font style is missing .accessibilityAddTraits(.isHeader). VoiceOver users won't be able to navigate to this heading.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add .accessibilityAddTraits(.isHeader)"
                ))
            }
        }
        return diagnostics
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
    public let wcagCriteria = ["1.3.1"]
    public let description = "Don't include 'heading' in .accessibilityLabel(). Use .accessibilityAddTraits(.isHeader) instead."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for mod in collector.modifiers(named: "accessibilityLabel") {
            guard let text = mod.firstStringArgument else { continue }
            if text.lowercased().contains("heading") {
                diagnostics.append(makeDiagnostic(
                    message: "Accessibility label \"\(text)\" contains 'heading'. Use .accessibilityAddTraits(.isHeader) instead of faking a heading in the label text.",
                    node: mod.callExpr,
                    context: context,
                    suggestion: "Remove \"heading\" from label and add .accessibilityAddTraits(.isHeader)"
                ))
            }
        }
        return diagnostics
    }
}
