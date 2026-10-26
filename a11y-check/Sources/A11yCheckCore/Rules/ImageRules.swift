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

// MARK: - Image Missing Label Rule

/// Flags `Image(systemName:)` or `Image("name")` that lack `.accessibilityLabel()`
/// and are not marked as decorative via `Image(decorative:)` or `.accessibilityHidden(true)`.
/// Skips images that are inside a Button or Link that has .accessibilityLabel() — the button's label is the accessible name.
///
/// WCAG 1.1.1 Non-text Content
/// Reference: InformativeView.swift, DecorativeView.swift, FunctionalView.swift
public struct ImageMissingLabelRule: A11yRule {
    public let id = "image-missing-label"
    public let name = "Image Missing Accessibility Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.critical
    public let wcagCriteria = ["1.1.1"]
    public let description = "Non-decorative images must have an .accessibilityLabel() or use Image(decorative:)."

    public init() {}

    private static let labelConsumerViews: Set<String> = ["Button", "Link", "NavigationLink", "ShareLink", "ToolbarItem", "Menu", "PhotosPicker"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        // A wrapper aliased in via `view_aliases` only means anything in a SwiftUI file. The
        // same name may belong to a UIView elsewhere in the project, and reading UIKit code as
        // if it were SwiftUI reports nonsense — aliasing one such name produced 16 false
        // positives on a real codebase before this guard.
        let isSwiftUIFile = context.sourceText.contains("import SwiftUI")

        for view in visitor.views(ofType: "Image") {
            // Skip decorative images — they're intentionally unlabeled
            if view.isDecorativeImage { continue }

            let isAliasedWrapper = view.sourceViewType != "Image"
            if isAliasedWrapper {
                guard isSwiftUIFile else { continue }
                // The design system may attach the accessible name to the token rather than
                // the call site, in which case the component already announces it.
                if mentionsLabelledToken(view.callExpr, labelled: context.labelledTokens) { continue }
            }

            let mods = view.modifiers

            // Skip if hidden from accessibility
            if hasAccessibilityHidden(mods) { continue }

            // Skip if it has an accessibility label
            if mods.hasModifier("accessibilityLabel") { continue }

            // Skip if the parent chain has .accessibilityElement(children: .combine)
            // since the parent may provide the label
            if hasAccessibilityElementCombine(mods) { continue }

            // Skip if image is inside a Button/Link that has .accessibilityLabel() — the button's label is the accessible name
            if isImageInsideLabeledButtonOrLink(view.callExpr) { continue }

            // Skip if image is inside a label: closure — VoiceOver groups the entire label as one element
            if isInsideLabelClosure(view.callExpr) { continue }

            // Skip if an ancestor container manages this image's accessibility:
            // .accessibilityElement(children: .ignore/.combine) absorbs children into
            // one element, or .accessibilityHidden(true) removes the subtree entirely.
            // This is the correct pattern for components that expose a single accessible
            // representation (e.g. a card component with .accessibilityLabel on the root).
            if isInsideAccessiblyManagedAncestor(view.callExpr) { continue }

            // Skip if the enclosing component struct has a stored property of type `Image` —
            // the image was injected from outside and the caller controls its accessibility.
            if enclosingStructHasImageProperty(view.callExpr) { continue }

            // Skip an Image being produced as an `Image` *value* rather than placed in a view
            // hierarchy: `extension Image { init(illustration:) }`, or
            // `func image(for option: Option) -> Image`. The label depends on what the caller
            // uses it for, so it cannot be known here — the same reasoning as the injected-Image
            // case above, for the factory shape instead of the stored-property shape.
            if Self.producesImageAsValue(view.callExpr) { continue }

            // Skip an Image handed to something else as a value — passed as an argument, or
            // composed into a Text run — where a label cannot be attached here.
            if Self.isTextAttachment(view.callExpr) { continue }
            if Self.isImageUsedAsValue(view.callExpr) { continue }

            // Skip if the enclosing component struct has a stored property named
            // `accessibilityLabel` — the component is designed to receive a label from its caller.
            if enclosingStructHasAccessibilityLabelProperty(view.callExpr) { continue }

            // Name what the author wrote. For a wrapper mapped in via `view_aliases`,
            // `Image(decorative:)` is not available to the caller, so only offer the advice
            // that applies to the call site.
            let message = isAliasedWrapper
                ? "\(view.sourceViewType) renders an image and is missing .accessibilityLabel(). Add a descriptive label, or .accessibilityHidden(true) if the icon is decorative."
                : "Image is missing .accessibilityLabel(). Add a descriptive label or use Image(decorative:) / .accessibilityHidden(true) for decorative images."
            let suggestion = isAliasedWrapper
                ? "Add .accessibilityLabel(\"description\") or .accessibilityHidden(true)"
                : "Add .accessibilityLabel(\"description\") or use Image(decorative:)"
            diagnostics.append(makeDiagnostic(
                message: message,
                node: view.callExpr,
                context: context,
                suggestion: suggestion
            ))
        }
        return diagnostics
    }

    /// Whether any token named at this call site carries its own accessibility label.
    ///
    /// Reads every member-access name in the arguments, so `IconView(.messaging(.errorFill))`
    /// is checked for both `messaging` and `errorFill`. A match means the design system
    /// supplies the accessible name and the call site is not at fault.
    private func mentionsLabelledToken(_ callExpr: FunctionCallExprSyntax, labelled: Set<String>) -> Bool {
        guard !labelled.isEmpty else { return false }
        var found = false
        func walk(_ node: Syntax) {
            if found { return }
            if let member = node.as(MemberAccessExprSyntax.self),
               labelled.contains(member.declName.baseName.text) {
                found = true
                return
            }
            for child in node.children(viewMode: .sourceAccurate) { walk(child) }
        }
        for arg in callExpr.arguments { walk(Syntax(arg)) }
        return found
    }

    /// True if an ancestor view in the same file manages this image's accessibility, meaning
    /// the image does not need its own label. Handles two patterns:
    ///   1. `.accessibilityElement(children: .ignore)` or `.combine` on an ancestor — the
    ///      container collapses its children into a single accessible element.
    ///   2. `.accessibilityHidden(true)` on an ancestor — the entire subtree is hidden.
    /// This is the correct pattern for reusable components (cards, list rows, etc.) that
    /// expose one accessible name via the root view rather than labeling each sub-image.
    private func isInsideAccessiblyManagedAncestor(_ imageCallExpr: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(imageCallExpr).parent
        while let node = current {
            if let call = node.as(FunctionCallExprSyntax.self) {
                let chainRoot = findChainRoot(for: ExprSyntax(call))
                let mods = ModifierCollector.collect(from: chainRoot)
                if hasAccessibilityHidden(mods) { return true }
                if hasAccessibilityElementIgnoreOrCombine(mods) { return true }
            }
            current = node.parent
        }
        return false
    }

    /// True if the struct enclosing this Image has a stored property of type `Image`,
    /// meaning the component accepts an image from its caller who is responsible for
    /// setting its accessibility label at the call site.
    /// Whether this `Image(...)` is being produced as an `Image` value for a caller to use,
    /// rather than rendered as a view here.
    ///
    /// Two shapes, both of which put the accessible name beyond this call site's knowledge:
    ///
    ///   extension Image { init(illustration: Illustration) { self = Image(decorative: …) } }
    ///   func image(for option: Option) -> Image { Image(option.assetName) }
    ///
    /// The returning declaration must be typed `Image` exactly. `-> some View` is a view being
    /// rendered and stays reportable, which is the distinction that keeps this narrow.
    /// Whether this `Image(...)` is being handed to something else as a value rather than
    /// rendered here.
    ///
    /// Two shapes, both unactionable at this call site:
    ///
    ///   ToolTip(image: Image("icon_quality_badge"), title: text)   // argument to a call
    ///   Text(Image(systemName: "figure.roll"))                     // inline text attachment
    ///
    /// `.accessibilityLabel` cannot be applied to an `Image` — it returns `some View` — so where
    /// an `Image` is what the parameter expects, the author physically cannot attach a label
    /// without changing the API. One real case carried a
    /// `// swiftlint:disable:next accessibility_label_for_image` comment saying exactly that.
    /// The receiving component is where the label belongs, and the rule already exempts that
    /// side via `enclosingStructHasImageProperty`; this is the symmetric case.
    ///
    /// For `Text(Image(...))` the glyph is composed into the text run, so the accessible name
    /// comes from the `Text` — which is also the only thing a label could attach to.
    static func isImageUsedAsValue(_ node: FunctionCallExprSyntax) -> Bool {
        guard let parent = node.parent else { return false }

        // Argument to a call: `image: Image(...)` or `.image(Image(...))`.
        if let argument = parent.as(LabeledExprSyntax.self) {
            // A trailing `label:`/`icon:` closure is handled by isInsideLabelClosure; anything
            // else passing an Image along is a value.
            if let label = argument.label?.text, label == "label" || label == "icon" {
                return false
            }
            return argument.parent?.parent?.is(FunctionCallExprSyntax.self) == true
        }
        return false
    }

    /// Whether this `Image(...)` is the argument of a `Text(...)` initialiser.
    static func isTextAttachment(_ node: FunctionCallExprSyntax) -> Bool {
        guard let argument = node.parent?.as(LabeledExprSyntax.self),
              let list = argument.parent?.as(LabeledExprListSyntax.self),
              let call = list.parent?.as(FunctionCallExprSyntax.self),
              let callee = call.calledExpression.as(DeclReferenceExprSyntax.self)
        else { return false }
        return callee.baseName.text == "Text"
    }

    static func producesImageAsValue(_ node: FunctionCallExprSyntax) -> Bool {
        var cursor: Syntax? = Syntax(node).parent
        while let current = cursor {
            // `extension Image { … }` — every Image built inside is a value for the caller.
            if let ext = current.as(ExtensionDeclSyntax.self) {
                return ext.extendedType.trimmedDescription == "Image"
            }
            // A function or computed property that hands back an `Image` value.
            //
            // Deliberately checked before the `extension Image` case above is reached: a member
            // of that extension returning `some View` *is* a view and can carry a label, so the
            // narrower declaration wins over the enclosing extension.
            if let fn = current.as(FunctionDeclSyntax.self) {
                return Self.isImageValueType(fn.signature.returnClause?.type)
            }
            if let binding = current.as(PatternBindingSyntax.self),
               let annotation = binding.typeAnnotation?.type {
                return Self.isImageValueType(annotation)
            }
            // Stop at a type boundary: a view struct's body is not a factory.
            if current.is(StructDeclSyntax.self) || current.is(ClassDeclSyntax.self) {
                return false
            }
            cursor = current.parent
        }
        return false
    }

    /// Whether a declared type hands back an `Image` value rather than a view.
    ///
    /// The optional spellings matter, and an exact `== "Image"` comparison missed them. A model
    /// exposing `var swiftUIImage: Image? { … return Image(illustration: .hospital) … }` was
    /// reported nine times in one file, and the advice could not be followed at all:
    /// `.accessibilityLabel` is declared on `View` and returns `some View`, so adding it inside
    /// a property typed `Image?` does not compile. The label belongs to whoever renders the
    /// value — the same illustration is meaningful on one screen and decorative on another.
    static func isImageValueType(_ type: TypeSyntax?) -> Bool {
        guard let type else { return false }
        var text = type.trimmedDescription

        // `Image?` / `Image!`
        while text.hasSuffix("?") || text.hasSuffix("!") { text.removeLast() }
        // `Optional<Image>`
        if text.hasPrefix("Optional<"), text.hasSuffix(">") {
            text = String(text.dropFirst("Optional<".count).dropLast())
        }
        // `SwiftUI.Image`
        if text.hasPrefix("SwiftUI.") { text = String(text.dropFirst("SwiftUI.".count)) }

        return text.trimmingCharacters(in: .whitespaces) == "Image"
    }

    private func enclosingStructHasImageProperty(_ node: FunctionCallExprSyntax) -> Bool {
        guard let structDecl = enclosingStructDecl(from: Syntax(node)) else { return false }
        return structHasPropertyOfType("Image", in: structDecl)
    }

    /// True if the struct enclosing this Image has a stored property named `accessibilityLabel`,
    /// meaning the component is explicitly designed to receive a label from its caller.
    private func enclosingStructHasAccessibilityLabelProperty(_ node: FunctionCallExprSyntax) -> Bool {
        guard let structDecl = enclosingStructDecl(from: Syntax(node)) else { return false }
        return structHasPropertyNamed("accessibilityLabel", in: structDecl)
    }

    /// Walk up the AST to find the innermost enclosing struct declaration.
    private func enclosingStructDecl(from node: Syntax) -> StructDeclSyntax? {
        var current: Syntax? = node.parent
        while let n = current {
            if let structDecl = n.as(StructDeclSyntax.self) { return structDecl }
            current = n.parent
        }
        return nil
    }

    /// True if the struct has a stored `var`/`let` property whose type annotation is `typeName`.
    private func structHasPropertyOfType(_ typeName: String, in structDecl: StructDeclSyntax) -> Bool {
        for member in structDecl.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
            for binding in varDecl.bindings {
                if binding.typeAnnotation?.type.trimmedDescription == typeName { return true }
            }
        }
        return false
    }

    /// True if the struct has a stored `var`/`let` property whose name is `name`.
    private func structHasPropertyNamed(_ name: String, in structDecl: StructDeclSyntax) -> Bool {
        for member in structDecl.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
            for binding in varDecl.bindings {
                if let id = binding.pattern.as(IdentifierPatternSyntax.self),
                   id.identifier.text == name { return true }
            }
        }
        return false
    }

    /// True if this Image is inside a Button or Link that has .accessibilityLabel() (or equivalent).
    private func isImageInsideLabeledButtonOrLink(_ imageCallExpr: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(imageCallExpr).parent
        while let node = current {
            if let call = node.as(FunctionCallExprSyntax.self) {
                let viewName: String? = {
                    if let ref = call.calledExpression.as(DeclReferenceExprSyntax.self) {
                        return ref.baseName.text
                    }
                    if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
                       let base = member.base?.as(DeclReferenceExprSyntax.self),
                       member.declName.baseName.text == "init" {
                        return base.baseName.text
                    }
                    return nil
                }()
                if let name = viewName, Self.labelConsumerViews.contains(name) {
                    let chainRoot = findChainRoot(for: ExprSyntax(call))
                    let mods = ModifierCollector.collect(from: chainRoot)
                    if mods.hasModifier("accessibilityLabel") {
                        return true
                    }
                }
            }
            current = node.parent
        }
        return false
    }

    /// Walk up from a function call to the outermost expression in its modifier chain.
    private func findChainRoot(for expr: ExprSyntax) -> ExprSyntax {
        var current = expr
        while let parent = current.parent {
            if let memberAccess = parent.as(MemberAccessExprSyntax.self),
               let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                current = ExprSyntax(grandparent)
                continue
            }
            if let funcCall = parent.as(FunctionCallExprSyntax.self),
               let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
               memberAccess.base?.id == current.id {
                current = ExprSyntax(funcCall)
                continue
            }
            break
        }
        return current
    }
}

// MARK: - Image Label Contains "Image" Rule

/// Flags `.accessibilityLabel()` values that contain words like "image", "icon",
/// or "graphic" — the accessibility trait already conveys this.
/// Words like "photo" and "picture" are valid descriptive terms, not roles.
///
/// WCAG 1.1.1 Non-text Content
/// Reference: InformativeImages.md — "Don't include 'Image' in label"
public struct ImageLabelContainsImageRule: A11yRule {
    public let id = "image-label-contains-role"
    public let name = "Image Label Contains Role Word"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.minor
    public let wcagCriteria = ["1.1.1"]
    public let description = "Accessibility labels should not contain the word 'image', 'icon', or 'graphic' — the role is announced automatically."

    public init() {}

    /// Role words that VoiceOver announces automatically and should not appear in labels.
    private static let roleWords = ["image", "icon", "graphic"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "Image") {
            let labels = view.modifiers.modifiers(named: "accessibilityLabel")
            for label in labels {
                guard let text = label.firstStringArgument else { continue }
                let lower = text.lowercased()
                for word in Self.roleWords {
                    if lower.contains(word) {
                        let fix = makeStringReplacementFix(
                            callExpr: label.callExpr,
                            originalText: text,
                            word: word,
                            sourceFile: syntax
                        )
                        diagnostics.append(makeDiagnostic(
                            message: "Accessibility label \"\(text)\" contains '\(word)'. The Image role is announced automatically by VoiceOver — remove the role word from the label.",
                            node: label.reportNode,
                            context: context,
                            fix: fix,
                            suggestion: "Remove \"\(word)\" from the accessibility label"
                        ))
                        break
                    }
                }
            }
        }
        return diagnostics
    }
}

// MARK: - Helpers

/// Check if a modifier collection includes `.accessibilityHidden(true)`.
func hasAccessibilityHidden(_ mods: ModifierCollector) -> Bool {
    mods.modifiers(named: "accessibilityHidden").contains { mod in
        mod.firstStringArgument == nil && mod.arguments.first?.text == "true"
    }
}

/// Check if a modifier collection includes `.accessibilityElement(children: .combine)`.
func hasAccessibilityElementCombine(_ mods: ModifierCollector) -> Bool {
    mods.modifiers(named: "accessibilityElement").contains { mod in
        mod.arguments.contains { $0.label == "children" && $0.text.contains("combine") }
    }
}

/// Check if a modifier collection includes `.accessibilityElement(children: .ignore)` or `.combine`.
/// Both collapse children into the container's accessible representation so individual
/// sub-views don't need their own labels.
func hasAccessibilityElementIgnoreOrCombine(_ mods: ModifierCollector) -> Bool {
    mods.modifiers(named: "accessibilityElement").contains { mod in
        mod.arguments.contains { $0.label == "children" && ($0.text.contains("ignore") || $0.text.contains("combine")) }
    }
}

/// Check if a node is inside a `label:` or `icon:` closure parameter (e.g.
/// `Menu { } label: { … }`, `Label { Text(…) } icon: { Image(…) }`).
/// Views inside these closures are grouped as a single accessibility element by VoiceOver,
/// so they don't need individual labels or manual grouping.
///
/// `icon:` is included because a `Label`'s title is already its accessible name, which makes the
/// icon decorative by construction — `Label { Text("More info") } icon: { Image("icon_info") }`
/// announces "More info" and nothing about the glyph. Both spellings of the initialiser reach
/// here: the trailing-closure form and the comma form `Label(title:icon:)`.
func isInsideLabelClosure(_ node: some SyntaxProtocol) -> Bool {
    let composingLabels: Set<String> = ["label", "icon"]
    var current: Syntax? = Syntax(node).parent
    while let parent = current {
        if let trailing = parent.as(MultipleTrailingClosureElementSyntax.self),
           composingLabels.contains(trailing.label.text) {
            return true
        }
        if let arg = parent.as(LabeledExprSyntax.self),
           let label = arg.label?.text, composingLabels.contains(label) {
            return true
        }
        current = parent.parent
    }
    return false
}
