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

// MARK: - Label Contains Role Rule

/// Flags an authored `.accessibilityLabel()` that writes a role as text when a trait
/// would convey it — `.accessibilityLabel("Home, Tab, 1 of 5")` on a Button built to
/// look like a tab.
///
/// This is the mirror of `value-contains-role`, and it is deliberately **not** the same
/// word list. That rule is about the wrong *channel*: a value is for state, so any role
/// word is misfiled there whichever role it names. This rule is about the wrong
/// *mechanism*: the author spelled out a role VoiceOver would have announced from a
/// trait, so the announcement is text rather than semantics — it does not reach the
/// Rotor, it is not localised by the system, and it survives no change to the control.
///
/// ## Which words qualify
///
/// A word is reportable only when VoiceOver announces it **as a role**, which in
/// practice means a trait exists to carry it. Probed against the iOS 27.1 SDK rather
/// than assumed:
///
/// | word | trait | reportable |
/// |---|---|---|
/// | `link` | `.isLink` | yes |
/// | `tab` | `.isTabBar` + `.isSelected` | yes |
/// | `toggle`, `switch` | `.isToggle` | yes |
/// | `search field` | `.isSearchField` | yes |
/// | `menu` | *none* | **no** |
/// | `picker` | *none* | **no** |
/// | `checkbox` | *none* | **no** |
/// | `radio button` | *none* | **no** |
/// | `slider` | *none* | **no** |
///
/// There is no `.isMenu` and no `.isPicker` in `AccessibilityTraits` at all, so a custom
/// menu or picker has nothing to apply and the word in the name is the only mechanism
/// its author has. VoiceOver never says "menu" or "picker" as a role either — a `Menu`
/// announces as a Button — so the word duplicates nothing and contradicts nothing. The
/// same holds for `checkbox` and `radio button`, which `Checkboxes.md` and
/// `RadioButtons.md` both document as the correct technique, and for `slider`, where
/// VoiceOver says "Adjustable" and no `.isSlider` or `.isAdjustable` trait exists.
/// Measured on three production apps, those five words were **every** false positive a
/// blanket list produced: 38 `"Theme picker"` on a Menu's icon and 2 `"Debug menu"` on a
/// Button that opens one, all of them naming a destination rather than claiming a role.
///
/// `button` is absent on purpose. `button-label-contains-role` already owns it on a
/// `Button`, where it is duplication and autofixable; a role claim of "button" on
/// something that is *not* a button is a real but separate gap, left for its own change
/// rather than folded in here where it would double-report.
///
/// ## Two defects, not one
///
/// The word may match the element's own role or contradict it, and the fix differs:
///
/// - **Duplication** — `.accessibilityLabel("Terms link")` on a `Link`. VoiceOver says
///   "Terms link, Link". Remove the word.
/// - **Mismatch** — `.accessibilityLabel("Terms link")` on a `Button`. VoiceOver says
///   "Terms link, Button", so the name claims a role the element does not have. The word
///   is not the defect, it is the *evidence*: the author is naming the semantic they
///   meant. Use `Link`, or add `.isLink`.
///
/// The mismatch half is why this rule is element-independent. `button-used-as-link`
/// catches the same defect only when it can see an unconditional `openURL` in the
/// action; navigation through a coordinator or a callback is invisible to it by design,
/// and there the label is the only signal available.
///
/// ## Why position matters
///
/// A role *claim* is appositive — it sits at the end of the name, or as its own
/// comma-delimited unit, the way VoiceOver would append it. A role word inside a verb
/// phrase is prose. So `"Save, Tab, 1 of 5"` and `"Settings tab"` report, while
/// `"Connect to the internet to link your health records"` does not. That last one is
/// real, from two shipping apps, and the guard is the only thing that separates it from
/// a claim: a word-count guard would not, because the fake tab that motivated this rule
/// is a long interpolated string.
///
/// Interpolation is read as an opaque placeholder token rather than elided, which
/// matters in both directions. `"\(tab.title) tab"` keeps its trailing word and
/// reports; `"Switch \(deviceName)"` does not, because something follows the verb. Using
/// `firstStringArgument` here would collapse both to a trailing match and invent a false
/// positive out of a correct label.
///
/// Reported as a **warning**, not an error. The word set and the position guard are
/// validated against only two true positives across three production apps — real ones,
/// both custom tab bars in shipping code, but a thin sample for a gate. Promote with
/// `severity_overrides` once a codebase has measured its own precision.
///
/// WCAG 4.1.2 Name, Role, Value
public struct LabelContainsRoleRule: A11yRule {
    public let id = "label-contains-role"
    public let name = "Accessibility Label Writes a Role as Text"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["4.1.2"]
    public let description = "An .accessibilityLabel() should not spell out a role that an accessibility trait conveys. Writing \"Tab\" or \"link\" into the name makes the role text rather than semantics. Only words VoiceOver announces as a role are reported — 'menu', 'picker', 'checkbox', 'radio button' and 'slider' have no trait to use instead and are never flagged."

    public init() {}

    /// A reportable role word, the trait that should carry it, and the view type that
    /// announces it natively. `nativeView` is used only to word the diagnostic — the
    /// check itself is element-independent, because a mismatch matters as much as a
    /// duplication.
    struct RoleWord {
        let word: String
        let remedy: String
        /// View types whose own role already *is* this word, making the finding a
        /// duplication rather than a mismatch.
        let nativeViews: Set<String>
        /// Traits that announce this role, so an author who added one by hand has made the
        /// role real and the word is then merely redundant.
        let traitNames: Set<String>
    }

    /// Ordered longest-phrase-first so a multi-word role is matched before any word it
    /// contains.
    static let roleWords: [RoleWord] = [
        RoleWord(
            word: "search field",
            remedy: "add .accessibilityAddTraits(.isSearchField)",
            nativeViews: ["TextField", "SearchField"],
            traitNames: ["isSearchField"]
        ),
        RoleWord(
            word: "link",
            remedy: "use Link(destination:), or add .accessibilityAddTraits(.isLink)",
            nativeViews: ["Link"],
            traitNames: ["isLink"]
        ),
        RoleWord(
            word: "tab",
            remedy: "put .accessibilityAddTraits(.isTabBar) and .accessibilityElement(children: .contain) on the tab bar container, .isSelected on the selected item, and move any position into .accessibilityValue(\"1 of 5\")",
            nativeViews: ["TabView"],
            traitNames: ["isTabBar"]
        ),
        RoleWord(
            word: "toggle",
            remedy: "use Toggle, or add .accessibilityAddTraits(.isToggle)",
            nativeViews: ["Toggle"],
            traitNames: ["isToggle"]
        ),
        RoleWord(
            word: "switch",
            remedy: "use Toggle, or add .accessibilityAddTraits(.isToggle)",
            nativeViews: ["Toggle"],
            traitNames: ["isToggle"]
        ),
    ]

    /// Phrases that contain a reportable word but must never be reported themselves.
    ///
    /// Only `radio button` currently needs this, and only because it ends in a word that
    /// a future change might add to `roleWords`. Matched before the word scan so the
    /// longer phrase always wins.
    static let neverReported: [String] = ["radio button"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        // `ModifierCollector` hands the same modifier to every view in an enclosing chain, so
        // a label written on a Button inside a VStack arrives under both — and under the Text
        // in the Button's own label closure. Collect each label once, then resolve the element
        // it is written on from the chain. Taking the loop's view instead named whichever was
        // detected first, which got the message wrong ("VStack does not have it"), suppressed
        // the `button-used-as-link` dedup against the wrong node, and would have called a
        // label on a Link a mismatch.
        var viewsByCall: [SyntaxIdentifier: ViewHierarchyVisitor.DetectedView] = [:]
        for view in visitor.detectedViews { viewsByCall[view.callExpr.id] = view }

        var labels: [ModifierCollector.CollectedModifier] = []
        var seen: Set<SyntaxIdentifier> = []
        for view in visitor.detectedViews {
            for label in view.modifiers.modifiers(named: "accessibilityLabel")
            where !seen.contains(label.callExpr.id) {
                seen.insert(label.callExpr.id)
                labels.append(label)
            }
        }

        for label in labels {
            guard let literal = Self.stringLiteral(of: label) else { continue }
            let lower = Self.normalize(literal).lowercased()

            // A never-reported phrase suppresses the whole label rather than just its own
            // span: "radio button, checked" is one claim, not a claim plus a state.
            if Self.neverReported.contains(where: { lower.contains($0) }) { continue }

            let ownerCall = Self.chainBaseCall(of: label)
            let owner = ownerCall.flatMap { viewsByCall[$0.id] }
            let written = ownerCall?.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
                ?? owner?.sourceViewType
                ?? "This view"
            let semantic = context.configOptions.viewAliases[written] ?? written

            for role in Self.roleWords {
                if Self.neverReported.contains(role.word) { continue }
                guard Self.claimsRole(lower, word: role.word) else { continue }

                // `button-used-as-link` already reports this Button, with the same fix.
                if role.word == "link", let owner, ButtonUsedAsLinkRule.reportsAsLink(owner) {
                    break
                }

                // Duplication, not mismatch, when the role is genuinely announced — either
                // because the element is the native control for it, or because the author
                // added the trait by hand. `.accessibilityAddTraits(.isLink)` on a Button
                // makes VoiceOver say "Link", so the word in the name is then redundant
                // rather than untrue, and the advice is to delete it rather than to go and
                // make the role real.
                let hasTrait = owner.map { Self.announcesTrait($0, role: role) } ?? false
                let isDuplication = role.nativeViews.contains(semantic) || hasTrait

                diagnostics.append(makeDiagnostic(
                    message: Self.message(
                        role: role,
                        labelText: literal,
                        viewType: written,
                        isDuplication: isDuplication
                    ),
                    node: label.reportNode,
                    context: context,
                    suggestion: isDuplication
                        ? "Remove \"\(role.word)\" from the accessibility label"
                        : role.remedy
                ))
                break
            }
        }

        return diagnostics
    }

    /// Whether the element already carries the trait that announces this role.
    private static func announcesTrait(
        _ view: ViewHierarchyVisitor.DetectedView,
        role: RoleWord
    ) -> Bool {
        guard !role.traitNames.isEmpty else { return false }
        return view.modifiers.modifiers(named: "accessibilityAddTraits").contains { mod in
            mod.arguments.contains { arg in
                role.traitNames.contains { arg.text.contains($0) }
            }
        }
    }

    // MARK: - Resolving the element

    /// The view-construction call this modifier is applied to.
    ///
    /// Walks down the chain below the modifier — `Text("x").padding().accessibilityLabel(…)`
    /// resolves to the `Text("x")` call — and stops at the first call whose callee is a plain
    /// name. Returns nil when the chain bottoms out in something that is not a view
    /// construction, such as a label applied to `content` inside a `ViewModifier`.
    static func chainBaseCall(
        of modifier: ModifierCollector.CollectedModifier
    ) -> FunctionCallExprSyntax? {
        guard let member = modifier.callExpr.calledExpression.as(MemberAccessExprSyntax.self),
              var current = member.base else { return nil }
        while true {
            guard let call = current.as(FunctionCallExprSyntax.self) else { return nil }
            if call.calledExpression.is(DeclReferenceExprSyntax.self) { return call }
            guard let nextMember = call.calledExpression.as(MemberAccessExprSyntax.self),
                  let next = nextMember.base else { return nil }
            current = next
        }
    }

    // MARK: - Reading the label

    /// The label's string literal, or nil when the argument is not one.
    ///
    /// A localised or variable label holds no text to judge, and most real labels are
    /// one of those — measured at 74–86% across three production apps. That is a
    /// coverage ceiling on this rule, not something to work around by guessing from an
    /// identifier's name.
    static func stringLiteral(of modifier: ModifierCollector.CollectedModifier) -> String? {
        guard let expr = modifier.callExpr.arguments.first?.expression else { return nil }
        // `.accessibilityLabel(Text("…"))` is as common as the bare-string form.
        if let call = expr.as(FunctionCallExprSyntax.self),
           call.calledExpression.trimmedDescription == "Text",
           let inner = call.arguments.first?.expression {
            return Self.render(inner)
        }
        return Self.render(expr)
    }

    /// Render a string literal with each interpolation replaced by a placeholder token,
    /// so position analysis sees that *something* sits there.
    ///
    /// `ModifierCollector.firstStringArgument` joins segments and drops interpolations,
    /// which turns `"Switch \(deviceName)"` into `"Switch "` and makes a verb look like a
    /// trailing role claim. The placeholder keeps the two apart.
    private static func render(_ expr: ExprSyntax) -> String? {
        guard let literal = expr.as(StringLiteralExprSyntax.self) else { return nil }
        return literal.segments.map { segment -> String in
            if let text = segment.as(StringSegmentSyntax.self) {
                return text.content.text
            }
            return Self.interpolationPlaceholder
        }.joined()
    }

    /// Stands in for `\(…)`. A letter so it reads as a word to the boundary checks, and
    /// one that cannot collide with a role word.
    private static let interpolationPlaceholder = "\u{FFFC}"

    /// Collapse whitespace so `", Tab,  of "` and `", Tab, of "` behave alike.
    static func normalize(_ text: String) -> String {
        text.split(separator: " ", omittingEmptySubsequences: true).joined(separator: " ")
    }

    // MARK: - Position guard

    /// Whether `word` appears as a role *claim* rather than as prose.
    ///
    /// Two accepted shapes, both the way VoiceOver itself appends a role:
    /// - **trailing** — the last word of the name, ignoring trailing punctuation.
    /// - **a standalone comma-delimited segment** — `"Home, Tab, 1 of 5"`.
    ///
    /// Anything else is a word doing a job inside a sentence, which is why
    /// `"…to link your health records"` and `"Switch \(device)"` are not claims.
    static func claimsRole(_ haystack: String, word: String) -> Bool {
        let trimmedTrailing = haystack.drop(while: { _ in false })
            .reversed()
            .drop(while: { !$0.isLetter && !$0.isNumber && $0 != Character(Self.interpolationPlaceholder) })
            .reversed()
        let tail = String(trimmedTrailing)

        // Trailing: the name ends with the word, on a word boundary.
        if tail.lowercased().hasSuffix(word) {
            let idx = tail.index(tail.endIndex, offsetBy: -word.count)
            if idx == tail.startIndex || !tail[tail.index(before: idx)].isLetter {
                return true
            }
        }

        // Standalone comma-delimited segment.
        for segment in haystack.split(separator: ",") {
            let cleaned = segment.trimmingCharacters(in: .whitespaces).lowercased()
            if cleaned == word { return true }
        }

        return false
    }

    // MARK: - Messages

    private static func message(
        role: RoleWord,
        labelText: String,
        viewType: String,
        isDuplication: Bool
    ) -> String {
        let shown = labelText.replacingOccurrences(of: Self.interpolationPlaceholder, with: "\\(…)")
        if isDuplication {
            return ".accessibilityLabel(\"\(shown)\") ends in the role word '\(role.word)', and \(viewType) already announces that role — VoiceOver says \"\(shown), \(role.word.capitalized)\". Remove '\(role.word)' from the name."
        }
        return ".accessibilityLabel(\"\(shown)\") claims the '\(role.word)' role, but \(viewType) does not have it — VoiceOver announces \(viewType == "Button" ? "'Button'" : "a different role") and the claim is text that no assistive technology can act on. It will not reach the Rotor, and Voice Control cannot use it. To make the role real, \(role.remedy)."
    }
}
