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
                        context: context
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

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Link") {
            // Check inline label
            let labelText = view.firstStringArgument ?? ""
            if Self.genericTexts.contains(labelText.lowercased().trimmingCharacters(in: .whitespaces)) {
                diagnostics.append(makeDiagnostic(
                    message: "Link text \"\(labelText)\" is generic. Use descriptive text that explains where the link goes.",
                    node: view.callExpr,
                    context: context
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
                        context: context
                    ))
                }
            }
        }
        return diagnostics
    }
}
