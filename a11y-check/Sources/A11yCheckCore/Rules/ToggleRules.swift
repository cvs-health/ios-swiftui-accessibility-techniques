import SwiftSyntax

// MARK: - Toggle Missing Label Rule

/// Flags `Toggle("", isOn:)` or `Toggle(isOn:) { }.labelsHidden()` where
/// the toggle has no meaningful label for VoiceOver.
/// Skips `Toggle(isOn:) { Text(...) }` or `Toggle(isOn:) { Image(...) }` — the trailing closure provides the label.
///
/// WCAG 3.3.2 Labels or Instructions — visible label must persist
/// WCAG 4.1.2 Name, Role, Value — accessible name must be provided
/// Reference: TogglesView.swift — bad example uses Toggle("").labelsHidden() with separate Text
public struct ToggleMissingLabelRule: A11yRule {
    public let id = "toggle-missing-label"
    public let name = "Toggle Missing Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["3.3.2", "4.1.2"]
    public let description = "Toggles must have a persistent visible label (3.3.2) and an accessible name (4.1.2)."

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
                    message: "Toggle has an empty label. No visible label (WCAG 3.3.2) and no accessible name (WCAG 4.1.2). Add meaningful label text and .accessibilityLabel().",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["3.3.2", "4.1.2"],
                    suggestion: "Add label text: Toggle(\"Label\", isOn:) or .accessibilityLabel(\"Label\")"
                ))
            } else if hasLabelsHidden {
                diagnostics.append(makeDiagnostic(
                    message: "Toggle uses .labelsHidden() without .accessibilityLabel(). The visible label is hidden but VoiceOver still needs an accessible name (WCAG 4.1.2).",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["4.1.2"],
                    suggestion: "Add .accessibilityLabel(\"Label\") when using .labelsHidden()"
                ))
            }
        }
        return diagnostics
    }
}
