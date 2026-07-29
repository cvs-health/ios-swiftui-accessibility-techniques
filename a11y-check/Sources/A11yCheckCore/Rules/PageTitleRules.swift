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

/// Flags two patterns that violate WCAG 2.4.2 Page Titled:
///
/// 1. NavigationStack/NavigationView whose trailing closure contains no `.navigationTitle()`.
///    The NavigationStack is the host — it must have a title so VoiceOver can announce the page.
///    Skips stacks inside #Preview or PreviewProvider — the child sets the title at runtime.
///
/// 2. View structs that look like screens (body's root view is ScrollView or List) but have
///    no `.navigationTitle()` anywhere in their body. These are navigation-destination views
///    that rely on a parent NavigationStack — the rule flags them even though the stack is
///    in a different file, because the destination is responsible for setting its own title.
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
                            suggestion: "Add .navigationTitle(\"Page Title\") on the root view inside the NavigationStack"
                        ))
                    }
                }
            }
        }
        // Pattern 2: View structs whose body root is ScrollView or List but have no .navigationTitle.
        // These are screen-level navigation destinations that must set their own title.
        for (structName, rootCall, bodyStatements) in screenLevelViewBodies(in: syntax) {
            // Skip view types that receive .navigationTitle from a parent navigation container
            // (detected by the cross-file pre-pass in RuleRegistry).
            if context.externallyTitledViews.contains(structName) { continue }
            let bodyText = bodyStatements.map(\.description).joined()
            if !bodyText.contains("navigationTitle") {
                // Fix targets the first content view inside ScrollView/List, not the container itself.
                // e.g.  ScrollView { VStack { ... }.padding() }
                //       → inserts .navigationTitle after VStack's last modifier, not on ScrollView.
                let fix = firstChildModifierFix(
                    in: rootCall,
                    modifier: ".navigationTitle(\"Page Title\")",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "This screen-level view has no .navigationTitle(). Add one so VoiceOver users know which page they're on when it is pushed onto a NavigationStack.",
                    node: rootCall,
                    context: context,
                    fix: fix,
                    suggestion: "Add .navigationTitle(\"Page Title\") on the content view inside the body's ScrollView or List (e.g., on VStack)"
                ))
            }
        }

        return diagnostics
    }

    /// Returns (root ScrollView/List call, body statements) for every View struct in the file
    /// whose `body` computed property starts with a ScrollView or List — the heuristic for a
    /// screen-level navigation-destination view rather than a reusable component.
    private func screenLevelViewBodies(in syntax: SourceFileSyntax) -> [(structName: String, rootCall: FunctionCallExprSyntax, bodyStatements: [CodeBlockItemSyntax])] {
        var results: [(structName: String, rootCall: FunctionCallExprSyntax, bodyStatements: [CodeBlockItemSyntax])] = []
        let screenRootViews: Set<String> = ["ScrollView", "List"]

        for statement in syntax.statements {
            guard case .decl(let decl) = statement.item,
                  let structDecl = decl.as(StructDeclSyntax.self) else { continue }

            // Only check structs conforming to View
            guard let clause = structDecl.inheritanceClause,
                  clause.inheritedTypes.contains(where: { $0.type.trimmedDescription == "View" }) else { continue }

            for member in structDecl.memberBlock.members {
                guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                      let binding = varDecl.bindings.first,
                      let idPattern = binding.pattern.as(IdentifierPatternSyntax.self),
                      idPattern.identifier.text == "body",
                      let accessorBlock = binding.accessorBlock else { continue }

                let items: CodeBlockItemListSyntax
                switch accessorBlock.accessors {
                case .getter(let list): items = list
                case .accessors(let list):
                    guard let getter = list.first(where: { $0.accessorSpecifier.text == "get" }),
                          let body = getter.body else { continue }
                    items = body.statements
                }

                guard let first = items.first,
                      case .expr(let expr) = first.item,
                      let call = expr.as(FunctionCallExprSyntax.self),
                      let name = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text,
                      screenRootViews.contains(name) else { continue }

                results.append((structName: structDecl.name.text, rootCall: call, bodyStatements: Array(items)))
            }
        }
        return results
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
