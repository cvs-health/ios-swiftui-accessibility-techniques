import SwiftSyntax

// MARK: - Button Used As Link Rule

/// Flags `Button` actions that open a URL — these should use `Link` instead
/// so VoiceOver announces the correct role.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: LinksView.swift — bad example uses Button instead of Link for external URLs
public struct ButtonUsedAsLinkRule: A11yRule {
    public let id = "button-used-as-link"
    public let name = "Button Used Instead of Link"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["4.1.2"]
    public let description = "Use Link instead of Button when navigating to a URL. VoiceOver announces Links differently than Buttons."

    public init() {}

    /// Patterns in button action body that suggest URL navigation.
    private static let urlPatterns = [
        "openURL", "UIApplication.shared.open", "URL(string:",
        "SFSafariViewController", "WKWebView", "safari",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Button") {
            // The rule exists so VoiceOver announces "Link" rather than "Button". If the author
            // already added the trait, that is achieved — asking them to swap the view type as
            // well is a style preference, not an accessibility defect.
            let announcesLink = view.modifiers.modifiers(named: "accessibilityAddTraits").contains { mod in
                mod.arguments.contains { $0.text.contains("isLink") }
            }
            if announcesLink { continue }

            // Check the trailing closure (action body)
            guard let body = view.callExpr.trailingClosure else { continue }
            let bodyText = body.trimmedDescription

            for pattern in Self.urlPatterns {
                if bodyText.contains(pattern) {
                    diagnostics.append(makeDiagnostic(
                        message: "Button opens a URL — use Link instead so VoiceOver announces the 'Link' role rather than 'Button'.",
                        node: view.callExpr,
                        context: context,
                        suggestion: "Replace Button with Link(destination:)"
                    ))
                    break
                }
            }
        }
        return diagnostics
    }
}

// MARK: - Generic Link Text Rule

/// Flags `Link` elements with generic text like "Click here", "here", "Read more", "Learn more".
///
/// WCAG 2.4.4 Link Purpose (In Context)
/// Reference: LinksView.swift — bad examples use "Click here" and "here"
public struct GenericLinkTextRule: A11yRule {
    public let id = "generic-link-text"
    public let name = "Generic Link Text"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.4.4"]
    public let description = "Link and button text should describe the destination or action, not use generic phrases like 'Click here', 'Read more' or 'Learn more'."

    public init() {}

    /// Generic link text patterns (case-insensitive comparison).
    private static let genericTexts: Set<String> = [
        "click here", "here", "read more", "learn more", "more",
        "tap here", "see more", "view more", "link", "go",
        "more options", "find out more", "show more", "more info",
    ]

    /// Extract label text from a Link's label closure, e.g.
    /// `Link(destination: ..., label: { Text("Click here") })` or
    /// `Link(destination: ...) { Text("Click here") }`
    private func extractLabelFromClosure(_ call: FunctionCallExprSyntax) -> String? {
        let closures: [ClosureExprSyntax] = [
            call.trailingClosure,
            call.arguments.first(where: { $0.label?.text == "label" })?
                .expression.as(ClosureExprSyntax.self),
        ].compactMap { $0 }

        for closure in closures {
            for statement in closure.statements {
                if let funcCall = statement.item.as(FunctionCallExprSyntax.self),
                   let callee = funcCall.calledExpression.as(DeclReferenceExprSyntax.self),
                   callee.baseName.text == "Text",
                   let firstArg = funcCall.arguments.first,
                   let str = firstArg.expression.as(StringLiteralExprSyntax.self) {
                    return str.segments.compactMap { $0.as(StringSegmentSyntax.self)?.content.text }.joined()
                }
            }
        }
        return nil
    }

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        // Buttons as well as Links. A generic label fails the same way whichever role it has,
        // and this is how the defect is usually written: the phrase repeated down a page of
        // cards where the destination differs every time and the name never does. Testers file
        // it under 2.4.4 for buttons too.
        for view in visitor.views(ofType: "Link") + visitor.views(ofType: "Button") {
            // Check inline label: Link("Click here", destination: ...)
            var labelText = view.firstStringArgument ?? ""

            // Also check label closure: Link(destination: ..., label: { Text("Click here") })
            if labelText.isEmpty, let closureText = extractLabelFromClosure(view.callExpr) {
                labelText = closureText
            }

            // A localised app holds no literal text, so resolve the constant to the English
            // string it renders. Without this the rule reads nothing on such a codebase: every
            // label is `Button(Localized.learnMore)` and the literals live in a catalogue.
            if labelText.isEmpty {
                labelText = resolvedLocalizedLabel(view, context: context) ?? ""
            }

            if Self.genericTexts.contains(labelText.lowercased().trimmingCharacters(in: .whitespaces)) {
                let isButton = view.viewType == "Button"
                diagnostics.append(makeDiagnostic(
                    message: isButton
                        ? "\(view.sourceViewType) text \"\(labelText)\" is generic. Several of these on one screen all announce the same name while doing different things — give each one the context that distinguishes it."
                        : "Link text \"\(labelText)\" is generic. Use descriptive text that explains where the link goes.",
                    node: view.callExpr,
                    context: context,
                    suggestion: isButton
                        ? "Replace \"\(labelText)\" with descriptive text, or add .accessibilityLabel() naming what it opens"
                        : "Replace \"\(labelText)\" with descriptive text like \"Log in to your account\""
                ))
                continue
            }

            // Check .accessibilityLabel override
            for label in view.modifiers.modifiers(named: "accessibilityLabel") {
                guard let text = label.firstStringArgument else { continue }
                if Self.genericTexts.contains(text.lowercased().trimmingCharacters(in: .whitespaces)) {
                    diagnostics.append(makeDiagnostic(
                        message: "Link .accessibilityLabel(\"\(text)\") is generic. Use descriptive text.",
                        node: label.reportNode,
                        context: context,
                        suggestion: "Replace \"\(text)\" with text describing the link destination"
                    ))
                }
            }
        }
        return diagnostics
    }
    /// The English text behind a localised label reference, if it can be resolved.
    ///
    /// Reads the trailing identifier of the label expression — `Localized.learnMore` resolves on
    /// `learnMore` — against the map the pre-pass built from the Swift constants and the string
    /// catalogues. Also handles a key written inline, as in `Button(Localized.string("learnMore"))`.
    private func resolvedLocalizedLabel(
        _ view: ViewHierarchyVisitor.DetectedView,
        context: RuleContext
    ) -> String? {
        guard !context.localizedText.isEmpty else { return nil }
        guard let first = view.callExpr.arguments.first?.expression else { return nil }

        // Inline key: Localized.string("learnMore"). The map carries raw catalogue keys as
        // well as constant names, so one lookup serves both shapes.
        if let key = StringCatalogIndex.KeyCollector.lookupKey(in: first),
           let text = context.localizedText[key] {
            return text
        }

        // Constant reference: Localized.learnMore
        var identifier = first.trimmedDescription.trimmingCharacters(in: .whitespaces)
        guard !identifier.contains("(") else { return nil }
        if let lastDot = identifier.lastIndex(of: ".") {
            identifier = String(identifier[identifier.index(after: lastDot)...])
        }
        return context.localizedText[identifier]
    }

}
