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

/// Finds `View` types that set a page title in their own body.
///
/// This is the mirror of `NavigationTitleCallSiteScanner`, which records views that *receive*
/// a title from a parent. Both facts are needed, for opposite reasons: a destination that is
/// titled by its parent should not be asked to title itself, and a navigation host wrapping a
/// view that titles itself is not untitled.
///
/// The second case is what a per-file rule cannot see. `NavigationStack { IDCardView() }` has
/// no title in its own file, and `IDCardView` sets `.navigationTitle(viewModel.idCardTitle)`
/// in another one — so the host was reported as untitled while the screen announces correctly.
///
/// Deliberately whole-type rather than root-chain only: a title set on a branch of the body,
/// inside an `if`, or on a subview the type composes still titles the screen at runtime. The
/// cost of being generous is a missed finding on a type that titles only one of several
/// branches; the cost of being strict was reporting nine titled screens as untitled.
public final class SelfTitledViewScanner: SyntaxVisitor {
    private(set) public var names: Set<String> = []

    public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    public static func scan(_ syntax: some SyntaxProtocol) -> Set<String> {
        let scanner = SelfTitledViewScanner()
        scanner.walk(syntax)
        return scanner.names
    }

    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        record(name: node.name.text, conformances: node.inheritanceClause, body: Syntax(node.memberBlock))
        return .visitChildren
    }

    public override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        // `extension IDCardView { var body: some View { … .navigationTitle(…) } }` — the title
        // lives in an extension often enough that ignoring them loses real cases. The extended
        // type's name is the last component, so `Nav.Coordinator` records as `Coordinator`.
        let extended = node.extendedType.trimmedDescription
        let name = extended.split(separator: ".").last.map(String.init) ?? extended
        if Self.setsPageTitle(Syntax(node.memberBlock)) { names.insert(name) }
        return .visitChildren
    }

    private func record(name: String, conformances: InheritanceClauseSyntax?, body: Syntax) {
        // A `View` conformance is the usual case, but a type can be a screen through a
        // typealias or an extension-declared conformance, so an absent clause is not
        // disqualifying — the title modifier is the evidence that matters.
        guard Self.setsPageTitle(body) else { return }
        names.insert(name)
    }

    /// Whether this subtree applies a real page title.
    ///
    /// `navigationBarTitleDisplayMode(.inline)` is excluded by requiring the call paren
    /// directly after the modifier name: it controls how a title displays and a screen can
    /// carry it while having no title at all.
    static func setsPageTitle(_ node: Syntax) -> Bool {
        for child in node.children(viewMode: .sourceAccurate) {
            if let call = child.as(FunctionCallExprSyntax.self),
               let member = call.calledExpression.as(MemberAccessExprSyntax.self),
               MissingNavigationTitleRule.pageTitleModifiers
                   .contains(member.declName.baseName.text) {
                return true
            }
            if setsPageTitle(child) { return true }
        }
        return false
    }
}
