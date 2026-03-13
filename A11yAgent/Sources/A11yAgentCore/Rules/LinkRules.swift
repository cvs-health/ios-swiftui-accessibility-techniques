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
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["4.1.2"]
    public let description = "Use Link instead of Button when navigating to a URL. VoiceOver announces Links differently than Buttons."

    public init() {}

    /// Patterns in button action body that suggest URL navigation.
    private static let urlPatterns = [
        "openURL", "UIApplication.shared.open", "URL(string:",
        "SFSafariViewController", "WKWebView", "safari",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Button") {
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
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["2.4.4"]
    public let description = "Link text should describe the destination, not use generic phrases like 'Click here' or 'Read more'."

    public init() {}

    /// Generic link text patterns (case-insensitive comparison).
    private static let genericTexts: Set<String> = [
        "click here", "here", "read more", "learn more", "more",
        "tap here", "see more", "view more", "link", "go",
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
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Link") {
            // Check inline label: Link("Click here", destination: ...)
            var labelText = view.firstStringArgument ?? ""

            // Also check label closure: Link(destination: ..., label: { Text("Click here") })
            if labelText.isEmpty, let closureText = extractLabelFromClosure(view.callExpr) {
                labelText = closureText
            }

            if Self.genericTexts.contains(labelText.lowercased().trimmingCharacters(in: .whitespaces)) {
                diagnostics.append(makeDiagnostic(
                    message: "Link text \"\(labelText)\" is generic. Use descriptive text that explains where the link goes.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Replace \"\(labelText)\" with descriptive text like \"Log in to your account\""
                ))
                continue
            }

            // Check .accessibilityLabel override
            for label in view.modifiers.modifiers(named: "accessibilityLabel") {
                guard let text = label.firstStringArgument else { continue }
                if Self.genericTexts.contains(text.lowercased().trimmingCharacters(in: .whitespaces)) {
                    diagnostics.append(makeDiagnostic(
                        message: "Link .accessibilityLabel(\"\(text)\") is generic. Use descriptive text.",
                        node: label.callExpr,
                        context: context,
                        suggestion: "Replace \"\(text)\" with text describing the link destination"
                    ))
                }
            }
        }
        return diagnostics
    }
}
