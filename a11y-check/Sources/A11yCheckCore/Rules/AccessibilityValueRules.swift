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
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []
        var reportedNodeIDs: Set<SyntaxIdentifier> = []

        for view in visitor.detectedViews {
            for value in view.modifiers.modifiers(named: "accessibilityValue") {
                guard let text = value.firstStringArgument else { continue }
                // Deduplicate: the same modifier can be collected by multiple views
                // when a chain sits above nested view calls.
                if reportedNodeIDs.contains(value.callExpr.id) { continue }

                let lower = text.lowercased()
                for word in Self.roleWords {
                    if containsWholeWord(lower, word: word) {
                        reportedNodeIDs.insert(value.callExpr.id)
                        let fix = makeStringReplacementFix(
                            callExpr: value.callExpr,
                            originalText: text,
                            word: word,
                            sourceFile: syntax
                        )
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

        return diagnostics
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
