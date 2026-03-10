import SwiftSyntax

// MARK: - Hidden On Parent With Controls Rule

/// Flags `.accessibilityHidden(true)` on container views (HStack, VStack, ZStack, etc.)
/// that contain interactive children (Button, Link, Toggle, TextField, etc.).
/// This hides all functional controls from VoiceOver, Voice Control, Full Keyboard Access,
/// and Switch Control.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: AccessibilityHidden.swift — bad example puts .accessibilityHidden(true) on parent
public struct HiddenOnParentWithControlsRule: A11yRule {
    public let id = "hidden-parent-with-controls"
    public let name = "accessibilityHidden on Parent with Controls"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Don't use .accessibilityHidden(true) on containers that have interactive children — it hides all controls from assistive technology."

    public init() {}

    /// View types that represent interactive/functional controls.
    private static let interactiveViewTypes: Set<String> = [
        "Button", "Link", "Toggle", "TextField", "SecureField", "TextEditor",
        "Slider", "Stepper", "Picker", "DatePicker", "ColorPicker",
        "NavigationLink", "Menu",
    ]

    /// View types that are containers.
    private static let containerViewTypes: Set<String> = [
        "HStack", "VStack", "ZStack", "LazyHStack", "LazyVStack",
        "Group", "GroupBox", "Section", "Form",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.detectedViews {
            guard Self.containerViewTypes.contains(view.viewType) else { continue }

            // Check if this container has .accessibilityHidden(true)
            guard hasAccessibilityHidden(view.modifiers) else { continue }

            // Check if the container's body has interactive children
            guard let body = view.callExpr.trailingClosure else { continue }
            let innerVisitor = ViewHierarchyVisitor.analyze(body)

            let hasInteractiveChild = innerVisitor.detectedViews.contains { child in
                Self.interactiveViewTypes.contains(child.viewType)
            }

            if hasInteractiveChild {
                diagnostics.append(makeDiagnostic(
                    message: ".accessibilityHidden(true) on a container hides all interactive children from VoiceOver, Voice Control, Full Keyboard Access, and Switch Control. Apply it only to individual decorative elements instead.",
                    node: view.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}
