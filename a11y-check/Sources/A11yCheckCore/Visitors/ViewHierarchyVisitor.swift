import SwiftSyntax

/// Identifies SwiftUI view construction calls (Image, Button, Toggle, etc.)
/// and collects information about modifier chains applied to them.
///
/// This visitor walks the AST and for each recognized SwiftUI view call, records:
/// - The view type (Image, Button, Toggle, etc.)
/// - The call site node
/// - All modifiers in the chain above it
public final class ViewHierarchyVisitor: SyntaxVisitor {

    /// Known SwiftUI view types to detect.
    public static let recognizedViews: Set<String> = [
        "Image", "Button", "Toggle", "Link", "Text", "Label",
        "TextField", "SecureField", "TextEditor",
        "Slider", "Stepper", "Picker", "DatePicker", "ColorPicker",
        "NavigationStack", "NavigationView", "NavigationLink", "NavigationSplitView",
        "TabView", "List", "ScrollView",
        "HStack", "VStack", "ZStack", "LazyHStack", "LazyVStack",
        "Form", "Section", "Group", "GroupBox",
        "Menu", "DisclosureGroup",
        "ProgressView", "Gauge",
        "Sheet", "Alert",
        "Map",
    ]

    /// A detected SwiftUI view node with its modifier chain context.
    public struct DetectedView {
        /// The view type name (e.g. "Image", "Button"). For an aliased wrapper this is the
        /// view it stands in for, so rules match on it unchanged.
        public let viewType: String
        /// The name as written at the call site. Differs from `viewType` only for an aliased
        /// wrapper — `IconView` aliased to `Image` reports `viewType: "Image"`,
        /// `sourceViewType: "IconView"` — so a message can name what the author actually wrote.
        public let sourceViewType: String
        /// The function call expression that constructs this view.
        public let callExpr: FunctionCallExprSyntax
        /// Whether this is using the `Image(decorative:)` initializer.
        public let isDecorativeImage: Bool
        /// Whether this is using `Image(systemName:)`.
        public let isSystemImage: Bool
        /// The first string argument (e.g. label text for Button/Toggle, name for Image).
        public let firstStringArgument: String?
        /// Modifiers collected from the chain this view is part of.
        public let modifiers: ModifierCollector
        /// The outermost expression in the modifier chain (for getting full chain context).
        public let chainRoot: ExprSyntax

        /// Whether the call site has a named argument with the given label (e.g. `prompt:`).
        public func hasNamedArgument(_ label: String) -> Bool {
            callExpr.arguments.contains { $0.label?.text == label }
        }
    }

    /// All detected views in the file.
    public private(set) var detectedViews: [DetectedView] = []

    /// Design-system wrapper name → the recognized view it stands in for.
    ///
    /// Aliasing happens here rather than in each rule, so a wrapper is reported under the type
    /// it renders and every existing rule sees it with no change: alias `IconView` to `Image`
    /// and the image rules examine `IconView(` call sites exactly as they would an `Image(`.
    /// The detected view keeps its real name in `sourceViewType` for diagnostic messages.
    public let viewAliases: [String: String]

    public init(viewAliases: [String: String] = [:]) {
        self.viewAliases = viewAliases
        super.init(viewMode: .sourceAccurate)
    }

    public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        let viewType: String
        let calledExpr = node.calledExpression

        // Direct call: Image("name"), Button("label") { }
        let sourceViewType: String
        if let identifier = calledExpr.as(DeclReferenceExprSyntax.self) {
            let name = identifier.baseName.text
            guard let resolved = resolve(name) else {
                return .visitChildren
            }
            viewType = resolved
            sourceViewType = name
        }
        // Member access call: Image.init(...) — rare but possible
        else if let memberAccess = calledExpr.as(MemberAccessExprSyntax.self),
                let base = memberAccess.base?.as(DeclReferenceExprSyntax.self),
                let resolved = resolve(base.baseName.text),
                memberAccess.declName.baseName.text == "init" {
            viewType = resolved
            sourceViewType = base.baseName.text
        }
        else {
            return .visitChildren
        }

        // Determine if this is already inside a modifier chain being analyzed
        // Walk up to find the outermost chained expression
        let chainRoot = findChainRoot(for: ExprSyntax(node))

        // Collect modifiers from the chain root
        let modifiers = ModifierCollector.collect(from: chainRoot)

        // Analyze Image-specific initializers
        var isDecorative = false
        var isSystemImage = false
        var firstString: String? = nil

        if viewType == "Image" {
            for arg in node.arguments {
                if arg.label?.text == "decorative" {
                    isDecorative = true
                    firstString = extractStringLiteral(from: arg.expression)
                } else if arg.label?.text == "systemName" {
                    isSystemImage = true
                    firstString = extractStringLiteral(from: arg.expression)
                } else if arg.label == nil {
                    firstString = extractStringLiteral(from: arg.expression)
                }
            }
        } else {
            // For other views, grab the first string argument (typically the label)
            firstString = extractStringLiteral(from: node.arguments.first?.expression)
        }

        detectedViews.append(DetectedView(
            viewType: viewType,
            sourceViewType: sourceViewType,
            callExpr: node,
            isDecorativeImage: isDecorative,
            isSystemImage: isSystemImage,
            firstStringArgument: firstString,
            modifiers: modifiers,
            chainRoot: chainRoot
        ))

        return .visitChildren
    }

    /// Walk up the AST from a function call to find the outermost expression
    /// in a fluent modifier chain like `Image("x").accessibilityLabel("y").frame(...)`.
    /// Modifier chains that cross `#if` / `#endif` are followed by walking through
    /// the conditional expression so modifiers after `#endif` (e.g. `.accessibilityLabel`) are included.
    private func findChainRoot(for expr: ExprSyntax) -> ExprSyntax {
        var current = expr
        while let parent = current.parent {
            // If the parent is a MemberAccessExpr (`.modifier`), keep going up
            if let memberAccess = parent.as(MemberAccessExprSyntax.self) {
                if let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                    if memberAccess.base?.id == current.id {
                        // We're the base of this modifier — step to the modifier call
                        current = ExprSyntax(grandparent)
                        continue
                    }
                    // Base is conditional compilation (#if / #endif) — walk through so we include modifiers after it
                    if let base = memberAccess.base, Syntax(base).kind == .postfixIfConfigExpr {
                        current = base
                        continue
                    }
                }
            }
            // If the parent is a FunctionCallExpr wrapping our current node as the callee's base
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

    private func extractStringLiteral(from expr: ExprSyntax?) -> String? {
        guard let expr = expr else { return nil }
        if let stringLiteral = expr.as(StringLiteralExprSyntax.self) {
            return stringLiteral.segments.map { segment -> String in
                if let text = segment.as(StringSegmentSyntax.self) {
                    return text.content.text
                }
                return ""
            }.joined()
        }
        return nil
    }
}

// MARK: - Convenience

extension ViewHierarchyVisitor {
    /// Get all detected views of a specific type.
    public func views(ofType type: String) -> [DetectedView] {
        detectedViews.filter { $0.viewType == type }
    }

    /// Analyze a syntax tree and return the visitor with results.
    public static func analyze(
        _ syntax: some SyntaxProtocol,
        viewAliases: [String: String] = [:]
    ) -> ViewHierarchyVisitor {
        let visitor = ViewHierarchyVisitor(viewAliases: viewAliases)
        visitor.walk(syntax)
        return visitor
    }

    /// The recognized view this call name stands for, or `nil` if it is not a view.
    ///
    /// A name a rule already knows wins over an alias, so a project cannot accidentally
    /// redefine `Image` or `Button` out from under the rules.
    private func resolve(_ name: String) -> String? {
        if Self.recognizedViews.contains(name) { return name }
        return viewAliases[name]
    }
}
