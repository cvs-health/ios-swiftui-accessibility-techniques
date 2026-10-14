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

/// Collects file-local font constants so rules can see through an identifier to the font
/// it holds.
///
/// Passing a font in rather than writing it inline is idiomatic for reusable components:
///
/// ```swift
/// struct InformationBannerView: View {
///     let titleFont: Font
///     let subtitleFont: Font
///
///     init(titleFont: Font = .themeHeadingM, subtitleFont: Font = .themeParagraphXS) { … }
///     // …
///     Text(subtitle).font(subtitleFont)
/// }
/// ```
///
/// Without this, a font rule only ever sees the identifier `subtitleFont` and has to guess
/// from its name — which is wrong in both directions. `subtitleFont` holds a *paragraph*
/// token and is not a heading; `titleFont` holds a heading token in some components and a
/// paragraph token in others. The name is not the evidence; the declared value is.
///
/// Note the init-parameter default above: for a component like this the stored property
/// carries no initialiser, so the only place the font appears is the signature. A collector
/// that looked at `let`/`var` alone would resolve nothing here.
public final class FontConstantCollector: SyntaxVisitor {
    /// Identifier name to the source text of its font expression.
    private(set) public var constants: [String: String] = [:]

    /// Names declared twice in one file with different fonts. Resolution has no way to tell
    /// which declaration a given call site meant, so these are dropped rather than guessed:
    /// the caller falls back to the unresolved expression.
    private var ambiguous: Set<String> = []

    public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    /// Collect every `let`/`var` and init-parameter default in the file whose value looks
    /// like a font.
    public static func collect(from syntax: some SyntaxProtocol) -> [String: String] {
        let collector = FontConstantCollector()
        collector.walk(syntax)
        return collector.constants
    }

    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for binding in node.bindings {
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
            let name = pattern.identifier.text

            // `var titleFont = Font.themeHeadingM` — a plain initialiser.
            if let initializer = binding.initializer {
                record(name: name, text: initializer.value.trimmedDescription)
                continue
            }

            // `var titleFont: Font { .themeHeadingM }` — a single-expression computed property.
            if let accessor = binding.accessorBlock,
               let text = Self.singleExpressionBody(of: accessor) {
                record(name: name, text: text)
            }
        }
        return .visitChildren
    }

    /// `init(titleFont: Font = .themeHeadingM)` — the default value of a parameter.
    ///
    /// Recorded for any function, not just `init`: a view builder helper taking
    /// `font: Font = .themeHeadingL` reads the same way at the call site.
    public override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        guard let defaultValue = node.defaultValue else { return .visitChildren }
        let name = (node.secondName ?? node.firstName).text
        record(name: name, text: defaultValue.value.trimmedDescription)
        return .visitChildren
    }

    /// Store a candidate.
    ///
    /// A stored property and an init parameter of the same name are the same font, so a
    /// repeat of the same value is fine. Two *different* fonts under one name — which happens
    /// when one file holds several components that each have their own `titleFont` — cannot be
    /// told apart from the call site, so the name is marked ambiguous and resolution leaves it
    /// alone. Letting declaration order decide would silently attach one component's type
    /// scale to another's text.
    private func record(name: String, text: String) {
        guard Self.looksLikeFont(text), !ambiguous.contains(name) else { return }
        if let existing = constants[name] {
            if existing != text {
                constants[name] = nil
                ambiguous.insert(name)
            }
            return
        }
        constants[name] = text
    }

    /// The sole expression of a computed property body, if it has exactly one statement.
    private static func singleExpressionBody(of accessor: AccessorBlockSyntax) -> String? {
        guard case .getter(let statements) = accessor.accessors else { return nil }
        guard statements.count == 1, let only = statements.first else { return nil }
        return only.item.trimmedDescription
    }

    /// Whether a value is worth recording as a font.
    ///
    /// Deliberately permissive — the calling rule decides what the token means. This only
    /// has to avoid storing values that plainly are not fonts, so that resolving an
    /// identifier never swaps in something unrelated.
    private static func looksLikeFont(_ text: String) -> Bool {
        if text.hasPrefix("Font.") || text.hasPrefix("SwiftUI.Font.") { return true }
        if text.hasPrefix("Font(") { return true }
        // Bare member access such as `.themeHeadingM` or `.title`, including a chained
        // `.themeHeadingL.weight(.bold)`, but not a free function call.
        if text.hasPrefix(".") {
            let head = text.dropFirst().prefix { $0 != "." && $0 != "(" }
            return !head.isEmpty && text.dropFirst().prefix(head.count + 1).last != "("
        }
        return false
    }

    /// Resolve a modifier argument to a font expression, following one level of indirection
    /// through a file-local constant.
    ///
    /// Returns `expression` unchanged when it is already a font literal, or when the
    /// identifier is unknown — the caller still decides whether the result means anything.
    public static func resolve(_ expression: String, constants: [String: String]) -> String {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        // A font literal resolves to itself.
        if trimmed.hasPrefix(".") || trimmed.hasPrefix("Font.") || trimmed.hasPrefix("Font(") {
            return trimmed
        }

        // Bare identifiers, optionally qualified with self., Self., or a view-model property.
        var identifier = trimmed
        for prefix in ["self.", "Self."] where identifier.hasPrefix(prefix) {
            identifier = String(identifier.dropFirst(prefix.count))
        }
        // `viewModel.titleFont` — resolve on the trailing member, since the font lives on
        // the model and the rule only cares which token it is.
        if let lastDot = identifier.lastIndex(of: "."), !identifier.contains("(") {
            identifier = String(identifier[identifier.index(after: lastDot)...])
        }
        guard !identifier.isEmpty,
              identifier.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" })
        else { return trimmed }

        return constants[identifier] ?? trimmed
    }
}
