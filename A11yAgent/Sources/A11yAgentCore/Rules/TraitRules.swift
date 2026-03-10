import SwiftSyntax

// MARK: - Tap Gesture Missing Button Trait Rule

/// Flags `.onTapGesture` modifiers on views that don't have
/// `.accessibilityAddTraits(.isButton)` — VoiceOver won't announce
/// the element as interactive.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: AccessibilityTraitsView.swift — bad example has onTapGesture without .isButton
public struct TapGestureMissingButtonTraitRule: A11yRule {
    public let id = "tap-gesture-missing-button-trait"
    public let name = "Tap Gesture Missing .isButton Trait"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["4.1.2"]
    public let description = "Views with .onTapGesture must have .accessibilityAddTraits(.isButton) so VoiceOver announces them as interactive."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let gestureVisitor = GestureVisitor()
        gestureVisitor.walk(syntax)

        var diagnostics: [A11yDiagnostic] = []

        for gesture in gestureVisitor.detectedGestures {
            if gesture.gestureName == "onTapGesture" && !gesture.hasButtonTrait {
                diagnostics.append(makeDiagnostic(
                    message: ".onTapGesture without .accessibilityAddTraits(.isButton). VoiceOver users won't know this element is tappable.",
                    node: gesture.callExpr,
                    context: context
                ))
            }
        }
        return diagnostics
    }
}
