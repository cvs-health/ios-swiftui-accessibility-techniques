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
    /// Calls that actually open a URL.
    ///
    /// `URL(string:)` was here and matched a Button that *built* a URL and handed it to a
    /// callback, opening nothing — constructing a URL is not opening one. The bare substring
    /// `safari` went with it: `SFSafariViewController` already covers the real case, and a
    /// lowercase word that short matches identifiers and comments.
    private static let urlPatterns = [
        "openURL", "UIApplication.shared.open",
        "SFSafariViewController", "WKWebView",
    ]

    /// Whether every URL-opening call in the action sits inside a conditional.
    ///
    /// `Link(destination:)` takes one static destination, so a Button that opens a URL on only
    /// one branch cannot be replaced by a Link — the rule's own advice becomes impossible to
    /// follow. Found on a rewards card that opens a deep link for one navigation case and
    /// presents an alert or a modal for the others.
    static func opensURLOnlyConditionally(_ closure: ClosureExprSyntax) -> Bool {
        var found = false
        var allConditional = true

        func visit(_ node: Syntax) {
            if let call = node.as(FunctionCallExprSyntax.self) {
                // The callee, not the whole call. A call's text contains its arguments, so
                // `Task { … openURL(url) … }` matched on its own body and, sitting outside any
                // conditional, voted the open unconditional — hiding the very case this check
                // exists for.
                let text = call.calledExpression.trimmedDescription
                if urlPatterns.contains(where: { text.contains($0) }) {
                    found = true
                    if !isInsideConditional(Syntax(call), stoppingAt: Syntax(closure)) {
                        allConditional = false
                    }
                }
            }
            for child in node.children(viewMode: .sourceAccurate) { visit(child) }
        }
        visit(Syntax(closure))
        return found && allConditional
    }

    /// Whether an `if` or `switch` sits between `node` and `boundary`.
    private static func isInsideConditional(_ node: Syntax, stoppingAt boundary: Syntax) -> Bool {
        var cursor = node.parent
        while let current = cursor, current.id != boundary.id {
            if current.is(IfExprSyntax.self) || current.is(SwitchExprSyntax.self) { return true }
            cursor = current.parent
        }
        return false
    }

    /// Modifiers whose action builder accepts buttons and nothing else.
    private static let alertModifiers: Set<String> = ["alert", "confirmationDialog"]

    /// Whether this Button is written in the `actions` closure of an alert or dialog.
    ///
    /// Apple's documentation is explicit that the system ignores any view in that closure
    /// other than a button, so replacing one with a `Link` removes it from the alert. Seven of
    /// sixteen findings on the flagship app were this shape: an "OK" or "Continue" button that
    /// opens a privacy statement or an app-store page once the user confirms.
    ///
    /// Only the lexical case is caught. An alert whose buttons are built in computed
    /// properties — `.alert { cancelButton; confirmButton }` — is not matched, and those are
    /// instead handled by the effects check: an alert button almost always clears the
    /// presenting state alongside the open.
    static func isAlertAction(_ node: FunctionCallExprSyntax) -> Bool {
        var cursor: Syntax? = Syntax(node).parent
        while let current = cursor {
            if let closure = current.as(ClosureExprSyntax.self),
               let name = Self.owningCallName(of: closure),
               alertModifiers.contains(name) {
                return true
            }
            if current.is(VariableDeclSyntax.self) || current.is(FunctionDeclSyntax.self) {
                return false
            }
            cursor = current.parent
        }
        return false
    }

    /// The name of the modifier a closure belongs to.
    ///
    /// `.alert(title, isPresented:) { … } message: { … }` writes its first closure as a
    /// labelled `actions:` argument rather than the trailing one, so a check that only looked
    /// at `closure.parent as FunctionCallExpr` missed exactly the two-closure alert form —
    /// which is the common one.
    private static func owningCallName(of closure: ClosureExprSyntax) -> String? {
        var node: Syntax? = closure.parent
        while let current = node {
            if let call = current.as(FunctionCallExprSyntax.self) {
                return call.calledExpression
                    .as(MemberAccessExprSyntax.self)?
                    .declName.baseName.text
            }
            if current.is(LabeledExprSyntax.self)
                || current.is(LabeledExprListSyntax.self)
                || current.is(MultipleTrailingClosureElementSyntax.self)
                || current.is(MultipleTrailingClosureElementListSyntax.self) {
                node = current.parent
                continue
            }
            return nil
        }
        return nil
    }

    /// Whether the action does anything besides derive and open the URL.
    ///
    /// A `Link` is a destination, not an action: it runs no code. So an action that also tracks
    /// analytics, invokes a callback, or clears the state presenting it cannot become one, and
    /// the honest fix is the `.isLink` trait on the Button it already has.
    ///
    /// Deriving the URL does not count — a `let`, a `guard let`, and the `URL(string:)` that
    /// builds it are all plumbing the Link form would absorb. An assignment or a call that is
    /// not the open itself does count, and so does a completion handler on the open, which is
    /// how a "could not open" fallback is written.
    static func hasEffectsBeyondOpening(_ closure: ClosureExprSyntax) -> Bool {
        for statement in closure.statements {
            switch statement.item {
            case .decl, .stmt:
                // `let url = …`, `guard let url else { return }` — plumbing.
                continue
            case .expr(let expr):
                guard let call = expr.as(FunctionCallExprSyntax.self) else {
                    // A bare assignment such as `alertInfo = nil`.
                    if expr.is(InfixOperatorExprSyntax.self) { return true }
                    continue
                }
                let callee = call.calledExpression.trimmedDescription
                let isTheOpen = urlPatterns.contains { callee.contains($0) }
                if !isTheOpen { return true }
                // `openURL(url) { status in … }` — a fallback a Link cannot run.
                if call.trailingClosure != nil { return true }
            }
        }
        return false
    }

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

            // A conditional open cannot become a Link, so the suggestion would not apply.
            if Self.opensURLOnlyConditionally(body) { continue }

            // An alert's buttons cannot be anything but buttons: Apple documents that the
            // system ignores any view in an `actions` closure that is not a Button, so a Link
            // written there is silently dropped. With no available fix, there is no finding.
            if Self.isAlertAction(view.callExpr) { continue }

            for pattern in Self.urlPatterns {
                if bodyText.contains(pattern) {
                    // A Link runs no code. When the action does more than open — analytics, a
                    // callback, resetting the presenting state — swapping the view type would
                    // drop that work, so the fix is the trait rather than the view. The defect
                    // is the same either way: VoiceOver says "Button" where it should say
                    // "Link".
                    let doesMoreThanOpen = Self.hasEffectsBeyondOpening(body)
                    diagnostics.append(makeDiagnostic(
                        message: doesMoreThanOpen
                            ? "Button opens a URL but also does other work, so VoiceOver announces 'Button' where it should say 'Link'. A Link runs no code and would drop that work — add .accessibilityAddTraits(.isLink) instead."
                            : "Button opens a URL — use Link instead so VoiceOver announces the 'Link' role rather than 'Button'.",
                        node: view.callExpr,
                        context: context,
                        suggestion: doesMoreThanOpen
                            ? "Add .accessibilityAddTraits(.isLink) to the Button"
                            : "Replace Button with Link(destination:)"
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
