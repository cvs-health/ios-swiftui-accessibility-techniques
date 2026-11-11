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

// MARK: - Value Contains Role Rule

/// Flags `.accessibilityValue()` strings that contain a role word like "button",
/// "tab", "link", "toggle", "switch", "slider", "picker", or "checkbox".
///
/// `.accessibilityValue()` is meant for the *state* of a control (e.g. "50 percent",
/// "on", "selected item 2 of 5"), not the role. VoiceOver announces the role
/// automatically from the element's accessibility traits. Placing a role word in
/// the value causes VoiceOver to speak it twice (e.g. "Tab, Home, Tab 1 of 5"),
/// which is redundant and confusing. Role words in the value are also a common
/// symptom of the developer trying to compensate for a missing or removed role
/// trait — the fix is to restore the correct trait rather than smuggle the role
/// into the value string.
///
/// WCAG 4.1.2 Name, Role, Value
public struct ValueContainsRoleRule: A11yRule {
    public let id = "value-contains-role"
    public let name = "Accessibility Value Contains Role Word"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["4.1.2"]
    public let description = "Accessibility values must describe state, not role. Don't include role words like 'button', 'tab', 'link', or 'toggle' in .accessibilityValue() — VoiceOver announces the role automatically from accessibility traits."

    public init() {}

    /// Phrases that contain a role word but are the documented technique, so they must
    /// never be reported.
    ///
    /// `radio button` ends in `button`, which put this rule in the position of erroring on
    /// the pattern `RadioButtons.md` publishes as correct:
    /// `.accessibilityValue(isSelected ? "Radio button, checked" : "Radio button, unchecked")`,
    /// described there as adding "a fake radio button trait". iOS has no radio trait at any
    /// level — `.isSelected` carries the state but nothing carries the role — so the value
    /// string is the only mechanism its author has. That is the same ground on which
    /// `checkbox` is already downgraded, and here it warrants silence rather than a
    /// downgrade, because unlike a checkbox there is no alternative trait to point at.
    ///
    /// The repository's own `RadioButtonsView.swift` escaped only because its values are
    /// written as ternaries, which this rule did not resolve; anyone following the
    /// documentation with a plain literal got the error. Matched before the word scan so
    /// the longer phrase always wins.
    private static let exemptPhrases: [String] = ["radio button"]

    /// Role words that VoiceOver already announces from element traits.
    /// Matched as whole words (see `containsWholeWord`) so descriptive terms like
    /// "linked account" or "buttonhole" don't produce false positives.
    private static let roleWords: [String] = [
        "button",
        "tab",
        "link",
        "toggle",
        "switch",
        "slider",
        "checkbox",
        "picker",
        "menu",
        "search field",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []
        var reportedNodeIDs: Set<SyntaxIdentifier> = []

        for view in visitor.detectedViews {
            for value in view.modifiers.modifiers(named: "accessibilityValue") {
                // Deduplicate: the same modifier can be collected by multiple views
                // when a chain sits above nested view calls.
                if reportedNodeIDs.contains(value.callExpr.id) { continue }

                // Every branch of a conditional value is a value the user can hear, so all
                // of them are scanned and the first offending one is reported. Reading only
                // `firstStringArgument` saw none of them: it resolves a plain literal and
                // gives up on a ternary, which is how this rule stayed silent on the
                // `isOn ? "Switch, on" : "Switch, off"` shape that is the common way to
                // write a state value at all.
                let candidates = Self.candidateStrings(of: value)
                guard !candidates.isEmpty else { continue }

                var reportedThisModifier = false
                for text in candidates where !reportedThisModifier {
                    let lower = text.lowercased()

                    // The documented radio-button technique is not a defect. Checked before
                    // the word scan so `radio button` is not reported as `button`.
                    if Self.exemptPhrases.contains(where: { lower.contains($0) }) { continue }

                    for word in Self.roleWords {
                        if containsWholeWord(lower, word: word) {
                            reportedThisModifier = true
                            reportedNodeIDs.insert(value.callExpr.id)
                            // Only a single-literal value can be rewritten mechanically. In a
                            // conditional the word occurs in more than one branch, and a
                            // whole-call replacement built from one branch's text would
                            // corrupt the others — so a conditional value reports without a
                            // fix rather than with a wrong one.
                            let fix = candidates.count == 1
                                ? makeStringReplacementFix(
                                    callExpr: value.callExpr,
                                    originalText: text,
                                    word: word,
                                    sourceFile: syntax
                                )
                                : nil
                            // Gray area: iOS has no checkbox trait, so writing
                            // "checkbox" in the value is a defensible workaround
                            // for developers who want to compensate for the
                            // "Switch button" role announcement not matching the
                            // visible checkbox UI. WCAG 4.1.2 is satisfied by the
                            // Toggle's Switch trait regardless. Downgrade to a
                            // warning so it still flags the anti-pattern without
                            // treating it as a hard failure.
                            let severityOverride: A11ySeverity? = (word == "checkbox") ? .warning : nil

                            diagnostics.append(makeDiagnostic(
                                message: messageFor(word: word, valueText: text),
                                node: value.reportNode,
                                context: context,
                                severityOverride: severityOverride,
                                fix: fix,
                                suggestion: "Remove \"\(word)\" from the accessibility value"
                            ))
                            break
                        }
                    }
                }
            }
        }

        return diagnostics
    }

    /// Every string literal a value expression can evaluate to.
    ///
    /// A plain literal yields one; a ternary yields one per branch, recursively, so a
    /// nested `a ? "x" : (b ? "y" : "z")` is fully enumerated. `Text("…")` wrappers are
    /// unwrapped because `.accessibilityValue(Text(…))` is as common as the bare-string
    /// form. Anything else — a variable, a localised key, a function call — yields
    /// nothing, which is the same coverage ceiling every text-judging rule here has.
    static func candidateStrings(of modifier: ModifierCollector.CollectedModifier) -> [String] {
        guard let expr = modifier.callExpr.arguments.first?.expression else { return [] }
        var out: [String] = []
        collectStrings(from: expr, into: &out)
        return out
    }

    private static func collectStrings(from expr: ExprSyntax, into out: inout [String]) {
        if let literal = expr.as(StringLiteralExprSyntax.self) {
            // Interpolations contribute no readable text; the surrounding segments still do.
            let text = literal.segments.map { segment -> String in
                (segment.as(StringSegmentSyntax.self))?.content.text ?? ""
            }.joined()
            out.append(text)
            return
        }
        // A ternary arrives **unfolded**: without an OperatorTable, SwiftSyntax parses
        // `sel ? "on" : "off"` as a SequenceExpr of [sel, UnresolvedTernaryExpr("on"), "off"]
        // rather than a TernaryExpr. Matching only the folded node is why the first attempt at
        // this change still reported nothing — handle both.
        if let sequence = expr.as(SequenceExprSyntax.self) {
            for element in sequence.elements { collectStrings(from: element, into: &out) }
            return
        }
        if let unresolved = expr.as(UnresolvedTernaryExprSyntax.self) {
            collectStrings(from: unresolved.thenExpression, into: &out)
            return
        }
        if let ternary = expr.as(TernaryExprSyntax.self) {
            collectStrings(from: ternary.thenExpression, into: &out)
            collectStrings(from: ternary.elseExpression, into: &out)
            return
        }
        if let tuple = expr.as(TupleExprSyntax.self), tuple.elements.count == 1,
           let inner = tuple.elements.first?.expression {
            collectStrings(from: inner, into: &out)
            return
        }
        if let call = expr.as(FunctionCallExprSyntax.self),
           call.calledExpression.trimmedDescription == "Text",
           let inner = call.arguments.first?.expression {
            collectStrings(from: inner, into: &out)
        }
    }

    /// Custom guidance for role words that have a well-known iOS pattern.
    /// "checkbox" in particular is a common trap because iOS has no checkbox
    /// trait — developers reach for the value string as a workaround, but the
    /// correct pattern is `Toggle` + `.toggleStyle(CheckboxToggleStyle())`,
    /// which supplies the "Switch button" trait automatically.
    private func messageFor(word: String, valueText: String) -> String {
        switch word {
        case "checkbox":
            return ".accessibilityValue(\"\(valueText)\") contains 'checkbox'. iOS has no checkbox trait, so developers sometimes put 'checkbox' into the value — but this makes VoiceOver announce the role twice when combined with a Toggle's built-in Switch trait. The correct pattern is a Toggle with a custom .toggleStyle (e.g. CheckboxToggleStyle) plus .accessibilityValue(isChecked ? \"Checked\" : \"Unchecked\") — the trait supplies the role, the value supplies just the state. See CheckboxesView.swift and Documentation/Checkboxes.md for the reference implementation."
        case "tab":
            return ".accessibilityValue(\"\(valueText)\") contains 'tab'. Tab items should get the .isTabBar or .isSelected traits — VoiceOver announces the tab role from the trait. If you need to communicate position, use a state-only value like \"1 of 5\" and leave the role out of the value string."
        default:
            return ".accessibilityValue(\"\(valueText)\") contains the role word '\(word)'. Values are for state, not role — VoiceOver announces the role automatically from accessibility traits. Remove '\(word)' from the value; if the role is not being announced, restore the correct accessibility trait instead of embedding the role in the value string."
        }
    }

    /// True if `haystack` contains `word` as a whole word (bounded by non-letter
    /// characters on both sides) — avoids false positives like "linked" matching
    /// "link". Both arguments must already be lowercased.
    private func containsWholeWord(_ haystack: String, word: String) -> Bool {
        guard !word.isEmpty else { return false }
        var searchStart = haystack.startIndex
        while let range = haystack.range(of: word, range: searchStart..<haystack.endIndex) {
            let precedingOk: Bool = {
                if range.lowerBound == haystack.startIndex { return true }
                let prev = haystack[haystack.index(before: range.lowerBound)]
                return !prev.isLetter
            }()
            let followingOk: Bool = {
                if range.upperBound == haystack.endIndex { return true }
                let next = haystack[range.upperBound]
                return !next.isLetter
            }()
            if precedingOk && followingOk { return true }
            searchStart = range.upperBound
        }
        return false
    }
}
