import SwiftSyntax

/// Collects file-local colour constants so rules can see through an identifier to the
/// colour it holds.
///
/// Storing a colour in a property is idiomatic SwiftUI:
///
/// ```swift
/// private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
/// // …
/// Text("Total").foregroundColor(darkGreen)
/// ```
///
/// Without this, colour rules only ever see the identifier `darkGreen`, so both the
/// contrast calculation and the hardcoded-colour check silently skip the view.
public final class ColorConstantCollector: SyntaxVisitor {
    /// Identifier name to the source text of its colour initialiser.
    private(set) public var constants: [String: String] = [:]

    public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    /// Collect every `let`/`var` in the file whose initialiser looks like a colour.
    public static func collect(from syntax: SourceFileSyntax) -> [String: String] {
        let collector = ColorConstantCollector()
        collector.walk(syntax)
        return collector.constants
    }

    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for binding in node.bindings {
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
            let name = pattern.identifier.text

            // `var foo = Color(...)` — a plain initialiser.
            if let initializer = binding.initializer {
                let text = initializer.value.trimmedDescription
                if Self.looksLikeColor(text) {
                    constants[name] = text
                }
                continue
            }

            // `var foo: Color { Color(...) }` — a single-expression computed property.
            if let accessor = binding.accessorBlock,
               let text = Self.singleExpressionBody(of: accessor),
               Self.looksLikeColor(text) {
                constants[name] = text
            }
        }
        return .visitChildren
    }

    /// The sole expression of a computed property body, if it has exactly one statement.
    private static func singleExpressionBody(of accessor: AccessorBlockSyntax) -> String? {
        guard case .getter(let statements) = accessor.accessors else { return nil }
        guard statements.count == 1, let only = statements.first else { return nil }
        return only.item.trimmedDescription
    }

    /// Whether an initialiser is worth recording as a colour.
    ///
    /// Deliberately permissive: `ColorParser` is the authority on whether the text
    /// resolves to an actual value, so this only has to avoid storing obvious non-colours.
    private static func looksLikeColor(_ text: String) -> Bool {
        if text.hasPrefix("Color(") || text.hasPrefix("Color.") { return true }
        if text.hasPrefix("UIColor(") || text.hasPrefix("UIColor.") { return true }
        // Bare member access such as `.white`, but not `.someFunction()`.
        if text.hasPrefix(".") && !text.contains("(") { return true }
        return false
    }

    /// Resolve a modifier argument to a colour expression, following one level of
    /// indirection through a file-local constant.
    ///
    /// Returns `expression` unchanged when it is already a colour literal, or when the
    /// identifier is unknown — callers still pass the result to `ColorParser`, which
    /// decides whether it means anything.
    public static func resolve(_ expression: String, constants: [String: String]) -> String {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        // A colour literal resolves to itself.
        if trimmed.hasPrefix("Color(") || trimmed.hasPrefix("Color.") { return trimmed }

        // Bare identifiers, optionally qualified with self. or Self.
        var identifier = trimmed
        for prefix in ["self.", "Self."] where identifier.hasPrefix(prefix) {
            identifier = String(identifier.dropFirst(prefix.count))
        }
        guard identifier.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) else { return trimmed }

        return constants[identifier] ?? trimmed
    }
}
