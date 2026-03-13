import SwiftSyntax

// MARK: - Image Missing Label Rule

/// Flags `Image(systemName:)` or `Image("name")` that lack `.accessibilityLabel()`
/// and are not marked as decorative via `Image(decorative:)` or `.accessibilityHidden(true)`.
/// Skips images that are inside a Button or Link that has .accessibilityLabel() — the button's label is the accessible name.
///
/// WCAG 1.1.1 Non-text Content
/// Reference: InformativeView.swift, DecorativeView.swift, FunctionalView.swift
public struct ImageMissingLabelRule: A11yRule {
    public let id = "image-missing-label"
    public let name = "Image Missing Accessibility Label"
    public let severity = A11ySeverity.error
    public let wcagCriteria = ["1.1.1"]
    public let description = "Non-decorative images must have an .accessibilityLabel() or use Image(decorative:)."

    public init() {}

    private static let labelConsumerViews: Set<String> = ["Button", "Link"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Image") {
            // Skip decorative images — they're intentionally unlabeled
            if view.isDecorativeImage { continue }

            let mods = view.modifiers

            // Skip if hidden from accessibility
            if hasAccessibilityHidden(mods) { continue }

            // Skip if it has an accessibility label
            if mods.hasModifier("accessibilityLabel") { continue }

            // Skip if the parent chain has .accessibilityElement(children: .combine)
            // since the parent may provide the label
            if hasAccessibilityElementCombine(mods) { continue }

            // Skip if image is inside a Button/Link that has .accessibilityLabel() — the button's label is the accessible name
            if isImageInsideLabeledButtonOrLink(view.callExpr) { continue }

            diagnostics.append(makeDiagnostic(
                message: "Image is missing .accessibilityLabel(). Add a descriptive label or use Image(decorative:) / .accessibilityHidden(true) for decorative images.",
                node: view.callExpr,
                context: context,
                suggestion: "Add .accessibilityLabel(\"description\") or use Image(decorative:)"
            ))
        }
        return diagnostics
    }

    /// True if this Image is inside a Button or Link that has .accessibilityLabel() (or equivalent).
    private func isImageInsideLabeledButtonOrLink(_ imageCallExpr: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(imageCallExpr).parent
        while let node = current {
            if let call = node.as(FunctionCallExprSyntax.self) {
                let viewName: String? = {
                    if let ref = call.calledExpression.as(DeclReferenceExprSyntax.self) {
                        return ref.baseName.text
                    }
                    if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
                       let base = member.base?.as(DeclReferenceExprSyntax.self),
                       member.declName.baseName.text == "init" {
                        return base.baseName.text
                    }
                    return nil
                }()
                if let name = viewName, Self.labelConsumerViews.contains(name) {
                    let chainRoot = findChainRoot(for: ExprSyntax(call))
                    let mods = ModifierCollector.collect(from: chainRoot)
                    if mods.hasModifier("accessibilityLabel") {
                        return true
                    }
                }
            }
            current = node.parent
        }
        return false
    }

    /// Walk up from a function call to the outermost expression in its modifier chain.
    private func findChainRoot(for expr: ExprSyntax) -> ExprSyntax {
        var current = expr
        while let parent = current.parent {
            if let memberAccess = parent.as(MemberAccessExprSyntax.self),
               let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                current = ExprSyntax(grandparent)
                continue
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

// MARK: - Image Label Contains "Image" Rule

/// Flags `.accessibilityLabel()` values that contain words like "image", "icon", "picture",
/// "graphic" — the accessibility trait already conveys this.
///
/// WCAG 1.1.1 Non-text Content
/// Reference: InformativeImages.md — "Don't include 'Image' in label"
public struct ImageLabelContainsImageRule: A11yRule {
    public let id = "image-label-contains-role"
    public let name = "Image Label Contains Role Word"
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["1.1.1"]
    public let description = "Accessibility labels should not contain the word 'image', 'icon', 'picture', or 'graphic' — the role is announced automatically."

    public init() {}

    /// Words that should not appear in image accessibility labels.
    private static let roleWords = ["image", "icon", "picture", "graphic", "photo"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Image") {
            let labels = view.modifiers.modifiers(named: "accessibilityLabel")
            for label in labels {
                guard let text = label.firstStringArgument else { continue }
                let lower = text.lowercased()
                for word in Self.roleWords {
                    if lower.contains(word) {
                        diagnostics.append(makeDiagnostic(
                            message: "Accessibility label \"\(text)\" contains '\(word)'. The Image role is announced automatically by VoiceOver — remove the role word from the label.",
                            node: label.callExpr,
                            context: context,
                            suggestion: "Remove \"\(word)\" from the accessibility label"
                        ))
                        break
                    }
                }
            }
        }
        return diagnostics
    }
}

// MARK: - Helpers

/// Check if a modifier collection includes `.accessibilityHidden(true)`.
func hasAccessibilityHidden(_ mods: ModifierCollector) -> Bool {
    mods.modifiers(named: "accessibilityHidden").contains { mod in
        mod.firstStringArgument == nil && mod.arguments.first?.text == "true"
    }
}

/// Check if a modifier collection includes `.accessibilityElement(children: .combine)`.
func hasAccessibilityElementCombine(_ mods: ModifierCollector) -> Bool {
    mods.modifiers(named: "accessibilityElement").contains { mod in
        mod.arguments.contains { $0.label == "children" && $0.text.contains("combine") }
    }
}
