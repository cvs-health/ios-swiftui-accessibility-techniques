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

// MARK: - Missing Navigation Title Rule

/// Flags views with `NavigationStack` (or `NavigationView`) that don't set `.navigationTitle()`.
/// Page titles are critical for VoiceOver orientation.
///
/// Skips NavigationStack/NavigationView inside PreviewProvider or #Preview — the wrapped view sets the title at runtime.
///
/// WCAG 2.4.2 Page Titled
/// Reference: PageTitlesView.swift — bad example omits .navigationTitle()
public struct MissingNavigationTitleRule: A11yRule {
    public let id = "missing-navigation-title"
    public let name = "Missing .navigationTitle()"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.4.2"]
    public let description = "Views inside NavigationStack should set .navigationTitle() so VoiceOver can announce the page title."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        // Look for NavigationStack / NavigationView usage
        let navContainers = visitor.views(ofType: "NavigationStack") + visitor.views(ofType: "NavigationView")

        for nav in navContainers {
            // Skip preview-only stacks: the child view provides the title at runtime
            if isInsidePreviewContext(nav.callExpr) { continue }

            // Check if .navigationTitle() appears anywhere in the navigation container's subtree
            let modCollector = ModifierCollector.collect(from: nav.chainRoot)
            if !modCollector.hasModifier("navigationTitle") {
                // Also check the trailing closure body
                if let body = nav.callExpr.trailingClosure {
                    let bodyCollector = ModifierCollector.collect(from: body)
                    if !bodyCollector.hasModifier("navigationTitle") {
                        let fix = firstChildModifierFix(
                            in: nav.callExpr,
                            modifier: ".navigationTitle(\"Page Title\")",
                            sourceFile: syntax
                        )
                        diagnostics.append(makeDiagnostic(
                            message: "NavigationStack is missing .navigationTitle(). Set a page title so VoiceOver users know which page they're on.",
                            node: nav.callExpr,
                            context: context,
                            fix: fix,
                            suggestion: "Add .navigationTitle(\"Page Title\") inside the NavigationStack"
                        ))
                    }
                }
            }
        }
        return diagnostics
    }

    /// Builds a fix that inserts `modifier` on the chain root of the first child expression
    /// inside the NavigationStack's trailing closure. Returns nil if no expression child is found.
    private func firstChildModifierFix(
        in navCall: FunctionCallExprSyntax,
        modifier: String,
        sourceFile: SourceFileSyntax
    ) -> A11yFix? {
        guard let body = navCall.trailingClosure,
              let firstStmt = body.statements.first,
              case .expr(let expr) = firstStmt.item else { return nil }
        let chainRoot = walkToChainRoot(expr)
        return makeModifierFix(chainRoot: chainRoot, modifier: modifier, sourceFile: sourceFile)
    }

    /// Walks up the AST from `expr` to return the outermost expression in its fluent modifier chain.
    private func walkToChainRoot(_ expr: ExprSyntax) -> ExprSyntax {
        var current = expr
        while let parent = current.parent {
            if let memberAccess = parent.as(MemberAccessExprSyntax.self),
               let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self),
               memberAccess.base?.id == current.id {
                current = ExprSyntax(grandparent)
            } else {
                break
            }
        }
        return current
    }

    /// True if this node is inside a PreviewProvider struct or #Preview macro (preview-only NavigationStack).
    private func isInsidePreviewContext(_ node: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(node).parent
        while let n = current {
            if let structDecl = n.as(StructDeclSyntax.self) {
                if let clause = structDecl.inheritanceClause {
                    for inherited in clause.inheritedTypes {
                        if inherited.type.description.contains("PreviewProvider") {
                            return true
                        }
                    }
                }
            }
            if let macroExp = n.as(MacroExpansionExprSyntax.self) {
                if macroExp.macroName.text == "Preview" {
                    return true
                }
            }
            current = n.parent
        }
        return false
    }
}
