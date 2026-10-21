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

/// Finds project modifiers that set a page title on the caller's behalf.
///
/// A design system usually wraps navigation chrome in one house modifier:
///
///     extension View {
///         func applyNavigationChrome(title: String?, …) -> some View {
///             navigationTitle(title ?? "")
///                 .navigationBarTitleDisplayMode(.inline)
///         }
///     }
///
/// A screen calling `.applyNavigationChrome(title: title)` is titled, but a rule looking only
/// for `navigationTitle` at the call site reads it as untitled. Collecting these names lets the
/// page-title rule credit the wrapper.
///
/// Resolved from the wrapper's own body rather than from configuration: the evidence that it
/// sets a title is the `navigationTitle` call inside it, which is more reliable than a
/// hand-maintained list and needs no project setup.
enum TitleModifierScanner {

    /// Functions whose body sets a page title, keyed by name.
    static func scan(_ syntax: SourceFileSyntax) -> Set<String> {
        let visitor = Visitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)
        return visitor.names
    }

    private final class Visitor: SyntaxVisitor {
        var names: Set<String> = []

        override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
            // Must return a view, otherwise it is not a modifier the caller chains.
            guard let returnType = node.signature.returnClause?.type.trimmedDescription,
                  returnType.contains("View"),
                  let body = node.body
            else { return .visitChildren }

            // The body must call a title-setting modifier. Checked as a member access so that a
            // parameter merely *named* `title` does not qualify, and `navigationBarTitleDisplayMode`
            // does not either — that sets how a title displays, not the title.
            let setsTitle = TitleCallFinder.containsTitleCall(Syntax(body))
            if setsTitle {
                names.insert(node.name.text)
            }
            return .visitChildren
        }
    }

    private enum TitleCallFinder {
        static func containsTitleCall(_ node: Syntax) -> Bool {
            if let call = node.as(FunctionCallExprSyntax.self) {
                let callee: String? = {
                    if let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
                        return member.declName.baseName.text
                    }
                    if let ref = call.calledExpression.as(DeclReferenceExprSyntax.self) {
                        return ref.baseName.text
                    }
                    return nil
                }()
                if let callee, callee == "navigationTitle" || callee == "navigationBarTitle" {
                    return true
                }
            }
            for child in node.children(viewMode: .sourceAccurate) {
                if containsTitleCall(child) { return true }
            }
            return false
        }
    }
}
