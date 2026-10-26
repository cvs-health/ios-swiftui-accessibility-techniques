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

// MARK: - Reduce Motion Rule

/// Flags animation that 2.2.2 actually reaches: motion that starts on its own and then either
/// never stops or runs past five seconds.
///
/// WCAG 2.2.2 Pause, Stop, Hide (Level AA) applies to moving content that **starts
/// automatically**, lasts **more than five seconds**, and is presented alongside other
/// content. Both halves matter, and an earlier version of this rule tested neither: it
/// reported every `withAnimation` in the file. Measured against a 73-finding sample that was
/// ~5% actionable — the other 69 were brief user-initiated transitions (a selection toggle, a
/// `scrollTo`, an accordion, a load-state swap) which fail no criterion. `withAnimation` is
/// imperative, called from inside an action closure, so it is user-initiated almost by
/// construction and is close to the worst available signal.
///
/// Worse, the volume hid the real defects. The `.animation()` branch asked
/// `ModifierCollector` for a modifier it did not track, so it could never emit, and a set of
/// indefinitely rotating spinners went unreported while the incidental transitions filled the
/// report.
///
/// Two signals are decidable from source, and this rule is limited to them:
///
/// 1. **Endless repetition** — `repeatForever`, or `repeatCount:` with an infinity. Resolved
///    through a file-local constant, since a spinner usually names its animation.
/// 2. **Auto-started and long** — a `withAnimation` lexically inside `onAppear` or `task`
///    whose duration resolves to more than five seconds.
///
/// Known limits, both of which under-report rather than invent:
/// - An animation re-triggered by a repeating `Timer` is endless in effect, but establishing
///   it means following the timer's closure to a function that animates. Not attempted. The
///   one real instance in the measured sample was reported anyway, by signal 2, because the
///   animation it kicks off runs for twenty seconds.
/// - Signal 2 is not applied to `.animation()`, whose trigger is a state change rather than a
///   lexical position, so deciding whether it auto-starts would mean tracing what writes the
///   value.
/// - A file mentioning `reduceMotion` anywhere is skipped entirely. Coarse, but a file that
///   has taken the preference into account is not the place to start.
public struct ReduceMotionRule: A11yRule {
    public let id = "animation-missing-reduce-motion"
    public let name = "Endless or Long Auto-Started Animation"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["2.2.2"]
    public let description = "Motion that starts on its own and either repeats without end or runs past 5 seconds needs a way to pause, stop or hide it (WCAG 2.2.2). Gate it on @Environment(\\.accessibilityReduceMotion). Note that SwiftUI does not disable .animation() under Reduce Motion for you — the check has to be explicit."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        var diagnostics: [A11yDiagnostic] = []
        let sourceText = context.sourceText

        // Check if the file references reduceMotion anywhere — if so, they're handling it
        let hasReduceMotionCheck = sourceText.contains("reduceMotion") ||
            sourceText.contains("UIAccessibility.isReduceMotionEnabled") ||
            sourceText.contains("ReduceMotion")

        if hasReduceMotionCheck { return [] }

        let infiniteNames = InfiniteAnimationCollector.collect(from: syntax)
        let numbers = NumericConstantCollector.collect(from: syntax)

        // Signal 1 on `.animation(...)`. Its trigger is a state change rather than a lexical
        // position, so the auto-start signal is not applied here.
        let collector = ModifierCollector.collect(from: syntax)
        for mod in collector.modifiers(named: "animation") {
            guard let argument = mod.callExpr.arguments.first?.expression,
                  Self.repeatsForever(argument, infiniteNames: infiniteNames) else { continue }
            diagnostics.append(makeDiagnostic(
                message: "This animation repeats without end, so the motion never stops on its own (WCAG 2.2.2). Gate it on @Environment(\\.accessibilityReduceMotion) so it does not run when the user has asked for less motion.",
                node: mod.reportNode,
                context: context,
                suggestion: "Add @Environment(\\.accessibilityReduceMotion) var reduceMotion and use .animation(reduceMotion ? nil : foreverAnimation, value:)"
            ))
        }

        let withAnimVisitor = WithAnimationVisitor(viewMode: .sourceAccurate)
        withAnimVisitor.walk(syntax)
        for call in withAnimVisitor.calls {
            let argument = call.arguments.first?.expression

            if let argument, Self.repeatsForever(argument, infiniteNames: infiniteNames) {
                diagnostics.append(makeDiagnostic(
                    message: "This animation repeats without end, so the motion never stops on its own (WCAG 2.2.2). Gate it on @Environment(\\.accessibilityReduceMotion) so it does not run when the user has asked for less motion.",
                    node: call,
                    context: context,
                    suggestion: "Wrap in: if !reduceMotion { withAnimation(...) { ... } } else { ... }"
                ))
                continue
            }

            // Signal 2: started by the view appearing, and long enough for 2.2.2 to bite.
            guard Self.isAutoStarted(call),
                  let argument,
                  let seconds = Self.duration(of: argument, numbers: numbers),
                  seconds > Self.pauseStopHideThreshold else { continue }

            let rendered = seconds.rounded() == seconds
                ? String(Int(seconds))
                : String(format: "%.1f", seconds)
            diagnostics.append(makeDiagnostic(
                message: "This animation starts when the view appears and runs for \(rendered)s — past the 5s point where WCAG 2.2.2 requires a way to pause, stop or hide it. Gate it on @Environment(\\.accessibilityReduceMotion).",
                node: call,
                context: context,
                suggestion: "Wrap in: if !reduceMotion { withAnimation(...) { ... } } else { ... }"
            ))
        }

        return diagnostics
    }

    /// 2.2.2 exempts moving content that stops within five seconds.
    private static let pauseStopHideThreshold: Double = 5

    /// Modifiers whose closure runs because the view appeared, not because the user acted.
    private static let autoStartModifiers: Set<String> = ["onAppear", "task"]

    /// Whether the animation expression repeats endlessly, following one level of
    /// indirection through a file-local constant.
    private static func repeatsForever(_ expr: ExprSyntax, infiniteNames: Set<String>) -> Bool {
        if InfiniteAnimationCollector.describesInfiniteRepeat(expr.trimmedDescription) {
            return true
        }
        guard !infiniteNames.isEmpty else { return false }
        return expr.tokens(viewMode: .sourceAccurate).contains { infiniteNames.contains($0.text) }
    }

    /// Whether this call sits inside an `onAppear` or `task` closure.
    private static func isAutoStarted(_ call: FunctionCallExprSyntax) -> Bool {
        var current = Syntax(call)
        while let parent = current.parent {
            if let closure = parent.as(ClosureExprSyntax.self),
               let owner = Self.owningModifierName(of: closure),
               autoStartModifiers.contains(owner) {
                return true
            }
            current = parent
        }
        return false
    }

    /// The name of the modifier a closure is an argument to, if any.
    private static func owningModifierName(of closure: ClosureExprSyntax) -> String? {
        var node: Syntax? = closure.parent
        while let current = node {
            if let call = current.as(FunctionCallExprSyntax.self) {
                return call.calledExpression
                    .as(MemberAccessExprSyntax.self)?
                    .declName.baseName.text
            }
            if current.is(LabeledExprSyntax.self) || current.is(LabeledExprListSyntax.self) {
                node = current.parent
                continue
            }
            return nil
        }
        return nil
    }

    /// The `duration:` of an animation expression, resolving an identifier through a
    /// file-local constant. Returns the longest duration found, so a chained animation is
    /// judged on its slowest leg.
    private static func duration(of expr: ExprSyntax, numbers: [String: Double]) -> Double? {
        var longest: Double?
        func consider(_ value: Double) {
            if longest == nil || value > longest! { longest = value }
        }
        func walk(_ node: Syntax) {
            if let call = node.as(FunctionCallExprSyntax.self) {
                for argument in call.arguments where argument.label?.text == "duration" {
                    if let literal = NumericConstantCollector.numericValue(of: argument.expression) {
                        consider(literal)
                    } else if let name = argument.expression
                        .as(DeclReferenceExprSyntax.self)?.baseName.text,
                        let resolved = numbers[name] {
                        consider(resolved)
                    } else if let member = argument.expression.as(MemberAccessExprSyntax.self),
                              let resolved = numbers[member.declName.baseName.text] {
                        // `self.loadingDuration`
                        consider(resolved)
                    }
                }
            }
            for child in node.children(viewMode: .sourceAccurate) { walk(child) }
        }
        walk(Syntax(expr))
        return longest
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
        let visitor = ViewHierarchyVisitor.analyze(syntax, viewAliases: context.configOptions.viewAliases)
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
