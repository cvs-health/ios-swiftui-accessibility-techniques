/*
   Copyright 2026 CVS Health and/or one of its affiliates

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import SwiftSyntax

/// Flags interactive elements with complex or non-obvious actions that lack
/// an `.accessibilityHint()`. Hints tell VoiceOver users what will happen
/// when they activate the element (e.g. "Adds item to cart").
///
/// WCAG 3.3.2 Labels or Instructions (Level A)
public struct MissingAccessibilityHintRule: A11yRule {
    public let id = "missing-accessibility-hint"
    public let name = "Complex Action Missing Accessibility Hint"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["3.3.2"]
    public let description = "Interactive elements with complex or non-obvious actions should have .accessibilityHint() so VoiceOver users understand what will happen when they activate the element."

    public init() {}

    private static let gestureModifiers: Set<String> = [
        "onLongPressGesture",
        "onDrag",
        "onDrop",
        "swipeActions",
        "contextMenu",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        var diagnostics: [A11yDiagnostic] = []
        let sourceText = context.sourceText

        guard sourceText.contains("onLongPressGesture") ||
              sourceText.contains("onDrag") ||
              sourceText.contains("onDrop") ||
              sourceText.contains("swipeActions") ||
              sourceText.contains("contextMenu") ||
              sourceText.contains("DragGesture") ||
              sourceText.contains("LongPressGesture") else {
            return []
        }

        let visitor = HintCheckVisitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)

        for node in visitor.elementsNeedingHint {
            diagnostics.append(makeDiagnostic(
                message: "Interactive element with a complex gesture is missing .accessibilityHint(). VoiceOver users won't know what action is available. Add .accessibilityHint(\"...\") describing what happens, not how to interact (e.g. \"Reorders the item\" not \"Double tap and hold to reorder\").",
                node: node,
                context: context,
                suggestion: "Add .accessibilityHint(\"Describes what happens\")"
            ))
        }

        return diagnostics
    }
}

private class HintCheckVisitor: SyntaxVisitor {
    var elementsNeedingHint: [SyntaxProtocol] = []

    private static let complexGestures: Set<String> = [
        "onLongPressGesture",
        "onDrag",
        "onDrop",
        "swipeActions",
        "contextMenu",
    ]

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let member = node.calledExpression.as(MemberAccessExprSyntax.self),
              Self.complexGestures.contains(member.declName.baseName.text) else {
            return .visitChildren
        }

        var root: ExprSyntax = ExprSyntax(node)
        while let parent = root.parent {
            if let funcCall = parent.as(FunctionCallExprSyntax.self),
               let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
               memberAccess.base?.id == root.id {
                root = ExprSyntax(funcCall)
                continue
            }
            if let memberAccess = parent.as(MemberAccessExprSyntax.self),
               let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                root = ExprSyntax(grandparent)
                continue
            }
            break
        }

        let chainText = root.trimmedDescription
        if !chainText.contains("accessibilityHint") {
            elementsNeedingHint.append(node)
        }

        return .visitChildren
    }

    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        guard node.declName.baseName.text == "gesture" else {
            return .visitChildren
        }

        if let parent = node.parent?.as(FunctionCallExprSyntax.self) {
            let argText = parent.arguments.description + (parent.trailingClosure?.description ?? "")
            if argText.contains("DragGesture") || argText.contains("LongPressGesture") {
                var root: ExprSyntax = ExprSyntax(parent)
                while let p = root.parent {
                    if let funcCall = p.as(FunctionCallExprSyntax.self),
                       let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
                       memberAccess.base?.id == root.id {
                        root = ExprSyntax(funcCall)
                        continue
                    }
                    if let memberAccess = p.as(MemberAccessExprSyntax.self),
                       let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                        root = ExprSyntax(grandparent)
                        continue
                    }
                    break
                }

                let chainText = root.trimmedDescription
                if !chainText.contains("accessibilityHint") {
                    elementsNeedingHint.append(parent)
                }
            }
        }

        return .visitChildren
    }
}

// MARK: - Bad Hint Content Rule

/// Flags `.accessibilityHint()` values that describe HOW to interact
/// instead of WHAT happens. VoiceOver already announces the interaction
/// method (e.g. "double tap to activate"), so hints like "Double tap to
/// add to cart" are redundant. Hints should use third-person declarative
/// form: "Adds item to cart", "Opens settings", "Deletes the message".
///
/// Apple HIG: "Don't include the action type... describe only the result."
public struct BadHintContentRule: A11yRule {
    public let id = "hint-describes-action-method"
    public let name = "Accessibility Hint Describes Interaction Method"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.minor
    public let wcagCriteria = ["3.3.2"]
    public let description = "Accessibility hints should describe what happens, not how to interact. VoiceOver already tells users the gesture (e.g. \"double tap to activate\"). Use third-person form like \"Adds item to cart\" instead of \"Double tap to add to cart\"."

    public init() {}

    private static let badPrefixes: [String] = [
        "double tap",
        "double-tap",
        "tap to",
        "tap and hold",
        "press to",
        "press and hold",
        "long press",
        "long-press",
        "click to",
        "click and",
        "swipe to",
        "swipe left",
        "swipe right",
        "swipe up",
        "swipe down",
        "drag to",
        "drag and",
        "pinch to",
        "rotate to",
        "shake to",
        "triple tap",
        "triple-tap",
        "two finger",
        "two-finger",
        "three finger",
        "three-finger",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        guard context.sourceText.contains("accessibilityHint") else { return [] }

        var diagnostics: [A11yDiagnostic] = []
        let collector = ModifierCollector.collect(from: syntax)

        for mod in collector.modifiers(named: "accessibilityHint") {
            guard let hintText = mod.firstStringArgument else { continue }
            let lower = hintText.lowercased().trimmingCharacters(in: .whitespaces)

            for prefix in Self.badPrefixes {
                if lower.hasPrefix(prefix) {
                    diagnostics.append(makeDiagnostic(
                        message: "Accessibility hint \"\(hintText)\" describes how to interact, not what happens. VoiceOver already announces the gesture. Rewrite in third-person declarative form (e.g. \"Adds item to cart\" instead of \"Double tap to add to cart\").",
                        node: mod.reportNode,
                        context: context,
                        suggestion: "Rewrite hint to describe the result, not the gesture"
                    ))
                    break
                }
            }
        }

        return diagnostics
    }
}
