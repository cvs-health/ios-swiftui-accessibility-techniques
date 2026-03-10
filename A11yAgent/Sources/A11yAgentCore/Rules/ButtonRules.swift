import SwiftSyntax

// MARK: - Button Label Contains Role Rule

/// Flags `.accessibilityLabel()` on Buttons that contain the word "button" —
/// the Button role is announced automatically by VoiceOver.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: ButtonsView.swift, Buttons.md — "Don't include 'Button' in .accessibilityLabel"
public struct ButtonLabelContainsRoleRule: A11yRule {
    public let id = "button-label-contains-role"
    public let name = "Button Label Contains 'Button'"
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["4.1.2"]
    public let description = "Don't include 'button' in .accessibilityLabel() — the Button role is announced automatically by VoiceOver."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Button") {
            // Check explicit accessibilityLabel
            for label in view.modifiers.modifiers(named: "accessibilityLabel") {
                guard let text = label.firstStringArgument else { continue }
                if text.lowercased().contains("button") {
                    diagnostics.append(makeDiagnostic(
                        message: "Button's .accessibilityLabel(\"\(text)\") contains 'button'. Remove it — VoiceOver announces the Button role automatically.",
                        node: label.callExpr,
                        context: context
                    ))
                }
            }
            // Check the inline label text too
            if let labelText = view.firstStringArgument, labelText.lowercased().contains("button") {
                diagnostics.append(makeDiagnostic(
                    message: "Button label text \"\(labelText)\" contains 'button'. The role is announced automatically by VoiceOver.",
                    node: view.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Icon-Only Button Missing Label Rule

/// Flags Buttons that contain only an Image (no Text) and lack `.accessibilityLabel()`.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: ButtonsView.swift — good examples add unique labels to icon-only edit buttons
public struct IconOnlyButtonMissingLabelRule: A11yRule {
    public let id = "icon-button-missing-label"
    public let name = "Icon-Only Button Missing Label"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Buttons containing only an Image must have .accessibilityLabel() to describe their action."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Button") {
            // Button must have no inline text label (empty string or nil)
            let hasInlineLabel = view.firstStringArgument != nil && !view.firstStringArgument!.isEmpty
            if hasInlineLabel { continue }

            // Collect all closures: the trailing closure and any additional trailing closures
            // Button { action } label: { Image(...) } uses additionalTrailingClosures for `label:`
            var closuresToCheck: [ClosureExprSyntax] = []
            if let trailing = view.callExpr.trailingClosure {
                closuresToCheck.append(trailing)
            }
            for additional in view.callExpr.additionalTrailingClosures {
                closuresToCheck.append(additional.closure)
            }

            guard !closuresToCheck.isEmpty else { continue }

            // Scan all closures for Image vs Text
            var hasText = false
            var hasImage = false
            for closure in closuresToCheck {
                let innerVisitor = ViewHierarchyVisitor.analyze(closure)
                if !innerVisitor.views(ofType: "Text").isEmpty || !innerVisitor.views(ofType: "Label").isEmpty {
                    hasText = true
                }
                if !innerVisitor.views(ofType: "Image").isEmpty {
                    hasImage = true
                }
            }

            if hasImage && !hasText {
                // It's an icon-only button — check for accessibility label
                if !view.modifiers.hasModifier("accessibilityLabel") {
                    diagnostics.append(makeDiagnostic(
                        message: "Icon-only Button is missing .accessibilityLabel(). VoiceOver users won't know what this button does.",
                        node: view.callExpr,
                        context: context
                    ))
                }
            }
        }
        return diagnostics
    }
}

// MARK: - Visually Disabled Not Semantically Rule

/// Flags Buttons that appear visually disabled (grayed out via .tint(.gray) or low .opacity())
/// but are not actually disabled via `.disabled(true)`.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: ButtonsView.swift — bad example uses .tint(.gray) without .disabled(true)
public struct VisuallyDisabledNotSemanticallyRule: A11yRule {
    public let id = "visually-disabled-not-semantic"
    public let name = "Visually Disabled But Not .disabled(true)"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Buttons that appear visually disabled must also use .disabled(true) so assistive technology knows they are disabled."

    public init() {}

    /// Visual cues that suggest a disabled state.
    private static let grayTints = [".gray", "Color.gray", ".secondary"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Button") {
            let mods = view.modifiers

            // Check for visual disabled indicators
            let hasGrayTint = mods.modifiers(named: "tint").contains { mod in
                Self.grayTints.contains(where: { mod.arguments.first?.text.contains($0) == true })
            }
            let hasLowOpacity = mods.modifiers(named: "opacity").contains { mod in
                guard let text = mod.arguments.first?.text,
                      let value = Double(text) else { return false }
                return value < 0.5
            }

            guard hasGrayTint || hasLowOpacity else { continue }

            // Check if .disabled(true) is present
            let hasDisabled = mods.modifiers(named: "disabled").contains { mod in
                mod.arguments.first?.text == "true"
            }
            if !hasDisabled {
                diagnostics.append(makeDiagnostic(
                    message: "Button appears visually disabled but is missing .disabled(true). VoiceOver won't announce the disabled state.",
                    node: view.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}
