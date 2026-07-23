import SwiftSyntax

/// Visitor that finds `.onTapGesture` usages and checks whether
/// the element also has `.accessibilityAddTraits(.isButton)`.
///
/// Also finds custom gesture modifiers that imply interactive behavior.
public final class GestureVisitor: SyntaxVisitor {

    /// A detected gesture usage with context about accessibility traits.
    public struct DetectedGesture {
        /// The modifier name (e.g. "onTapGesture", "onLongPressGesture").
        public let gestureName: String
        /// The function call expression for this gesture modifier.
        public let callExpr: FunctionCallExprSyntax
        /// Whether the chain also contains `.accessibilityAddTraits(.isButton)`.
        public let hasButtonTrait: Bool
        /// Whether the chain also contains `.accessibilityLabel(...)`.
        public let hasAccessibilityLabel: Bool
        /// Whether the gesture closure is a keyboard-dismiss pattern —
        /// e.g. `.onTapGesture { hideKeyboard() }` on a background view.
        /// These don't represent interactive UI controls and should not
        /// require `.accessibilityAddTraits(.isButton)`.
        public let isKeyboardDismiss: Bool

        /// Node positioned at the gesture modifier token rather than the
        /// base of the chain. Use for diagnostic reporting.
        public var reportNode: any SyntaxProtocol {
            if let memberAccess = callExpr.calledExpression.as(MemberAccessExprSyntax.self) {
                return memberAccess.period
            }
            return callExpr
        }
    }

    /// Gestures that imply the element is interactive.
    private static let interactiveGestures: Set<String> = [
        "onTapGesture",
        "onLongPressGesture",
    ]

    public private(set) var detectedGestures: [DetectedGesture] = []

    public init() {
        super.init(viewMode: .sourceAccurate)
    }

    public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) else {
            return .visitChildren
        }
        let name = memberAccess.declName.baseName.text
        guard Self.interactiveGestures.contains(name) else {
            return .visitChildren
        }

        // Walk up the modifier chain to find the root, then collect all modifiers
        let chainRoot = findChainRoot(for: ExprSyntax(node))
        let modifiers = ModifierCollector.collect(from: chainRoot)

        let hasButtonTrait = modifiers.modifiers(named: "accessibilityAddTraits").contains { mod in
            mod.arguments.contains { $0.text.contains("isButton") }
        }
        // Also check the older `.accessibility(addTraits:)` API
        let hasOldButtonTrait = modifiers.modifiers(named: "accessibility").contains { mod in
            mod.arguments.contains { $0.label == "addTraits" && $0.text.contains("isButton") }
        }

        let hasLabel = modifiers.hasModifier("accessibilityLabel")

        detectedGestures.append(DetectedGesture(
            gestureName: name,
            callExpr: node,
            hasButtonTrait: hasButtonTrait || hasOldButtonTrait,
            hasAccessibilityLabel: hasLabel,
            isKeyboardDismiss: Self.isKeyboardDismissGesture(node)
        ))

        return .visitChildren
    }

    /// Returns true when the closure body is a single keyboard-dismiss call:
    /// `hideKeyboard()`, `dismissKeyboard()`, `endEditing(...)`, `resignFirstResponder()`.
    private static func isKeyboardDismissGesture(_ node: FunctionCallExprSyntax) -> Bool {
        guard let closure = node.trailingClosure
                ?? node.arguments.first?.expression.as(ClosureExprSyntax.self),
              closure.statements.count == 1 else { return false }

        let text = closure.statements.description.lowercased()
        return ["hidekeyboard", "dismisskeyboard", "endediting", "resignfirstresponder"]
            .contains { text.contains($0) }
    }

    private func findChainRoot(for expr: ExprSyntax) -> ExprSyntax {
        var current = expr
        while let parent = current.parent {
            if let memberAccess = parent.as(MemberAccessExprSyntax.self) {
                if let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                    current = ExprSyntax(grandparent)
                    continue
                }
            }
            if let funcCall = parent.as(FunctionCallExprSyntax.self),
               let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
               memberAccess.base?.id == current.id {
                current = ExprSyntax(funcCall)
                continue
            }
            break
        }
        return current
    }
}

