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
/// when they activate the element (e.g. "Double tap to add to cart").
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
                message: "Interactive element with a complex gesture is missing .accessibilityHint(). VoiceOver users won't know what action is available. Add .accessibilityHint(\"...\") to describe what happens (e.g. \"Double tap and hold to reorder\").",
                node: node,
                context: context,
                suggestion: "Add .accessibilityHint(\"Describe the action\")"
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
