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

/// Drops diagnostics that fall inside preview-only code.
///
/// Preview scaffolding never ships, so no user can encounter an accessibility defect in it, and
/// a finding there is something nobody can act on usefully. Before this filter existed the
/// question was settled rule by rule: `heading-trait-missing`, `missing-navigation-title`,
/// `button-label-contains-role`, `duplicate-button-label`, `image-missing-label` and
/// `zstack-order-confusing` each grew their own preview handling, in six different shapes, and a
/// seventh was arriving. Deciding it once in one place is both less code and more predictable.
///
/// Three forms are recognised, all structurally rather than by name:
///
///   #Preview { … }                      the macro, declaration or expression form
///   struct X: PreviewProvider { … }      the pre-iOS 17 protocol
///   struct X_Previews { … }              the conventional suffix
///
/// Detection is deliberately not name-based beyond the `_Previews` suffix: a shipping `View`
/// merely called `PreviewCardView` is real UI and its findings are kept.
public enum PreviewCodeFilter {

    /// Remove diagnostics whose line falls within preview-only code.
    public static func filter(
        _ diagnostics: [A11yDiagnostic],
        syntax: SourceFileSyntax,
        converter: SourceLocationConverter
    ) -> [A11yDiagnostic] {
        let ranges = previewLineRanges(syntax: syntax, converter: converter)
        guard !ranges.isEmpty else { return diagnostics }
        return diagnostics.filter { diagnostic in
            !ranges.contains { $0.contains(diagnostic.line) }
        }
    }

    /// Inclusive line ranges covered by preview-only declarations.
    static func previewLineRanges(
        syntax: SourceFileSyntax,
        converter: SourceLocationConverter
    ) -> [ClosedRange<Int>] {
        let collector = Collector(viewMode: .sourceAccurate)
        collector.walk(syntax)
        return collector.nodes.compactMap { node in
            let start = converter.location(for: node.positionAfterSkippingLeadingTrivia).line
            let end = converter.location(for: node.endPositionBeforeTrailingTrivia).line
            guard start <= end else { return nil }
            return start...end
        }
    }

    private final class Collector: SyntaxVisitor {
        var nodes: [Syntax] = []

        override func visit(_ node: MacroExpansionDeclSyntax) -> SyntaxVisitorContinueKind {
            if node.macroName.text == "Preview" {
                nodes.append(Syntax(node))
                return .skipChildren
            }
            return .visitChildren
        }

        override func visit(_ node: MacroExpansionExprSyntax) -> SyntaxVisitorContinueKind {
            if node.macroName.text == "Preview" {
                nodes.append(Syntax(node))
                return .skipChildren
            }
            return .visitChildren
        }

        override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
            let inherited = node.inheritanceClause?.inheritedTypes
                .map { $0.type.trimmedDescription } ?? []
            if inherited.contains("PreviewProvider") || node.name.text.hasSuffix("_Previews") {
                nodes.append(Syntax(node))
                return .skipChildren
            }
            return .visitChildren
        }
    }
}
