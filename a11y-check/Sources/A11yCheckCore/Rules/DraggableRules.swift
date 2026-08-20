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

// MARK: - Draggable Missing Accessibility Action Rule

/// Flags SwiftUI views using the `.draggable()` or `.dropDestination()` modifier
/// without an `.accessibilityAction(named:)` alternative on the same modifier chain.
///
/// Drag-and-drop is inaccessible to VoiceOver, Switch Control, and Full Keyboard
/// Access users unless custom accessibility actions are provided. The correct pattern
/// is to add "Move Up" and "Move Down" (or equivalent) actions:
///
/// ```swift
/// ForEach(items) { item in
///     Text(item.name)
///         .draggable(item)
///         .accessibilityAction(named: "Move Up") { moveUp(item) }
///         .accessibilityAction(named: "Move Down") { moveDown(item) }
///         .accessibilityHint("Reorderable. Use actions to move.")
/// }
/// ```
///
/// Note: This rule targets the high-level `.draggable()` / `.dropDestination()` SwiftUI
/// API. The existing `gesture-missing-alternative` rule covers the lower-level
/// `.gesture(DragGesture())` API. This rule is emitted as a **warning** because the
/// accessibility actions may be defined in a parent view or container that static
/// analysis cannot see from this file alone.
///
/// WCAG 2.5.7 Dragging Movements (Level AA)
/// WCAG 2.1.1 Keyboard (Level A)
public struct DraggableMissingAccessibilityActionRule: A11yRule {
    public let id = "draggable-missing-accessibility-action"
    public let name = "Draggable Item Missing Accessibility Action Alternative"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.5.7", "2.1.1"]
    public let description = "Views using .draggable() or .dropDestination() must have .accessibilityAction(named:) alternatives (e.g. \"Move Up\", \"Move Down\") so VoiceOver, Switch Control, and Full Keyboard Access users can perform the same action without dragging."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let sourceText = context.sourceText
        guard sourceText.contains("draggable") || sourceText.contains("dropDestination") else {
            return []
        }

        let visitor = DraggableModifierVisitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)

        var diagnostics: [A11yDiagnostic] = []
        for call in visitor.draggableCalls {
            let chainText = findChainText(for: call.callExpr)
            if !chainText.contains("accessibilityAction") {
                let modName = call.modifierName
                diagnostics.append(makeDiagnostic(
                    message: ".\(modName)() without .accessibilityAction(named:) alternative. VoiceOver, Switch Control, and Full Keyboard Access users cannot perform drag operations. Add .accessibilityAction(named: \"Move Up\") { } and .accessibilityAction(named: \"Move Down\") { }, and .accessibilityHint(\"Reorderable. Use actions to move.\") (WCAG 2.5.7).",
                    node: call.reportNode,
                    context: context,
                    suggestion: "Add .accessibilityAction(named: \"Move Up\") { /* reorder up */ } and .accessibilityAction(named: \"Move Down\") { /* reorder down */ }"
                ))
            }
        }
        return diagnostics
    }

    private func findChainText(for callExpr: FunctionCallExprSyntax) -> String {
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

// MARK: - Visitor

private struct DraggableCall {
    let modifierName: String
    let callExpr: FunctionCallExprSyntax
    var reportNode: any SyntaxProtocol {
        if let member = callExpr.calledExpression.as(MemberAccessExprSyntax.self) {
            return member.period
        }
        return callExpr
    }
}

private class DraggableModifierVisitor: SyntaxVisitor {
    var draggableCalls: [DraggableCall] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) else {
            return .visitChildren
        }
        let name = memberAccess.declName.baseName.text
        if name == "draggable" || name == "dropDestination" {
            draggableCalls.append(DraggableCall(modifierName: name, callExpr: node))
        }
        return .visitChildren
    }
}
