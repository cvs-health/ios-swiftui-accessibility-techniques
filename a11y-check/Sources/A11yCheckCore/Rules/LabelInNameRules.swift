import SwiftSyntax

// MARK: - Label in Name Rule

/// Flags views where the accessible name (accessibilityLabel) does not contain
/// the visible text label, violating WCAG 2.5.3 Label in Name.
///
/// WCAG 2.5.3 Label in Name
/// The accessible name must contain the visible text label so that speech input
/// users can activate controls by speaking the text they see on screen.
public struct LabelInNameRule: A11yRule {
    public let id = "label-in-name"
    public let name = "Label in Name"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.5.3"]
    public let description = "The accessible name (.accessibilityLabel) must begin with the visible text label so Voice Control users can activate the control by speaking what they see on screen. WCAG 2.5.3: 'the accessible name is identical to or begins with the same sequence of characters as the visible text label.'"

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        let viewTypes = ["Button", "Text", "Label"]

        diagnostics.append(contentsOf: checkAdjacentLabels(visitor: visitor, syntax: syntax, context: context))

        for viewType in viewTypes {
            for view in visitor.views(ofType: viewType) {
                // Skip views with accessibilityHidden(true)
                if view.modifiers.modifiers(named: "accessibilityHidden").first?.firstStringArgument == "true" {
                    continue
                }

                // Get visible text
                guard let visibleText = view.firstStringArgument, !visibleText.isEmpty else {
                    continue
                }

                // Get accessible name from accessibilityLabel modifier
                guard let labelModifier = view.modifiers.modifiers(named: "accessibilityLabel").first,
                      let accessibleName = labelModifier.firstStringArgument,
                      !accessibleName.isEmpty else {
                    continue
                }

                let visibleLower = visibleText.lowercased()
                let nameLower = accessibleName.lowercased()

                if !nameLower.contains(visibleLower) {
                    // ERROR: visible text is not contained at all in accessible name
                    diagnostics.append(makeDiagnostic(
                        message: "\(viewType)'s visible text \"\(visibleText)\" is not contained in .accessibilityLabel(\"\(accessibleName)\"). Speech input users won't be able to activate this control by speaking the visible label.",
                        node: labelModifier.callExpr,
                        context: context,
                        suggestion: "Ensure the accessible name contains the visible text \"\(visibleText)\""
                    ))
                } else if !nameLower.hasPrefix(visibleLower) {
                    // ERROR: visible text present but not at the start — Voice Control prefix-match failure
                    // WCAG 2.5.3 Understanding: "the accessible name is identical to or begins with
                    // the same sequence of characters as the visible text label."
                    diagnostics.append(makeDiagnostic(
                        message: "\(viewType)'s visible text \"\(visibleText)\" is in .accessibilityLabel(\"\(accessibleName)\") but is not at the beginning. WCAG 2.5.3 requires the accessible name to start with the visible label so Voice Control users can activate the control by speaking what they see. Move \"\(visibleText)\" to the start, or remove .accessibilityLabel() so the visible label is used automatically.",
                        node: labelModifier.callExpr,
                        context: context,
                        suggestion: "Move \"\(visibleText)\" to the beginning of .accessibilityLabel(), or remove .accessibilityLabel() to use the visible label automatically"
                    ))
                }
            }
        }

        return diagnostics
    }
    /// Controls whose visible label is a separate `Text` above them, rather than their own
    /// argument.
    ///
    /// A `TextField` carrying `.accessibilityLabel("Enter address")` under a visible
    /// `Text("Searching near")` fails 2.5.3 just as plainly as a mislabelled Button: a Voice
    /// Control user says what they see and nothing happens. The rule's other path only reads a
    /// control's own argument, so this shape went unreported.
    ///
    /// Deliberately narrow, because deciding which nearby `Text` is a control's label is a
    /// guess and the wrong guess is a false positive on correct code:
    ///
    /// - the `Text` must be the **immediately preceding sibling** in the same container,
    /// - both strings must be known — a literal, or a localised constant this run could
    ///   resolve — so nothing is inferred from an identifier's name,
    /// - a container that groups its children is skipped, since the label then belongs to the
    ///   group rather than the control.
    private func checkAdjacentLabels(
        visitor: ViewHierarchyVisitor,
        syntax: SourceFileSyntax,
        context: RuleContext
    ) -> [A11yDiagnostic] {
        let controlTypes = ["TextField", "SecureField", "TextEditor", "Picker", "DatePicker", "Slider", "Stepper"]
        var diagnostics: [A11yDiagnostic] = []

        for type in controlTypes {
            for control in visitor.views(ofType: type) {
                guard let labelMod = control.modifiers.modifiers(named: "accessibilityLabel").first,
                      let accessibleName = resolvedText(labelMod.arguments.first?.text, context: context),
                      !accessibleName.isEmpty
                else { continue }

                guard let sibling = precedingTextSibling(of: control.chainRoot),
                      let visibleText = resolvedText(sibling.text, context: context),
                      !visibleText.isEmpty
                else { continue }

                if groupsItsChildren(sibling.container) { continue }

                let nameLower = accessibleName.lowercased()
                let visibleLower = visibleText.lowercased()
                guard !nameLower.hasPrefix(visibleLower) else { continue }

                diagnostics.append(makeDiagnostic(
                    message: "The visible label \"\(visibleText)\" sits above this \(control.sourceViewType), but its accessible name is \"\(accessibleName)\". WCAG 2.5.3 asks the accessible name to begin with the visible label, so a Voice Control user can say what they see.",
                    node: labelMod.callExpr,
                    context: context,
                    suggestion: "Start the accessible name with \"\(visibleText)\", or label the control with the visible text"
                ))
            }
        }
        return diagnostics
    }

    /// A string that is either a literal or a localised constant resolved by the pre-pass.
    /// Returns nil for anything else, so an unresolved identifier is never guessed at.
    private func resolvedText(_ expression: String?, context: RuleContext) -> String? {
        guard var text = expression?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return nil }
        if text.hasPrefix("\"") && text.hasSuffix("\"") && text.count >= 2 {
            return String(text.dropFirst().dropLast())
        }
        guard !text.contains("(") else { return nil }
        if let lastDot = text.lastIndex(of: ".") {
            text = String(text[text.index(after: lastDot)...])
        }
        return context.localizedText[text]
    }

    /// The `Text(...)` immediately before this control in the same container, with the
    /// container itself so the caller can check how it handles grouping.
    private func precedingTextSibling(of chainRoot: ExprSyntax) -> (text: String, container: Syntax)? {
        var current: Syntax? = Syntax(chainRoot)
        var item: CodeBlockItemSyntax?
        while let node = current {
            if let candidate = node.as(CodeBlockItemSyntax.self) { item = candidate; break }
            current = node.parent
        }
        guard let item,
              let list = item.parent?.as(CodeBlockItemListSyntax.self),
              let index = list.firstIndex(where: { $0.id == item.id }),
              index > list.startIndex
        else { return nil }

        let previous = list[list.index(before: index)]
        guard let call = previous.item.as(FunctionCallExprSyntax.self) ?? firstCall(in: Syntax(previous.item)),
              let text = textArgument(of: call)
        else { return nil }
        return (text, Syntax(list))
    }

    /// The outermost call in a node, so `Text("x").font(.body)` yields the `Text` call.
    private func firstCall(in node: Syntax) -> FunctionCallExprSyntax? {
        if let call = node.as(FunctionCallExprSyntax.self) { return call }
        for child in node.children(viewMode: .sourceAccurate) {
            if let found = firstCall(in: child) { return found }
        }
        return nil
    }

    /// The first argument of a `Text(...)` call, following a modifier chain down to it.
    private func textArgument(of call: FunctionCallExprSyntax) -> String? {
        var candidate: FunctionCallExprSyntax? = call
        while let current = candidate {
            if let ref = current.calledExpression.as(DeclReferenceExprSyntax.self),
               ref.baseName.text == "Text" {
                return current.arguments.first?.expression.trimmedDescription
            }
            // Walk down a modifier chain: `.font(...)` applied to `Text(...)`.
            if let member = current.calledExpression.as(MemberAccessExprSyntax.self),
               let base = member.base?.as(FunctionCallExprSyntax.self) {
                candidate = base
                continue
            }
            return nil
        }
        return nil
    }

    /// Whether the container collapses its children into one accessibility element, in which
    /// case the visible label belongs to the group and not to this control.
    private func groupsItsChildren(_ container: Syntax) -> Bool {
        var current: Syntax? = container
        var depth = 0
        while let node = current, depth < 6 {
            let text = node.trimmedDescription
            if text.contains("accessibilityElement(children:") { return true }
            current = node.parent
            depth += 1
        }
        return false
    }

}
