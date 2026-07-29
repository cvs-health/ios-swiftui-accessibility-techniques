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

/// Scans a single source file to find View type names that receive `.navigationTitle()`
/// externally — i.e., a parent navigation container calls `.navigationTitle()` on the
/// returned view at the call site rather than the view setting it internally.
///
/// Detects two patterns:
///
/// 1. Direct external title: `SomeView().navigationTitle("...")`
///    → "SomeView" is externally titled.
///
/// 2. Indirect via `@ViewBuilder` helper: `getDetailView(for: item).navigationTitle("...")`
///    where `getDetailView` is a `@ViewBuilder` function whose body constructs view types
///    like `InformativeImagesWatch()`, `TabsWatch()`, etc.
///    → all view types constructed inside `getDetailView` are externally titled.
///
/// Usage:
/// ```swift
/// let scanner = NavigationTitleCallSiteScanner(viewMode: .sourceAccurate)
/// scanner.walk(syntaxTree)
/// let externallyTitled = scanner.resolvedExternallyTitledViews()
/// ```
final class NavigationTitleCallSiteScanner: SyntaxVisitor {

    /// Maps `@ViewBuilder` function name → set of View type names constructed in its body.
    private(set) var viewBuilderBodies: [String: Set<String>] = [:]

    /// Names collected from `.navigationTitle(...)` call sites (may be view type names or function names).
    private(set) var navTitleCallSites: [String] = []

    // MARK: - Visitor

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard isViewBuilder(node), let body = node.body else { return .visitChildren }
        let viewTypes = collectViewConstructorNames(in: Syntax(body))
        if !viewTypes.isEmpty {
            viewBuilderBodies[node.name.text] = viewTypes
        }
        return .visitChildren
    }

    /// Detects `someCall(...).navigationTitle(...)` and records `someCall`'s name.
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard
            let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self),
            memberAccess.declName.baseName.text == "navigationTitle",
            let base = memberAccess.base,
            let baseCall = base.as(FunctionCallExprSyntax.self),
            let calledName = baseCall.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
        else { return .visitChildren }

        navTitleCallSites.append(calledName)
        return .visitChildren
    }

    // MARK: - Resolution

    /// Returns the set of View type names that are externally titled in this file.
    func resolvedExternallyTitledViews() -> Set<String> {
        var result = Set<String>()
        for name in navTitleCallSites {
            if name.first?.isUppercase == true {
                // Direct view constructor: e.g. InformativeImagesWatch().navigationTitle(...)
                result.insert(name)
            } else {
                // Function call: look up its @ViewBuilder body for constructed view types
                if let viewTypes = viewBuilderBodies[name] {
                    result.formUnion(viewTypes)
                }
            }
        }
        return result
    }

    // MARK: - Helpers

    private func isViewBuilder(_ node: FunctionDeclSyntax) -> Bool {
        node.attributes.contains { attr in
            guard let attrSyntax = attr.as(AttributeSyntax.self) else { return false }
            return attrSyntax.attributeName.trimmedDescription == "ViewBuilder"
        }
    }

    /// Recursively walks `syntax` and collects names of view constructor calls —
    /// `FunctionCallExprSyntax` where the called expression is an uppercase identifier.
    private func collectViewConstructorNames(in syntax: Syntax) -> Set<String> {
        var names = Set<String>()
        for child in syntax.children(viewMode: .sourceAccurate) {
            if let call = child.as(FunctionCallExprSyntax.self),
               let name = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text,
               name.first?.isUppercase == true {
                names.insert(name)
            }
            names.formUnion(collectViewConstructorNames(in: child))
        }
        return names
    }
}
