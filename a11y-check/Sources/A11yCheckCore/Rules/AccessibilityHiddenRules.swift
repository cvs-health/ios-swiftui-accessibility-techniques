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

// MARK: - Hidden On Parent With Controls Rule

/// Flags `.accessibilityHidden(true)` on container views (HStack, VStack, ZStack, etc.)
/// that contain interactive children (Button, Link, Toggle, TextField, etc.).
/// This hides all functional controls from VoiceOver, Voice Control, Full Keyboard Access,
/// and Switch Control.
///
/// WCAG 4.1.2 Name, Role, Value
/// Reference: AccessibilityHidden.swift — bad example puts .accessibilityHidden(true) on parent
public struct HiddenOnParentWithControlsRule: A11yRule {
    public let id = "hidden-parent-with-controls"
    public let name = "accessibilityHidden on Parent with Controls"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["4.1.2"]
    public let description = "Don't use .accessibilityHidden(true) on containers that have interactive children — it hides all controls from assistive technology."

    public init() {}

    /// View types that represent interactive/functional controls.
    private static let interactiveViewTypes: Set<String> = [
        "Button", "Link", "Toggle", "TextField", "SecureField", "TextEditor",
        "Slider", "Stepper", "Picker", "DatePicker", "ColorPicker",
        "NavigationLink", "Menu",
    ]

    /// View types that are containers.
    private static let containerViewTypes: Set<String> = [
        "HStack", "VStack", "ZStack", "LazyHStack", "LazyVStack",
        "Group", "GroupBox", "Section", "Form",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.detectedViews {
            guard Self.containerViewTypes.contains(view.viewType) else { continue }

            // Collect modifiers only from the direct chain on this container,
            // NOT from children inside the trailing closure.
            let directModifiers = ModifierCollector.collectChainOnly(from: view.chainRoot, callExpr: view.callExpr)
            guard hasAccessibilityHidden(directModifiers) else { continue }

            // Check if the container's body has interactive children
            guard let body = view.callExpr.trailingClosure else { continue }
            let innerVisitor = ViewHierarchyVisitor.analyze(body, viewAliases: context.configOptions.viewAliases)

            let hasInteractiveChild = innerVisitor.detectedViews.contains { child in
                Self.interactiveViewTypes.contains(child.viewType)
            }

            if hasInteractiveChild {
                diagnostics.append(makeDiagnostic(
                    message: ".accessibilityHidden(true) on a container hides all interactive children from VoiceOver, Voice Control, Full Keyboard Access, and Switch Control. Apply it only to individual decorative elements instead.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Remove .accessibilityHidden(true) from the container and apply it only to decorative children"
                ))
            }
        }
        return diagnostics
    }
}

// MARK: - Hidden Label Text Rule

/// Flags `.accessibilityHidden(true)` on visible text that reads as a label.
///
/// The pattern this exists for: a control's label is moved onto the control with
/// `.accessibilityLabel`, and the visible `Text` beside it is then hidden "so VoiceOver does not
/// read it twice". The duplication is real, but hiding is the wrong cure — it removes content a
/// sighted user can read, and if the text's information only survives as an
/// `.accessibilityHint` it is lost entirely for anyone who has hints switched off.
///
/// The web settled this long ago: `<label for>` and `aria-describedby` associate the text with
/// the control and the visible text stays in the reading order. Nobody reaches for `aria-hidden`
/// to tidy the repetition. Verbosity is an annoyance; hidden content is a defect.
///
/// Deliberately narrow, because hiding text is sometimes correct — a notification badge count or
/// a decorative glyph beside an already-labelled icon is repetitive, not informative. So this
/// only fires when:
///
/// - the hidden value is `true` or a condition, not a literal `false`
/// - the text is **wordy**: more than one word, or a resolved string over
///   ``decorativeLengthLimit`` characters. A badge count, `"•"`, or `"*"` is left alone
/// - no ancestor groups its children with `.combine` or `.ignore`, where hiding a child changes
///   nothing
/// - the text is not `.strikethrough()`. A struck-through original price is the one case where
///   hiding is the better technique: VoiceOver cannot convey strikethrough, so "5.99" read aloud
///   claims to be the price. Hiding it and announcing the real price elsewhere is correct, and
///   this was 2 of 3 false positives on a real app
/// - it is not the content of a `.placeholder { ... }` overlay, where the field underneath
///   already carries the name
/// Preview-only scaffolding is excluded centrally by ``PreviewCodeFilter``, so this rule does
/// not repeat that check.
///
/// WCAG 1.3.1 Info and Relationships — content available visually must be available to AT
/// Reference: AccessibilityHidden.swift — second bad example
public struct HiddenLabelTextRule: A11yRule {
    public let id = "hidden-label-text"
    public let name = "Visible Label Text Hidden from Assistive Technology"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.3.1"]
    public let description = "Don't use .accessibilityHidden(true) on visible label text. Moving the label onto the control with .accessibilityLabel and hiding the visible copy removes content sighted users can read. Associate them instead and accept the repetition, as the web does with <label for> and aria-describedby."

    public init() {}

    /// A resolved literal at or below this length is treated as decoration — a badge count, a
    /// bullet, a separator — rather than a label.
    private static let decorativeLengthLimit = 3

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Text") {
            guard let hidden = view.modifiers.modifiers(named: "accessibilityHidden").first else { continue }
            let argument = hidden.arguments.first?.text ?? "true"
            // `false` is an explicit decision to keep it visible to AT.
            guard argument != "false" else { continue }
            if groupsChildren(above: view.chainRoot) { continue }
            if view.modifiers.hasModifier("strikethrough") { continue }
            if isPlaceholderOverlay(above: view.chainRoot) { continue }
            guard isWordy(view.firstStringArgument) else { continue }

            diagnostics.append(makeDiagnostic(
                message: "This text is hidden from assistive technology with .accessibilityHidden(\(argument)), but it is visible on screen. If its text was moved onto a control as .accessibilityLabel, associate the two instead of hiding this copy — a hint can be switched off by the user, and hidden text cannot be reached at all. Repetition is better than loss.",
                node: hidden.callExpr,
                context: context,
                suggestion: "Remove .accessibilityHidden and let the text stay readable, keeping the control's .accessibilityLabel"
            ))
        }
        return diagnostics
    }

    /// Whether the string looks like a label rather than decoration. An unresolved expression
    /// counts as wordy: dynamic text is almost always content.
    private func isWordy(_ text: String?) -> Bool {
        guard let text else { return true }
        if text.contains(" ") { return true }
        return text.count > Self.decorativeLengthLimit
    }

    /// Whether any ancestor merges or drops its children, which makes hiding one of them moot.
    /// Whether this text is the content of a `.placeholder { ... }` overlay.
    ///
    /// The `View.placeholder(when:)` idiom draws a visual stand-in over an empty `TextField`,
    /// because SwiftUI's own placeholder cannot be styled. The field underneath carries the
    /// accessible name, so hiding the visual copy is correct — leaving it visible is what makes
    /// VoiceOver read the name twice.
    ///
    /// This exclusion opens no hole: a field with a placeholder and *no* name of its own is
    /// already reported by `placeholder-only-label`, at critical.
    private func isPlaceholderOverlay(above chainRoot: ExprSyntax) -> Bool {
        var current: Syntax? = Syntax(chainRoot).parent
        while let node = current {
            if let call = node.as(FunctionCallExprSyntax.self),
               let member = call.calledExpression.as(MemberAccessExprSyntax.self),
               member.declName.baseName.text == "placeholder" {
                return true
            }
            current = node.parent
        }
        return false
    }

    private func groupsChildren(above chainRoot: ExprSyntax) -> Bool {
        var current: Syntax? = Syntax(chainRoot).parent
        while let node = current {
            if let call = node.as(FunctionCallExprSyntax.self),
               let member = call.calledExpression.as(MemberAccessExprSyntax.self),
               member.declName.baseName.text == "accessibilityElement" {
                let args = call.arguments.map(\.description).joined()
                if args.contains("combine") || args.contains("ignore") { return true }
            }
            current = node.parent
        }
        return false
    }
}
