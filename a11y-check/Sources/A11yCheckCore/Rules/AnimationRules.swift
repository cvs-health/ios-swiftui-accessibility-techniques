import SwiftSyntax

// MARK: - Reduce Motion Rule

/// Flags views that use animations (.animation(), withAnimation, .transition())
/// without checking @Environment(\.accessibilityReduceMotion).
///
/// WCAG 2.3.3 Animation from Interactions (AAA) / best practice for WCAG 2.3.1
/// Users who experience motion sickness or vestibular disorders need the ability
/// to disable non-essential animations.
public struct ReduceMotionRule: A11yRule {
    public let id = "animation-missing-reduce-motion"
    public let name = "Animation Without Reduce Motion Check"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.3.1"]
    public let description = "Animations should respect the user's Reduce Motion preference. Check @Environment(\\.accessibilityReduceMotion) or use .animation(.default, value:) which automatically respects the setting."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        var diagnostics: [A11yDiagnostic] = []
        let sourceText = context.sourceText

        // Check if the file references reduceMotion anywhere — if so, they're handling it
        let hasReduceMotionCheck = sourceText.contains("reduceMotion") ||
            sourceText.contains("UIAccessibility.isReduceMotionEnabled") ||
            sourceText.contains("ReduceMotion")

        if hasReduceMotionCheck { return [] }

        // Look for animation modifiers
        let collector = ModifierCollector.collect(from: syntax)
        for mod in collector.modifiers(named: "animation") {
            diagnostics.append(makeDiagnostic(
                message: ".animation() used without checking accessibilityReduceMotion. Users with vestibular disorders may experience discomfort. Add @Environment(\\.accessibilityReduceMotion) and conditionally disable animations.",
                node: mod.reportNode,
                context: context,
                suggestion: "Add @Environment(\\.accessibilityReduceMotion) var reduceMotion and use .animation(reduceMotion ? .none : .default, value:)"
            ))
        }

        // Look for withAnimation calls
        let withAnimVisitor = WithAnimationVisitor(viewMode: .sourceAccurate)
        withAnimVisitor.walk(syntax)
        for call in withAnimVisitor.calls {
            diagnostics.append(makeDiagnostic(
                message: "withAnimation used without checking accessibilityReduceMotion. Users with vestibular disorders may experience discomfort.",
                node: call,
                context: context,
                suggestion: "Wrap in: if !reduceMotion { withAnimation { ... } } else { ... }"
            ))
        }

        return diagnostics
    }
}

// MARK: - WithAnimation Visitor

private class WithAnimationVisitor: SyntaxVisitor {
    var calls: [FunctionCallExprSyntax] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let calledExpr = node.calledExpression.as(DeclReferenceExprSyntax.self),
           calledExpr.baseName.text == "withAnimation" {
            calls.append(node)
        }
        return .visitChildren
    }
}

// MARK: - Tab View Missing Label Rule

/// Flags TabView items that lack a .tabItem { } modifier and custom tab bar
/// containers (using `.accessibilityAddTraits(.isTabBar)`) that lack an
/// `.accessibilityLabel()` group label.
///
/// WCAG 4.1.2 Name, Role, Value
/// WCAG 2.4.2 Page Titled — tabs serve as navigation landmarks
public struct TabViewMissingLabelRule: A11yRule {
    public let id = "tabview-missing-label"
    public let name = "TabView or Custom Tab Bar Missing Label"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["4.1.2", "2.4.2"]
    public let description = "Every view inside a TabView must have a .tabItem { } modifier. Custom tab bars using .accessibilityAddTraits(.isTabBar) must have an .accessibilityLabel() so VoiceOver users hear the tab bar name."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        // Check native TabView children for missing .tabItem
        for view in visitor.views(ofType: "TabView") {
            // Skip page-style TabViews (carousels/pagers) — they use .tag(), not .tabItem
            let chainText = view.chainRoot.trimmedDescription
            if chainText.contains("PageTabViewStyle") || chainText.contains(".page") { continue }

            guard let trailingClosure = view.callExpr.trailingClosure else { continue }

            let childVisitor = DirectChildViewVisitor(viewMode: .sourceAccurate)
            childVisitor.walk(trailingClosure)

            for child in childVisitor.views {
                let childText = child.trimmedDescription
                if !childText.contains(".tabItem") && !childText.contains("tabItem(") {
                    diagnostics.append(makeDiagnostic(
                        message: "TabView child view is missing .tabItem { } modifier. VoiceOver users won't know what this tab is. Add .tabItem { Label(\"Name\", systemImage: \"icon\") }.",
                        node: child,
                        context: context,
                        suggestion: "Add .tabItem { Label(\"Tab Name\", systemImage: \"star\") }"
                    ))
                }
            }
        }

        // Check custom tab bars: containers with .isTabBar trait but no .accessibilityLabel
        let tabBarVisitor = TabBarTraitVisitor(viewMode: .sourceAccurate)
        tabBarVisitor.walk(syntax)
        for container in tabBarVisitor.containers {
            let chainText = container.trimmedDescription
            if !chainText.contains("accessibilityLabel") {
                diagnostics.append(makeDiagnostic(
                    message: "Custom tab bar with .accessibilityAddTraits(.isTabBar) is missing .accessibilityLabel(). VoiceOver users won't hear the tab bar name when entering it.",
                    node: container,
                    context: context,
                    suggestion: "Add .accessibilityLabel(\"Tab Bar Name\") to the container with .isTabBar trait"
                ))
            }
        }

        return diagnostics
    }
}

/// Finds views that have `.accessibilityAddTraits(.isTabBar)`.
private class TabBarTraitVisitor: SyntaxVisitor {
    var containers: [FunctionCallExprSyntax] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let member = node.calledExpression.as(MemberAccessExprSyntax.self),
           member.declName.baseName.text == "accessibilityAddTraits" {
            let argText = node.arguments.description
            if argText.contains("isTabBar") {
                // Walk up to find the root of the modifier chain
                var root: ExprSyntax = ExprSyntax(node)
                while let parent = root.parent {
                    if let funcCall = parent.as(FunctionCallExprSyntax.self),
                       let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
                       memberAccess.base?.id == root.id {
                        root = ExprSyntax(funcCall)
                        continue
                    }
                    if let memberAccess = parent.as(MemberAccessExprSyntax.self),
                       let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                        root = ExprSyntax(grandparent)
                        continue
                    }
                    break
                }
                if let rootCall = root.as(FunctionCallExprSyntax.self) {
                    containers.append(rootCall)
                }
            }
        }
        return .visitChildren
    }
}

/// Finds the direct child views in a closure body (top-level expressions only).
private class DirectChildViewVisitor: SyntaxVisitor {
    var views: [FunctionCallExprSyntax] = []

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        // Look for function call expressions at the top level of the closure
        if let call = node.item.as(FunctionCallExprSyntax.self) {
            views.append(call)
            return .skipChildren
        }
        return .visitChildren
    }
}
