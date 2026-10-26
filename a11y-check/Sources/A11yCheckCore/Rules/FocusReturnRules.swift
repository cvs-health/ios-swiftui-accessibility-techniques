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

// MARK: - Presentation Focus Return Rule

/// Flags presentation modifiers (sheet, fullScreenCover, popover, alert, confirmationDialog) that
/// allow focus return but do not return focus. Per project docs: VoiceOver focus must move back to
/// the trigger when the sheet/dialog/popover/alert closes. Use AccessibilityFocusState and set it
/// when dismissing.
///
/// - Sheet/FullScreenCover: require onDismiss and that it sets focus (or skip if no onDismiss).
/// - Alert/ConfirmationDialog: require @AccessibilityFocusState and that button actions set it.
/// - Popover: require @AccessibilityFocusState and that popover content (e.g. Dismiss button) sets it.
///
/// Measured at ~98% actionable (114 of 116) on the flagship app, which is why it ships as an
/// error rather than a warning.
///
/// The one false-positive mode left is focus restored through a Combine indirection: a helper
/// in the dismiss path calls `restore()` on a trigger object that sends on a
/// `PassthroughSubject`, and the `.onReceive` that actually assigns the focus state lives in
/// whichever view the trigger was handed to through the environment. Focus does return, but
/// nothing in this file says so, and following it means reading another file. Suppress those
/// with `// a11y-check:disable-next-line sheet-focus-return`.
///
/// WCAG 2.4.3 Focus Order, 2.1.2 No Keyboard Trap
/// Reference: Documentation/Sheets.md, Alerts.md, ConfirmationDialogs.md, Popovers.md, FocusManagement.md
public struct SheetFocusReturnRule: A11yRule {
    public let id = "sheet-focus-return"
    public let name = "Return Focus When Sheet/Dialog Dismisses"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.4.3", "2.1.2"]
    public let description = "When using .sheet(), .fullScreenCover(), .popover(), .alert(), or .confirmationDialog(), return focus by setting @AccessibilityFocusState (or @FocusState) when the presentation closes so VoiceOver/keyboard focus returns to the trigger."

    public init() {}

    /// Modifiers that take onDismiss — we require onDismiss to set focus.
    private static let onDismissModifiers = ["sheet", "fullScreenCover"]
    /// Modifiers with no onDismiss — we require focus state and that their content (buttons /
    /// popover body) sets focus.
    ///
    /// `contextMenu` is here because a context menu closing is the same focus problem as a
    /// dialog closing, and testers report it as often: pick an item and VoiceOver focus jumps
    /// to the top of the screen instead of the control that opened the menu.
    ///
    /// `Menu` and `Picker` are *views*, not modifiers, so they are out of this rule's reach as
    /// written — dismissing either has the same defect and would need a view-based check.
    private static let contentFocusModifiers = [
        "alert", "confirmationDialog", "popover", "contextMenu",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for modName in Self.onDismissModifiers {
            diagnostics.append(contentsOf: checkOnDismissModifier(collector: collector, modName: modName, context: context))
        }
        for modName in Self.contentFocusModifiers {
            diagnostics.append(contentsOf: checkContentFocusModifier(collector: collector, modName: modName, context: context))
        }
        return diagnostics
    }

    // MARK: - Sheet / fullScreenCover (onDismiss must set focus)

    private func checkOnDismissModifier(collector: ModifierCollector, modName: String, context: RuleContext) -> [A11yDiagnostic] {
        var diagnostics: [A11yDiagnostic] = []
        for mod in collector.modifiers(named: modName) {
            guard let onDismissArg = mod.callExpr.arguments.first(where: { $0.label?.text == "onDismiss" }) else {
                continue
            }
            guard let structDecl = findEnclosingStructOrClass(Syntax(mod.callExpr)) else { continue }

            let focusStateVars = focusStateVariableNames(in: structDecl)
            if focusStateVars.isEmpty {
                let inViewModifier = conformsToViewModifier(structDecl)
                diagnostics.append(makeDiagnostic(
                    message: inViewModifier
                        ? "\(modName)(…) has onDismiss but nothing returns focus. This is a ViewModifier, so the control that opened the \(modName) belongs to the caller — a focus state declared here would have nothing to focus. Take the caller's focus binding as a parameter and set it in onDismiss."
                        : "\(modName)(…) has onDismiss but no @FocusState or @AccessibilityFocusState to return focus. Add a focus state and set it in onDismiss so VoiceOver/keyboard focus returns when the \(modName) closes.",
                    node: mod.reportNode,
                    context: context,
                    suggestion: inViewModifier
                        ? "Accept an AccessibilityFocusState<…>.Binding parameter and set it in onDismiss"
                        : "Add @AccessibilityFocusState var and set it in onDismiss"
                ))
                continue
            }
            if !onDismissSetsAnyFocusState(onDismissExpr: onDismissArg.expression, focusVarNames: focusStateVars, in: structDecl) {
                diagnostics.append(makeDiagnostic(
                    message: "\(modName)(…) has onDismiss but does not set focus in onDismiss. Set your @AccessibilityFocusState (or @FocusState) in onDismiss so focus returns when the \(modName) closes.",
                    node: mod.reportNode,
                    context: context,
                    suggestion: "Set your @AccessibilityFocusState variable in the onDismiss closure"
                ))
            }
        }
        return diagnostics
    }

    // MARK: - Alert / confirmationDialog / popover (content or buttons must set focus)

    private func checkContentFocusModifier(collector: ModifierCollector, modName: String, context: RuleContext) -> [A11yDiagnostic] {
        var diagnostics: [A11yDiagnostic] = []
        for mod in collector.modifiers(named: modName) {
            guard let structDecl = findEnclosingStructOrClass(Syntax(mod.callExpr)) else { continue }
            let focusStateVars = focusStateVariableNames(in: structDecl)
            if focusStateVars.isEmpty {
                let inViewModifier = conformsToViewModifier(structDecl)
                diagnostics.append(makeDiagnostic(
                    message: inViewModifier
                        ? "\(modName)(…) should return focus when closed. This is a ViewModifier, so the control that opened the \(modName) belongs to the caller — a focus state declared here would have nothing to focus. Take the caller's focus binding as a parameter and set it in the button action."
                        : "\(modName)(…) should return focus when closed. Add @AccessibilityFocusState (or @FocusState) and set it in a button action or in the \(modName) content so VoiceOver/keyboard focus returns to the trigger.",
                    node: mod.reportNode,
                    context: context,
                    suggestion: inViewModifier
                        ? "Accept an AccessibilityFocusState<…>.Binding parameter and set it in the button action"
                        : "Add @AccessibilityFocusState var and set it when the \(modName) closes"
                ))
                continue
            }
            let focusHelpers = focusSettingMethodNames(in: structDecl, focusVarNames: focusStateVars)
            if !anyClosureInNodeSetsFocus(
                Syntax(mod.callExpr),
                focusVarNames: focusStateVars,
                focusSettingMethods: focusHelpers
            ) {
                diagnostics.append(makeDiagnostic(
                    message: "\(modName)(…) has no focus return. Set your @AccessibilityFocusState (or @FocusState) in a button action or in the \(modName) content when closing so focus returns to the trigger.",
                    node: mod.reportNode,
                    context: context,
                    suggestion: "Set your @AccessibilityFocusState variable in a button action"
                ))
            }
        }
        return diagnostics
    }

    /// True if any closure inside the modifier call (e.g. alert buttons, popover content) contains an assignment to one of the focus state variables.
    private func anyClosureInNodeSetsFocus(
        _ node: Syntax,
        focusVarNames: [String],
        focusSettingMethods: Set<String> = []
    ) -> Bool {
        let fullText = node.trimmedDescription
        for varName in focusVarNames {
            if fullText.contains("\(varName) =") || fullText.contains("\(varName)=") {
                return true
            }
        }
        // Restoring focus through a helper is normal: an alert's Cancel action calls
        // `restoreAccessibilityFocus()` and that method does the assignment. Looking only for
        // the assignment inside the closure reports code that already does the right thing —
        // which is how the rule's single most precisely-evidenced finding on a real app turned
        // out to be a false positive.
        for method in focusSettingMethods {
            if fullText.contains("\(method)(") { return true }
        }
        return false
    }

    /// Names of methods on this type whose body assigns one of the focus variables.
    ///
    /// One level deep by design: a helper that assigns the variable counts, a helper that calls
    /// another helper does not. Going deeper would mean resolving a call graph for a check whose
    /// whole purpose is a cheap source read, and one level covers the idiom.
    private func focusSettingMethodNames(
        in decl: DeclSyntaxProtocol,
        focusVarNames: [String]
    ) -> Set<String> {
        guard !focusVarNames.isEmpty else { return [] }
        let memberBlock: MemberBlockSyntax? =
            decl.as(StructDeclSyntax.self)?.memberBlock
            ?? decl.as(ClassDeclSyntax.self)?.memberBlock
            ?? decl.as(ExtensionDeclSyntax.self)?.memberBlock
        guard let block = memberBlock else { return [] }

        var names: Set<String> = []
        for member in block.members {
            guard let fn = member.decl.as(FunctionDeclSyntax.self), let body = fn.body else { continue }
            let text = body.trimmedDescription
            if focusVarNames.contains(where: { text.contains("\($0) =") || text.contains("\($0)=") }) {
                names.insert(fn.name.text)
            }
        }
        return names
    }

    /// Walk up from a node to find the enclosing StructDecl or ClassDecl.
    private func findEnclosingStructOrClass(_ node: Syntax) -> DeclSyntaxProtocol? {
        var current: Syntax? = node.parent
        while let n = current {
            if let s = n.as(StructDeclSyntax.self) { return s }
            if let c = n.as(ClassDeclSyntax.self) { return c }
            current = n.parent
        }
        return nil
    }

    /// Whether the declaration conforms to `ViewModifier`.
    ///
    /// It changes what the author should do, so it changes the advice. A `ViewModifier`
    /// attaches its alert to content it does not own, so the control that opened the alert is
    /// in the *caller*. Declaring an `@AccessibilityFocusState` inside the modifier gives it
    /// nothing to focus — the property would sit there unused and the defect would survive the
    /// "fix". The modifier has to be handed the caller's focus binding instead.
    private func conformsToViewModifier(_ decl: DeclSyntaxProtocol) -> Bool {
        let clause: InheritanceClauseSyntax?
        if let s = decl.as(StructDeclSyntax.self) {
            clause = s.inheritanceClause
        } else if let c = decl.as(ClassDeclSyntax.self) {
            clause = c.inheritanceClause
        } else {
            clause = nil
        }
        guard let clause else { return false }
        return clause.inheritedTypes.contains { $0.type.trimmedDescription == "ViewModifier" }
    }

    /// Collect variable names that are declared with @FocusState or @AccessibilityFocusState in the given struct/class.
    private func focusStateVariableNames(in decl: DeclSyntaxProtocol) -> [String] {
        let memberBlock: MemberBlockSyntax?
        if let s = decl.as(StructDeclSyntax.self) {
            memberBlock = s.memberBlock
        } else if let c = decl.as(ClassDeclSyntax.self) {
            memberBlock = c.memberBlock
        } else {
            return []
        }
        guard let block = memberBlock else { return [] }

        var names: [String] = []
        for member in block.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
            let attrs = varDecl.attributes.description
            guard attrs.contains("FocusState") || attrs.contains("AccessibilityFocusState") else { continue }
            for binding in varDecl.bindings {
                var patternText = binding.pattern.trimmedDescription
                if let colon = patternText.firstIndex(of: ":") {
                    patternText = String(patternText[..<colon]).trimmingCharacters(in: .whitespaces)
                }
                if !patternText.isEmpty, patternText.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
                    names.append(patternText)
                }
            }
        }
        return names
    }

    /// True if the onDismiss expression (closure or referenced function) sets any of the focus state variables.
    private func onDismissSetsAnyFocusState(onDismissExpr: ExprSyntax, focusVarNames: [String], in structDecl: DeclSyntaxProtocol) -> Bool {
        let bodyText: String
        if let closure = onDismissExpr.as(ClosureExprSyntax.self) {
            bodyText = closure.trimmedDescription
        } else if let ref = onDismissExpr.as(DeclReferenceExprSyntax.self) {
            let funcName = ref.baseName.text
            bodyText = findFunctionBody(named: funcName, in: structDecl) ?? ""
        } else {
            return false
        }
        for varName in focusVarNames {
            if bodyText.contains("\(varName) =") || bodyText.contains("\(varName)=") {
                return true
            }
        }
        // `onDismiss: { restoreFocus() }` — the closure delegates to a helper that assigns the
        // variable. Same shape the content path handles.
        for method in focusSettingMethodNames(in: structDecl, focusVarNames: focusVarNames) {
            if bodyText.contains("\(method)(") { return true }
        }
        return false
    }

    /// Find the body text of a function with the given name in the struct/class.
    private func findFunctionBody(named name: String, in decl: DeclSyntaxProtocol) -> String? {
        let memberBlock: MemberBlockSyntax?
        if let s = decl.as(StructDeclSyntax.self) {
            memberBlock = s.memberBlock
        } else if let c = decl.as(ClassDeclSyntax.self) {
            memberBlock = c.memberBlock
        } else {
            return nil
        }
        guard let block = memberBlock else { return nil }

        for member in block.members {
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else { continue }
            if funcDecl.name.text == name, let body = funcDecl.body {
                return body.trimmedDescription
            }
        }
        return nil
    }
}
