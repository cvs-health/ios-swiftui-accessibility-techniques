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

// MARK: - Input Triggers Context Change Rule

/// Flags `.onChange` modifiers on input controls (Picker, Toggle, Slider, DatePicker,
/// Stepper) whose closure body calls `dismiss()` or mutates a navigation path,
/// causing an unexpected context change without user initiation.
///
/// WCAG 3.2.2 On Input requires that changing a UI component's value does not
/// automatically cause a change of context unless the user has been advised of that
/// behaviour in advance. A Picker that navigates away when an option is selected,
/// or a Toggle that dismisses the sheet it's on, disorients VoiceOver users and
/// users with cognitive disabilities.
///
/// Compliant pattern — use a Button to confirm before navigating:
/// ```swift
/// Picker("Sort by", selection: $sortOrder) { ... }
/// Button("Apply") { dismiss() }   // user-initiated dismiss
/// ```
///
/// This rule fires as a **warning** because the dismiss or navigation call might be
/// intentional with an appropriate prior user notice, or the control hierarchy may
/// not be identifiable from the call site alone. Review manually.
///
/// WCAG 3.2.2 On Input (Level A)
public struct InputTriggersContextChangeRule: A11yRule {
    public let id = "input-triggers-context-change"
    public let name = "Input Control Triggers Unexpected Context Change"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["3.2.2"]
    public let description = "Changing the value of a Picker, Toggle, Slider, DatePicker, or Stepper should not automatically dismiss a screen or navigate away. Move navigation to a confirm Button so users control when a context change occurs."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        guard context.sourceText.contains("onChange") else { return [] }

        let visitor = InputContextChangeVisitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)

        return visitor.violations.map { violation in
            makeDiagnostic(
                message: ".onChange on \(violation.controlType) calls \(violation.triggerDescription). Changing a control's value should not automatically cause a context change — users expect to control when navigation or dismissal happens. Move the \(violation.triggerDescription) to a confirm Button or inform the user before the change occurs (WCAG 3.2.2).",
                node: violation.reportNode,
                context: context,
                suggestion: "Move dismiss() or navigation into a separate confirm Button action instead of the .onChange closure"
            )
        }
    }
}

// MARK: - Visitor

private struct ContextChangeViolation {
    let controlType: String
    let triggerDescription: String
    let reportNode: FunctionCallExprSyntax
}

private class InputContextChangeVisitor: SyntaxVisitor {
    var violations: [ContextChangeViolation] = []

    private static let inputControlTypes: Set<String> = [
        "Picker", "Toggle", "Slider", "DatePicker", "Stepper",
    ]

    // Closure content patterns that indicate a context change.
    // Each tuple is (substring to find, human-readable label).
    private static let contextChangeTriggers: [(pattern: String, description: String)] = [
        ("dismiss()",                "dismiss()"),
        ("path.append",              "navigation path append"),
        ("path.removeLast",          "navigation path removal"),
        ("navigationPath.append",    "navigation path append"),
        ("navigationPath.removeLast","navigation path removal"),
        ("isPresented = false",      "isPresented = false"),
        ("isPresented = true",       "isPresented = true"),
    ]

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.text == "onChange" else {
            return .visitChildren
        }

        // Extract the closure body text (trailing or inline)
        let closureText: String
        if let trailing = node.trailingClosure {
            closureText = trailing.trimmedDescription
        } else if let firstClosure = node.arguments.first(where: {
            $0.expression.as(ClosureExprSyntax.self) != nil
        }) {
            closureText = firstClosure.expression.trimmedDescription
        } else {
            return .visitChildren
        }

        // Check for context-changing calls in the closure
        guard let trigger = Self.contextChangeTriggers.first(where: {
            closureText.contains($0.pattern)
        }) else {
            return .visitChildren
        }

        // Walk down the modifier chain to identify the input control type
        guard let controlType = findInputControlType(for: node) else {
            return .visitChildren
        }

        violations.append(ContextChangeViolation(
            controlType: controlType,
            triggerDescription: trigger.description,
            reportNode: node
        ))

        return .visitChildren
    }

    /// Walks down the modifier chain base to find a Picker/Toggle/Slider/etc.
    private func findInputControlType(for onChange: FunctionCallExprSyntax) -> String? {
        guard let memberAccess = onChange.calledExpression.as(MemberAccessExprSyntax.self),
              let base = memberAccess.base else {
            return nil
        }
        let chainText = base.trimmedDescription
        for control in Self.inputControlTypes {
            if chainText.contains(control) {
                return control
            }
        }
        return nil
    }
}
