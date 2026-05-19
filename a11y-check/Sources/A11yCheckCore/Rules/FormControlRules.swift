import SwiftSyntax

// MARK: - TextField Missing Label Rule

/// Flags `TextField("", text:)` with an empty placeholder or
/// TextFields that rely only on placeholder text as the accessible name.
///
/// WCAG 3.3.2 Labels or Instructions — visible label must persist
/// WCAG 4.1.2 Name, Role, Value — accessible name must be provided
/// Reference: TextFieldsView.swift — bad examples have empty or missing labels
public struct TextFieldMissingLabelRule: A11yRule {
    public let id = "textfield-missing-label"
    public let name = "TextField Missing Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["3.3.2", "4.1.2"]
    public let description = "TextFields must have a persistent visible label (3.3.2) and an accessible name via .accessibilityLabel() (4.1.2). Placeholder text alone is insufficient."

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

    /// Walk up the AST to check if this node is inside a LabeledContent call
    /// with a non-empty string label (e.g. `LabeledContent("First Name") { ... }`).
    private func isInsideLabeledContent(_ node: some SyntaxProtocol) -> Bool {
        var current: Syntax? = Syntax(node)
        while let parent = current?.parent {
            if let funcCall = parent.as(FunctionCallExprSyntax.self),
               let callee = funcCall.calledExpression.as(DeclReferenceExprSyntax.self),
               callee.baseName.text == "LabeledContent" {
                if let firstArg = funcCall.arguments.first,
                   firstArg.label == nil,
                   let str = firstArg.expression.as(StringLiteralExprSyntax.self) {
                    let text = str.segments.compactMap { $0.as(StringSegmentSyntax.self)?.content.text }.joined()
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        return true
                    }
                }
            }
            current = parent
        }
        return false
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

            // Inside LabeledContent("Label") { ... } — the LabeledContent provides
            // both a persistent visible label and the VoiceOver accessible name.
            if isInsideLabeledContent(view.callExpr) { continue }

            let inlineLabel = view.firstStringArgument ?? ""
            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                diagnostics.append(makeDiagnostic(
                    message: "\(view.viewType) has an empty label and no .accessibilityLabel(). Add a visible Text label (WCAG 3.3.2) and .accessibilityLabel() (WCAG 4.1.2) so VoiceOver users know what to enter.",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["3.3.2", "4.1.2"],
                    suggestion: "Add a visible Text(\"Label\") above the field and .accessibilityLabel(\"Label\")"
                ))
            } else {
                diagnostics.append(makeDiagnostic(
                    message: "\(view.viewType) uses placeholder text \"\(inlineLabel)\" as its only label. Placeholder text disappears when the user starts typing, leaving no persistent visible label (WCAG 3.3.2). Add a visible Text label above the field and .accessibilityLabel().",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["3.3.2"],
                    suggestion: "Add a visible Text(\"\(inlineLabel)\") label above the field and .accessibilityLabel(\"\(inlineLabel)\")"
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Slider Missing Label Rule

/// Flags `Slider` without a visible label or `.accessibilityLabel()`.
///
/// WCAG 3.3.2 Labels or Instructions — visible label must persist
/// WCAG 4.1.2 Name, Role, Value — accessible name must be provided
/// Reference: SlidersView.swift — bad example has Slider without label
public struct SliderMissingLabelRule: A11yRule {
    public let id = "slider-missing-label"
    public let name = "Slider Missing Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["3.3.2", "4.1.2"]
    public let description = "Sliders must have a persistent visible label (3.3.2) and an accessible name (4.1.2)."

    public init() {}

    private func hasLabelInTrailingClosure(_ callExpr: FunctionCallExprSyntax) -> Bool {
        guard let closure = callExpr.trailingClosure else { return false }
        let text = closure.statements.description
        return text.contains("Text(") || text.contains("Label(")
    }

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Slider") {
            let mods = view.modifiers

            if mods.hasModifier("accessibilityLabel") { continue }

            // Slider's label can be a string argument or a trailing closure with Text/Label
            let inlineLabel = view.firstStringArgument ?? ""
            let hasLabelsHidden = mods.hasModifier("labelsHidden")
            let hasClosureLabel = hasLabelInTrailingClosure(view.callExpr)

            if hasClosureLabel && !hasLabelsHidden { continue }

            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty && !hasClosureLabel {
                diagnostics.append(makeDiagnostic(
                    message: "Slider has no visible label (WCAG 3.3.2) and no accessible name (WCAG 4.1.2). Add label text and .accessibilityLabel().",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["3.3.2", "4.1.2"],
                    suggestion: "Add a visible Text(\"Label\") above the Slider and .accessibilityLabel(\"Label\")"
                ))
            } else if hasLabelsHidden {
                diagnostics.append(makeDiagnostic(
                    message: "Slider uses .labelsHidden() without .accessibilityLabel(). The visible label is hidden but VoiceOver still needs an accessible name (WCAG 4.1.2).",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["4.1.2"],
                    suggestion: "Add .accessibilityLabel(\"description\") when using .labelsHidden()"
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Stepper Missing Label Rule

/// Flags `Stepper` without a visible label or `.accessibilityLabel()`.
///
/// WCAG 3.3.2 Labels or Instructions — visible label must persist
/// WCAG 4.1.2 Name, Role, Value — accessible name must be provided
/// Reference: SteppersView.swift
public struct StepperMissingLabelRule: A11yRule {
    public let id = "stepper-missing-label"
    public let name = "Stepper Missing Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["3.3.2", "4.1.2"]
    public let description = "Steppers must have a persistent visible label (3.3.2) and an accessible name (4.1.2)."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Stepper") {
            let mods = view.modifiers
            if mods.hasModifier("accessibilityLabel") { continue }

            let inlineLabel = view.firstStringArgument ?? ""
            if inlineLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                if let closure = view.callExpr.trailingClosure {
                    let text = closure.statements.description
                    if text.contains("Text(") || text.contains("Label(") { continue }
                }
                diagnostics.append(makeDiagnostic(
                    message: "Stepper has no visible label (WCAG 3.3.2) and no accessible name (WCAG 4.1.2). Add label text and .accessibilityLabel().",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["3.3.2", "4.1.2"],
                    suggestion: "Add a visible Text(\"Label\") above the Stepper and .accessibilityLabel(\"Label\")"
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Picker Missing Label Rule

/// Flags `Picker` without a visible label or `.accessibilityLabel()`.
///
/// WCAG 3.3.2 Labels or Instructions — visible label must persist
/// WCAG 4.1.2 Name, Role, Value — accessible name must be provided
/// Reference: PickersView.swift
public struct PickerMissingLabelRule: A11yRule {
    public let id = "picker-missing-label"
    public let name = "Picker Missing Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["3.3.2", "4.1.2"]
    public let description = "Pickers must have a persistent visible label (3.3.2) and an accessible name (4.1.2)."

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
                    message: "Picker has no visible label (WCAG 3.3.2) and no accessible name (WCAG 4.1.2). Add label text and .accessibilityLabel().",
                    node: view.callExpr,
                    context: context,
                    wcagCriteriaOverride: ["3.3.2", "4.1.2"],
                    suggestion: "Add a visible Text(\"Label\") above the Picker and .accessibilityLabel(\"Label\")"
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Picker Style Accessibility Rule

/// Flags `Picker` views using `WheelPickerStyle` or `SegmentedPickerStyle` that are
/// missing `.accessibilityLabel` or `.accessibilityElement(children: .contain)`.
///
/// WCAG 4.1.2 Name, Role, Value — these picker styles require both modifiers
/// for VoiceOver to speak the accessible label.
public struct PickerStyleAccessibilityRule: A11yRule {
    public let id = "picker-style-missing-accessibility"
    public let name = "Picker Style Missing Accessibility Modifiers"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["4.1.2"]
    public let description = "Pickers using WheelPickerStyle or SegmentedPickerStyle must have .accessibilityLabel and .accessibilityElement(children: .contain) or VoiceOver will not speak the label."

    public init() {}

    private func isWheelOrSegmentedStyle(_ mods: ModifierCollector) -> Bool {
        mods.modifiers(named: "pickerStyle").contains { mod in
            guard let text = mod.arguments.first?.text else { return false }
            return text.contains("wheel") || text.contains("Wheel")
                || text.contains("segmented") || text.contains("Segmented")
        }
    }

    private func hasAccessibilityElementContain(_ mods: ModifierCollector) -> Bool {
        mods.modifiers(named: "accessibilityElement").contains { mod in
            mod.arguments.contains { $0.label == "children" && $0.text.contains("contain") }
        }
    }

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Picker") {
            let mods = view.modifiers

            guard isWheelOrSegmentedStyle(mods) else { continue }

            let hasLabel = mods.hasModifier("accessibilityLabel")
            let hasContain = hasAccessibilityElementContain(mods)

            if hasLabel && hasContain { continue }

            let styleName = mods.modifiers(named: "pickerStyle").first
                .flatMap { $0.arguments.first?.text } ?? "wheel/segmented"

            if !hasLabel && !hasContain {
                let fix = makeModifierFix(
                    chainRoot: view.chainRoot,
                    modifier: ".accessibilityElement(children: .contain)",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "Picker with \(styleName) style is missing both .accessibilityLabel() and .accessibilityElement(children: .contain). Without these modifiers, VoiceOver will not speak the picker's label.",
                    node: view.callExpr,
                    context: context,
                    fix: fix,
                    suggestion: "Add .accessibilityLabel(\"Label\") and .accessibilityElement(children: .contain)"
                ))
            } else if !hasLabel {
                let fix = makeModifierFix(
                    chainRoot: view.chainRoot,
                    modifier: ".accessibilityLabel(\"Label\")",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "Picker with \(styleName) style is missing .accessibilityLabel(). Add .accessibilityLabel() matching the visible label text so VoiceOver can identify this picker.",
                    node: view.callExpr,
                    context: context,
                    fix: fix,
                    suggestion: "Add .accessibilityLabel(\"Label\") matching the visible label"
                ))
            } else {
                let fix = makeModifierFix(
                    chainRoot: view.chainRoot,
                    modifier: ".accessibilityElement(children: .contain)",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "Picker with \(styleName) style is missing .accessibilityElement(children: .contain). Without this modifier, VoiceOver will not speak the .accessibilityLabel.",
                    node: view.callExpr,
                    context: context,
                    fix: fix,
                    suggestion: "Add .accessibilityElement(children: .contain)"
                ))
            }
        }
        return diagnostics
    }
}
