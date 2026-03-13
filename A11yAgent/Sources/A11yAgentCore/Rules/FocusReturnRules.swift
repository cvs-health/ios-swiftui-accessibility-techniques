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
/// WCAG 2.4.3 Focus Order, 2.1.2 No Keyboard Trap
/// Reference: Documentation/Sheets.md, Alerts.md, ConfirmationDialogs.md, Popovers.md, FocusManagement.md
public struct SheetFocusReturnRule: A11yRule {
    public let id = "sheet-focus-return"
    public let name = "Return Focus When Sheet/Dialog Dismisses"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["2.4.3", "2.1.2"]
    public let description = "When using .sheet(), .fullScreenCover(), .popover(), .alert(), or .confirmationDialog(), return focus by setting @AccessibilityFocusState (or @FocusState) when the presentation closes so VoiceOver/keyboard focus returns to the trigger."

    public init() {}

    /// Modifiers that take onDismiss — we require onDismiss to set focus.
    private static let onDismissModifiers = ["sheet", "fullScreenCover"]
    /// Modifiers with no onDismiss — we require focus state and that their content (buttons / popover body) sets focus.
    private static let contentFocusModifiers = ["alert", "confirmationDialog", "popover"]

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
                diagnostics.append(makeDiagnostic(
                    message: "\(modName)(…) has onDismiss but no @FocusState or @AccessibilityFocusState to return focus. Add a focus state and set it in onDismiss so VoiceOver/keyboard focus returns when the \(modName) closes.",
                    node: mod.reportNode,
                    context: context,
                    suggestion: "Add @AccessibilityFocusState var and set it in onDismiss"
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
                diagnostics.append(makeDiagnostic(
                    message: "\(modName)(…) should return focus when closed. Add @AccessibilityFocusState (or @FocusState) and set it in a button action or in the \(modName) content so VoiceOver/keyboard focus returns to the trigger.",
                    node: mod.reportNode,
                    context: context,
                    suggestion: "Add @AccessibilityFocusState var and set it when the \(modName) closes"
                ))
                continue
            }
            if !anyClosureInNodeSetsFocus(Syntax(mod.callExpr), focusVarNames: focusStateVars) {
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
    private func anyClosureInNodeSetsFocus(_ node: Syntax, focusVarNames: [String]) -> Bool {
        let fullText = node.trimmedDescription
        for varName in focusVarNames {
            if fullText.contains("\(varName) =") || fullText.contains("\(varName)=") {
                return true
            }
        }
        return false
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
