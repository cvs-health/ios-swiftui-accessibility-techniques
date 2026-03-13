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

    /// Returns true if `.accessibilityLabel` appears after this view in source (e.g. in a following statement
    /// after `#if` / `#endif`), so we don't flag when the label is split across statements.
    private func hasAccessibilityLabelInFollowingStatements(chainRoot: ExprSyntax, viewStartOffset: Int, syntax: SourceFileSyntax) -> Bool {
        let viewEndOffset = chainRoot.endPosition.utf8Offset
        let allLabels = ModifierCollector.collect(from: syntax).modifiers(named: "accessibilityLabel")
        guard let firstAfter = allLabels.first(where: { $0.callExpr.positionAfterSkippingLeadingTrivia.utf8Offset > viewEndOffset }) else {
            return false
        }
        let labelOffset = firstAfter.callExpr.positionAfterSkippingLeadingTrivia.utf8Offset
        // If another view starts before this label (after our chain), the label likely belongs to that view
        let otherViewsAfter = ViewHierarchyVisitor.analyze(syntax).detectedViews
            .filter { $0.callExpr.positionAfterSkippingLeadingTrivia.utf8Offset > viewEndOffset }
        if let nextViewOffset = otherViewsAfter.map({ $0.callExpr.positionAfterSkippingLeadingTrivia.utf8Offset }).min(),
           labelOffset >= nextViewOffset {
            return false
        }
        return true
    }

    /// Source-text fallback: after the chain root, look for ".accessibilityLabel(" before any other view.
    /// Handles modifier chains split by #if / #endif where the AST-based collector misses the label.
    private func hasAccessibilityLabelInSourceAfterView(chainRoot: ExprSyntax, context: RuleContext) -> Bool {
        let viewEndOffset = chainRoot.endPosition.utf8Offset
        let source = context.sourceText
        let utf8 = source.utf8
        guard viewEndOffset < utf8.count else { return false }
        let startIdx = utf8.index(utf8.startIndex, offsetBy: viewEndOffset)
        let windowLen = min(2048, utf8.distance(from: startIdx, to: utf8.endIndex))
        guard windowLen > 0,
              let endIdx = utf8.index(startIdx, offsetBy: windowLen, limitedBy: utf8.endIndex) else { return false }
        let window = String(source[startIdx..<endIdx])
        let labelPattern = ".accessibilityLabel("
        let viewStarts = ["TextField(", "SecureField(", "Button(", "Toggle(", "Image(", "Text("]
        guard let labelRange = window.range(of: labelPattern) else { return false }
        let labelPos = window.distance(from: window.startIndex, to: labelRange.lowerBound)
        let firstOtherView = viewStarts.compactMap { window.range(of: $0).map { window.distance(from: window.startIndex, to: $0.lowerBound) } }.min()
        if let first = firstOtherView, first < labelPos { return false }
        return true
    }

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        let textFields = visitor.views(ofType: "TextField") + visitor.views(ofType: "SecureField")

        for view in textFields {
            let mods = view.modifiers

            // Has explicit .accessibilityLabel in the modifier chain — OK
            if mods.hasModifier("accessibilityLabel") { continue }

            // Modifier chain may be split by #if / #endif; .accessibilityLabel may appear in a following statement
            let viewStart = view.callExpr.positionAfterSkippingLeadingTrivia.utf8Offset
            if hasAccessibilityLabelInFollowingStatements(chainRoot: view.chainRoot, viewStartOffset: viewStart, syntax: syntax) {
                continue
            }
            // Fallback: scan source after this view's chain for ".accessibilityLabel(" (handles #if / #endif splitting)
            if hasAccessibilityLabelInSourceAfterView(chainRoot: view.chainRoot, context: context) {
                continue
            }

            let inlineLabel = view.firstStringArgument ?? ""
            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                diagnostics.append(makeDiagnostic(
                    message: "\(view.viewType) has an empty label and no .accessibilityLabel(). Add a visible Text label and .accessibilityLabel() so VoiceOver users know what to enter.",
                    node: view.callExpr,
                    context: context
                ))
            } else {
                diagnostics.append(makeDiagnostic(
                    message: "\(view.viewType) uses placeholder text \"\(inlineLabel)\" as its only label. Placeholder text disappears when the user starts typing, leaving no label for VoiceOver, and has insufficient contrast. Add a persistent visible label (e.g. a Text view above the field) and .accessibilityLabel().",
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
