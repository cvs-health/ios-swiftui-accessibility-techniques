import SwiftSyntax

// MARK: - Label in Name Rule

/// Flags views where the accessible name (accessibilityLabel) does not contain
/// the visible text label, violating WCAG 2.5.3 Label in Name.
///
/// WCAG 2.5.3 Label in Name
/// The accessible name must contain the visible text label so that speech input
/// users can activate controls by speaking the text they see on screen.
public struct LabelInNameRule: A11yRule {
    public let id = "label-in-name"
    public let name = "Label in Name"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.5.3"]
    public let description = "The accessible name (.accessibilityLabel) must begin with the visible text label so Voice Control users can activate the control by speaking what they see on screen. WCAG 2.5.3: 'the accessible name is identical to or begins with the same sequence of characters as the visible text label.'"

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        let viewTypes = ["Button", "Text", "Label"]

        for viewType in viewTypes {
            for view in visitor.views(ofType: viewType) {
                // Skip views with accessibilityHidden(true)
                if view.modifiers.modifiers(named: "accessibilityHidden").first?.firstStringArgument == "true" {
                    continue
                }

                // Get visible text
                guard let visibleText = view.firstStringArgument, !visibleText.isEmpty else {
                    continue
                }

                // Get accessible name from accessibilityLabel modifier
                guard let labelModifier = view.modifiers.modifiers(named: "accessibilityLabel").first,
                      let accessibleName = labelModifier.firstStringArgument,
                      !accessibleName.isEmpty else {
                    continue
                }

                let visibleLower = visibleText.lowercased()
                let nameLower = accessibleName.lowercased()

                if !nameLower.contains(visibleLower) {
                    // ERROR: visible text is not contained at all in accessible name
                    diagnostics.append(makeDiagnostic(
                        message: "\(viewType)'s visible text \"\(visibleText)\" is not contained in .accessibilityLabel(\"\(accessibleName)\"). Speech input users won't be able to activate this control by speaking the visible label.",
                        node: labelModifier.callExpr,
                        context: context,
                        suggestion: "Ensure the accessible name contains the visible text \"\(visibleText)\""
                    ))
                } else if !nameLower.hasPrefix(visibleLower) {
                    // ERROR: visible text present but not at the start — Voice Control prefix-match failure
                    // WCAG 2.5.3 Understanding: "the accessible name is identical to or begins with
                    // the same sequence of characters as the visible text label."
                    diagnostics.append(makeDiagnostic(
                        message: "\(viewType)'s visible text \"\(visibleText)\" is in .accessibilityLabel(\"\(accessibleName)\") but is not at the beginning. WCAG 2.5.3 requires the accessible name to start with the visible label so Voice Control users can activate the control by speaking what they see. Move \"\(visibleText)\" to the start, or remove .accessibilityLabel() so the visible label is used automatically.",
                        node: labelModifier.callExpr,
                        context: context,
                        suggestion: "Move \"\(visibleText)\" to the beginning of .accessibilityLabel(), or remove .accessibilityLabel() to use the visible label automatically"
                    ))
                }
            }
        }

        return diagnostics
    }
}
