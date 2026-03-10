import SwiftSyntax

// MARK: - TextField Missing Label Rule

/// Flags `TextField("", text:)` with an empty placeholder or
/// TextFields that rely only on placeholder text as the accessible name.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: TextFieldsView.swift — bad examples have empty or missing labels
public struct TextFieldMissingLabelRule: A11yRule {
    public let id = "textfield-missing-label"
    public let name = "TextField Missing Label"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "TextFields must have a non-empty label or .accessibilityLabel(). Placeholder text alone is insufficient as it disappears when the user starts typing."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        let textFields = visitor.views(ofType: "TextField") + visitor.views(ofType: "SecureField")

        for view in textFields {
            let mods = view.modifiers

            // Has explicit .accessibilityLabel — OK
            if mods.hasModifier("accessibilityLabel") { continue }

            // Check inline label/placeholder
            let inlineLabel = view.firstStringArgument ?? ""
            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                diagnostics.append(makeDiagnostic(
                    message: "\(view.viewType) has an empty label. Add label text or .accessibilityLabel() so VoiceOver users know what to enter.",
                    node: view.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Slider Missing Label Rule

/// Flags `Slider` without a visible label or `.accessibilityLabel()`.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: SlidersView.swift — bad example has Slider without label
public struct SliderMissingLabelRule: A11yRule {
    public let id = "slider-missing-label"
    public let name = "Slider Missing Label"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Sliders must have a label or .accessibilityLabel() so VoiceOver users know what value they're adjusting."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Slider") {
            let mods = view.modifiers

            if mods.hasModifier("accessibilityLabel") { continue }

            // Slider's first string argument is its label
            let inlineLabel = view.firstStringArgument ?? ""
            let hasLabelsHidden = mods.hasModifier("labelsHidden")

            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                diagnostics.append(makeDiagnostic(
                    message: "Slider has no label. Add label text or .accessibilityLabel() so VoiceOver users know what value they're adjusting.",
                    node: view.callExpr,
                    context: context
                ))
            } else if hasLabelsHidden {
                diagnostics.append(makeDiagnostic(
                    message: "Slider uses .labelsHidden() without .accessibilityLabel(). The label is hidden visually but VoiceOver still needs it.",
                    node: view.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Stepper Missing Label Rule

/// Flags `Stepper` without a visible label or `.accessibilityLabel()`.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: SteppersView.swift
public struct StepperMissingLabelRule: A11yRule {
    public let id = "stepper-missing-label"
    public let name = "Stepper Missing Label"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Steppers must have a label or .accessibilityLabel()."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Stepper") {
            let mods = view.modifiers
            if mods.hasModifier("accessibilityLabel") { continue }

            let inlineLabel = view.firstStringArgument ?? ""
            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                diagnostics.append(makeDiagnostic(
                    message: "Stepper has no label. Add label text or .accessibilityLabel().",
                    node: view.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Picker Missing Label Rule

/// Flags `Picker` without a visible label or `.accessibilityLabel()`.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: PickersView.swift
public struct PickerMissingLabelRule: A11yRule {
    public let id = "picker-missing-label"
    public let name = "Picker Missing Label"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Pickers must have a label or .accessibilityLabel()."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Picker") {
            let mods = view.modifiers
            if mods.hasModifier("accessibilityLabel") { continue }

            let inlineLabel = view.firstStringArgument ?? ""
            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                diagnostics.append(makeDiagnostic(
                    message: "Picker has no label. Add label text or .accessibilityLabel().",
                    node: view.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}
