import SwiftSyntax

/// Collects all SwiftUI accessibility-related modifiers applied to view expressions.
///
/// Usage: Walk a syntax node and then query `modifiers(for:)` to find what accessibility
/// modifiers are chained on a given expression.
public final class ModifierCollector: SyntaxVisitor {

    /// A recognized accessibility modifier with its argument info.
    public struct CollectedModifier {
        /// The modifier name, e.g. "accessibilityLabel", "font", "frame", etc.
        public let name: String
        /// The full function call expression node for this modifier.
        public let callExpr: FunctionCallExprSyntax
        /// The string value of the first argument, if it's a string literal.
        public let firstStringArgument: String?
        /// All argument labels and their expression text.
        public let arguments: [(label: String?, text: String)]

        /// Node positioned at the modifier itself (the `.` token) rather than
        /// at the base of the chain. Use this for diagnostic reporting so the
        /// line/column points to the modifier, not the view it's applied to.
        public var reportNode: any SyntaxProtocol {
            if let memberAccess = callExpr.calledExpression.as(MemberAccessExprSyntax.self) {
                return memberAccess.period
            }
            return callExpr
        }
    }

    /// All collected modifiers in order of appearance.
    public private(set) var allModifiers: [CollectedModifier] = []

    /// Set of modifier names we care about.
    private static let trackedModifiers: Set<String> = [
        // Accessibility
        "accessibilityLabel",
        "accessibilityHint",
        "accessibilityValue",
        "accessibilityHidden",
        "accessibilityAddTraits",
        "accessibilityRemoveTraits",
        "accessibilityElement",
        "accessibilityIdentifier",
        "accessibilityAction",
        "accessibilityLanguage",
        "accessibilityHeading",
        "accessibilitySortPriority",
        "accessibilityRepresentation",
        "accessibilityRespondsToUserInteraction",
        "accessibilityInputLabels",
        "accessibilityFocused",
        // Older API
        "accessibility",
        // Layout & appearance
        "font",
        "frame",
        "lineLimit",
        "navigationTitle",
        "disabled",
        "foregroundColor",
        "foregroundStyle",
        "background",
        "tint",
        "opacity",
        "labelsHidden",
        "underline",
        // Interactions
        "onTapGesture",
        "sheet",
        "fullScreenCover",
        "popover",
        "alert",
        "confirmationDialog",
    ]

    public init() {
        super.init(viewMode: .sourceAccurate)
    }

    public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Check if this is a member access call like `.accessibilityLabel("text")`
        if let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) {
            let name = memberAccess.declName.baseName.text
            if Self.trackedModifiers.contains(name) {
                let args: [(label: String?, text: String)] = node.arguments.map { arg in
                    (label: arg.label?.text, text: arg.expression.trimmedDescription)
                }
                let firstString = extractStringLiteral(from: node.arguments.first?.expression)
                allModifiers.append(CollectedModifier(
                    name: name,
                    callExpr: node,
                    firstStringArgument: firstString,
                    arguments: args
                ))
            }
        }
        return .visitChildren
    }

    /// Extract a string literal value from an expression, if it is one.
    private func extractStringLiteral(from expr: ExprSyntax?) -> String? {
        guard let expr = expr else { return nil }
        if let stringLiteral = expr.as(StringLiteralExprSyntax.self) {
            return stringLiteral.segments.map { segment -> String in
                if let text = segment.as(StringSegmentSyntax.self) {
                    return text.content.text
                }
                return ""
            }.joined()
        }
        return nil
    }
}

// MARK: - Convenience queries

extension ModifierCollector {
    /// Check whether any modifier with the given name exists in the collected set.
    public func hasModifier(_ name: String) -> Bool {
        allModifiers.contains { $0.name == name }
    }

    /// Get all modifiers with a given name.
    public func modifiers(named name: String) -> [CollectedModifier] {
        allModifiers.filter { $0.name == name }
    }

    /// Collect modifiers from a specific syntax subtree.
    public static func collect(from node: some SyntaxProtocol) -> ModifierCollector {
        let collector = ModifierCollector()
        collector.walk(node)
        return collector
    }
}
