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

    // MARK: - What counts as setting a page title

    /// Modifiers that give a screen a title VoiceOver will announce.
    ///
    /// `navigationBarTitle` is deprecated in favour of `navigationTitle`, but it still sets the
    /// title and VoiceOver still reads it, so a screen using it is titled. Treating only the
    /// modern spelling as valid reported 8 titled screens in one app as untitled — including
    /// `.navigationBarTitle(Text("Login As"))`, which a reviewer can hear announced.
    ///
    /// Migrating off the deprecated API is a worthwhile cleanup, but it is a different rule from
    /// "this screen has no title", and conflating the two sends people to fix the wrong thing.
    static let pageTitleModifiers = ["navigationTitle", "navigationBarTitle"]

    static func setsPageTitle(_ collector: ModifierCollector) -> Bool {
        pageTitleModifiers.contains { collector.hasModifier($0) }
    }

    /// As above, but also crediting a project modifier that sets the title internally.
    ///
    /// A design system typically wraps navigation chrome in one house modifier, so the screen
    /// chains `.applyNavigationChrome(title: title)` and never names `navigationTitle` itself.
    /// The pre-pass resolves those wrappers from their own bodies, so the screen reads as titled.
    ///
    /// Matched against the chain's source text rather than through `ModifierCollector`, which
    /// only gathers a fixed allowlist of known SwiftUI modifiers — a project's own modifier is
    /// never in it, so `hasModifier` can never see one.
    static func setsPageTitle(
        _ collector: ModifierCollector,
        chainText: String,
        context: RuleContext
    ) -> Bool {
        if setsPageTitle(collector) { return true }
        return context.titleSettingModifiers.contains { chainText.contains(".\($0)(") }
    }

    /// Source-text fallback for the cases that read a body as a string.
    ///
    /// Requires an opening paren so `navigationBarTitleDisplayMode(.inline)` does not count as a
    /// title. That modifier only sets *how* a title displays; a screen can carry it while having
    /// no title at all, and a plain substring check would mark exactly those screens clean.
    static func textSetsPageTitle(_ text: String) -> Bool {
        for name in pageTitleModifiers {
            // Every occurrence, not just the first: a `navigationBarTitleDisplayMode(.inline)`
            // earlier in the body would otherwise mask a real `navigationBarTitle(…)` after it.
            var searchStart = text.startIndex
            while let range = text.range(of: name, range: searchStart..<text.endIndex) {
                var index = range.upperBound
                while index < text.endIndex, text[index] == " " || text[index] == "\n" {
                    index = text.index(after: index)
                }
                if index < text.endIndex, text[index] == "(" { return true }
                searchStart = range.upperBound
            }
        }
        return false
    }

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        // Look for NavigationStack / NavigationView usage
        let navContainers = visitor.views(ofType: "NavigationStack") + visitor.views(ofType: "NavigationView")

        for nav in navContainers {
            // Skip preview-only stacks: the child view provides the title at runtime
            if isInsidePreviewContext(nav.callExpr) { continue }

            // Check if a page title appears anywhere in the navigation container's subtree
            let modCollector = ModifierCollector.collect(from: nav.chainRoot)
            let chainText = nav.chainRoot.trimmedDescription
            if !Self.setsPageTitle(modCollector, chainText: chainText, context: context) {
                // Also check the trailing closure body
                if let body = nav.callExpr.trailingClosure {
                    let bodyCollector = ModifierCollector.collect(from: body)
                    if !Self.setsPageTitle(bodyCollector, chainText: body.trimmedDescription, context: context),
                       !Self.contentIsTitledElsewhere(body, context: context) {
                        // Deliberately no autofix: a page title is content, and only the author
                        // knows what this screen is called. Inserting a literal "Page Title"
                        // shipped that string to users as the real title and VoiceOver
                        // announcement, and left the rule reporting the file as clean — a
                        // user-visible regression that hid itself from the gate.
                        diagnostics.append(makeDiagnostic(
                            message: "NavigationStack is missing .navigationTitle(). Set a page title so VoiceOver users know which page they're on.",
                            node: nav.callExpr,
                            context: context,
                            suggestion: "Add .navigationTitle(\"<this screen's name>\") on the root view inside the NavigationStack"
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
            if !Self.textSetsPageTitle(bodyText),
               !context.titleSettingModifiers.contains(where: { bodyText.contains(".\($0)(") }) {
                // No autofix, for the same reason as pattern 1 above: the title is content.
                // The suggestion still names where it goes — the first content view inside
                // ScrollView/List (e.g. the VStack), not the container itself.
                diagnostics.append(makeDiagnostic(
                    message: "This screen-level view has no .navigationTitle(). Add one so VoiceOver users know which page they're on when it is pushed onto a NavigationStack.",
                    node: rootCall,
                    context: context,
                    suggestion: "Add .navigationTitle(\"<this screen's name>\") on the content view inside the body's ScrollView or List (e.g., on VStack)"
                ))
            }
        }

        return diagnostics
    }

    // MARK: - Content whose title is set somewhere this file cannot see

    /// Whether the stack's content gets its title from somewhere other than this call.
    ///
    /// A `NavigationStack` is often a host rather than a screen, and then the title is not its
    /// to set. Three shapes, all read from declarations rather than from names:
    ///
    /// - **`self`** — a `View` extension helper such as `embeddedInNavigationStack()`. The
    ///   caller's view is the screen and titles itself.
    /// - **An injected stored property** — `let content: Content` filled by a `@ViewBuilder`
    ///   init, as in a navigation coordinator. Whatever is handed in carries the title, and the
    ///   coordinator is reused by every screen in the app.
    /// - **A view that titles itself** — `NavigationStack { IDCardView() }`, where `IDCardView`
    ///   sets `.navigationTitle(viewModel.idCardTitle)` on its own root in another file. The
    ///   screen announces correctly; only this file looks silent.
    ///
    /// A local computed property is followed one level, so `NavigationStack { mainView }` is
    /// judged on `mainView`'s body rather than on the fact that the closure is one identifier.
    static func contentIsTitledElsewhere(_ closure: ClosureExprSyntax, context: RuleContext) -> Bool {
        guard closure.statements.count == 1,
              case .expr(let expr) = closure.statements.first!.item else { return false }

        switch chainBase(of: expr) {
        case .selfReference:
            return true

        case .viewType(let name):
            return context.selfTitledViews.contains(name)

        case .identifier(let name):
            guard let decl = propertyDeclaration(named: name, near: Syntax(closure)) else {
                return false
            }
            guard let binding = decl.bindings.first else { return false }

            // Stored and uninitialised: the value arrives from outside this type.
            if binding.initializer == nil, binding.accessorBlock == nil { return true }

            // Computed: judge the property's body as if it were the closure's content.
            if SelfTitledViewScanner.setsPageTitle(Syntax(decl)) { return true }
            if let accessor = binding.accessorBlock,
               case .getter(let statements) = accessor.accessors,
               statements.count == 1,
               case .expr(let inner) = statements.first!.item,
               case .viewType(let name) = chainBase(of: inner) {
                return context.selfTitledViews.contains(name)
            }
            return false

        case .none:
            return false
        }
    }

    /// What sits at the bottom of a view's modifier chain.
    enum ChainBase {
        case selfReference
        /// A view being constructed, e.g. `IDCardView()` or `SpendingDetailView.Content(…)`.
        case viewType(String)
        /// A bare reference, e.g. `content` or `mainView`.
        case identifier(String)
        case none
    }

    static func chainBase(of expr: ExprSyntax) -> ChainBase {
        var current = expr
        while true {
            if let call = current.as(FunctionCallExprSyntax.self) {
                if let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
                    // A modifier applied to something: keep descending towards the base.
                    if let base = member.base {
                        current = base
                        continue
                    }
                    return .viewType(member.declName.baseName.text)
                }
                if let name = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                    return name.first?.isUppercase == true ? .viewType(name) : .identifier(name)
                }
                return .none
            }
            if let member = current.as(MemberAccessExprSyntax.self) {
                if let base = member.base { current = base; continue }
                return .none
            }
            if let reference = current.as(DeclReferenceExprSyntax.self) {
                let name = reference.baseName.text
                if name == "self" { return .selfReference }
                return name.first?.isUppercase == true ? .viewType(name) : .identifier(name)
            }
            return .none
        }
    }

    /// The declaration of a property with this name in the type enclosing `node`.
    ///
    /// Searched from the enclosing declaration outwards, so an extension's own members are
    /// found before the type's. Extensions are common here: the body that hosts the stack and
    /// the property it renders are often declared in separate `private extension` blocks.
    static func propertyDeclaration(named name: String, near node: Syntax) -> VariableDeclSyntax? {
        var current: Syntax? = node
        while let scope = current {
            let members: MemberBlockItemListSyntax?
            if let s = scope.as(StructDeclSyntax.self) {
                members = s.memberBlock.members
            } else if let e = scope.as(ExtensionDeclSyntax.self) {
                members = e.memberBlock.members
            } else if let c = scope.as(ClassDeclSyntax.self) {
                members = c.memberBlock.members
            } else {
                members = nil
            }
            if let members {
                for member in members {
                    guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                          let binding = varDecl.bindings.first,
                          binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == name
                    else { continue }
                    return varDecl
                }
            }
            current = scope.parent
        }
        return nil
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
