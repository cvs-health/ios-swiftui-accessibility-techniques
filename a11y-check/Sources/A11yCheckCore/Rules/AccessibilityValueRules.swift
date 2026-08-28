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
                        diagnostics.append(makeDiagnostic(
                            message: ".accessibilityValue(\"\(text)\") contains the role word '\(word)'. Values are for state, not role — VoiceOver announces the role automatically. Remove '\(word)' from the value, and if the role is not being announced, restore the correct accessibility trait instead.",
                            node: value.reportNode,
                            context: context,
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
