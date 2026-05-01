import SwiftSyntax

// MARK: - Custom Gesture Missing Accessibility Action Rule

/// Flags complex gestures (long press, drag, rotation, magnification) that
/// don't have an `.accessibilityAction` alternative. These gestures are
/// inaccessible to VoiceOver, Switch Control, and Voice Control users.
/// A visible single-tap alternative (e.g. a Button) should also be provided
/// so that touch users who cannot perform the gesture can still trigger the action.
///
/// WCAG 2.1.1 Keyboard (all functionality must be operable via keyboard/assistive tech)
/// WCAG 2.5.1 Pointer Gestures (multipoint or path-based gestures need single-pointer alternatives)
public struct CustomGestureMissingAlternativeRule: A11yRule {
    public let id = "gesture-missing-alternative"
    public let name = "Complex Gesture Missing Accessibility Alternative"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.1.1", "2.5.1"]
    public let description = "Complex gestures (long press, drag, rotation, magnification) need an .accessibilityAction() alternative for VoiceOver users and a visible single-tap alternative (e.g. a Button) so touch users who cannot perform the gesture can still trigger the action."

    public init() {}

    /// Gesture modifiers that need accessibility alternatives.
    private static let complexGestures: Set<String> = [
        "onLongPressGesture",
        "gesture",          // catches .gesture(DragGesture()), .gesture(RotationGesture()), etc.
    ]

    /// Gesture types used inside .gesture() that need alternatives.
    private static let complexGestureTypes: Set<String> = [
        "DragGesture",
        "RotationGesture",
        "MagnificationGesture",
        "LongPressGesture",
        "SpatialTapGesture",
        "SequenceGesture",
        "SimultaneousGesture",
        "ExclusiveGesture",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let gestureVisitor = GestureVisitor()
        gestureVisitor.walk(syntax)
        var diagnostics: [A11yDiagnostic] = []

        // Check onLongPressGesture
        for gesture in gestureVisitor.detectedGestures {
            if gesture.gestureName == "onLongPressGesture" {
                // Walk up to find if chain has .accessibilityAction
                let chainText = findChainText(for: gesture.callExpr)
                if !chainText.contains("accessibilityAction") {
                    diagnostics.append(makeDiagnostic(
                        message: ".onLongPressGesture without .accessibilityAction() alternative. Provide .accessibilityAction() for VoiceOver users and a visible single-tap Button alternative for touch users who cannot perform the gesture.",
                        node: gesture.reportNode,
                        context: context,
                        suggestion: "Add .accessibilityAction(named: \"Long Press\") { /* action */ } and a visible Button alternative"
                    ))
                }
            }
        }

        // Check .gesture(DragGesture()/RotationGesture()/etc.)
        let collector = ModifierCollector.collect(from: syntax)
        for mod in collector.modifiers(named: "gesture") {
            let argText = mod.arguments.first?.text ?? ""
            let isComplex = Self.complexGestureTypes.contains { argText.contains($0) }
            guard isComplex else { continue }

            let chainText = findChainText(for: mod.callExpr)
            if !chainText.contains("accessibilityAction") &&
               !chainText.contains("accessibilityAdjustableAction") {
                let gestureType = Self.complexGestureTypes.first { argText.contains($0) } ?? "custom gesture"
                diagnostics.append(makeDiagnostic(
                    message: ".gesture(\(gestureType)()) without .accessibilityAction() alternative. Provide .accessibilityAction() for VoiceOver users and a visible single-tap Button alternative for touch users who cannot perform this gesture.",
                    node: mod.reportNode,
                    context: context,
                    suggestion: "Add .accessibilityAction(named: \"Perform Action\") { /* action */ } and a visible Button alternative"
                ))
            }
        }

        return diagnostics
    }

    private func findChainText(for callExpr: FunctionCallExprSyntax) -> String {
        // Walk up to find the full modifier chain text
        var current: Syntax = Syntax(callExpr)
        while let parent = current.parent {
            if parent.as(FunctionCallExprSyntax.self) != nil {
                current = parent
            } else if parent.as(MemberAccessExprSyntax.self) != nil {
                current = parent
            } else {
                break
            }
        }
        return current.trimmedDescription
    }
}
