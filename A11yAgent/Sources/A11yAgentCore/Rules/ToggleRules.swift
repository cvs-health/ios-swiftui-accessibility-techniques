import SwiftSyntax

// MARK: - Toggle Missing Label Rule

/// Flags `Toggle("", isOn:)` or `Toggle(isOn:) { }.labelsHidden()` where
/// the toggle has no meaningful label for VoiceOver.
/// Skips `Toggle(isOn:) { Text(...) }` or `Toggle(isOn:) { Image(...) }` — the trailing closure provides the label.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: TogglesView.swift — bad example uses Toggle("").labelsHidden() with separate Text
public struct ToggleMissingLabelRule: A11yRule {
    public let id = "toggle-missing-label"
    public let name = "Toggle Missing Label"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Toggles must have a meaningful label — either inline text, view-builder content, or .accessibilityLabel()."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Toggle") {
            let mods = view.modifiers

            // Has explicit .accessibilityLabel — OK
            if mods.hasModifier("accessibilityLabel") { continue }

            // Toggle(isOn:) { Text("...") } or { Image(...) } — label is the trailing-closure content; don't flag as empty
            if view.callExpr.trailingClosure != nil { continue }

            // Check inline label text (Toggle("Label", isOn:))
            let inlineLabel = view.firstStringArgument ?? ""
            let hasLabelsHidden = mods.hasModifier("labelsHidden")

            // Bad: empty inline label, or labelsHidden() with no a11y label
            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                diagnostics.append(makeDiagnostic(
                    message: "Toggle has an empty label. Add meaningful label text or .accessibilityLabel().",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add label text: Toggle(\"Label\", isOn:) or .accessibilityLabel(\"Label\")"
                ))
            } else if hasLabelsHidden {
                diagnostics.append(makeDiagnostic(
                    message: "Toggle uses .labelsHidden() without .accessibilityLabel(). The label is visually hidden but VoiceOver needs it.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add .accessibilityLabel(\"Label\") when using .labelsHidden()"
                ))
            }
        }
        return diagnostics
    }
}
