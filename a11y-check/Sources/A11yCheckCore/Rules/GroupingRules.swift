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

// MARK: - Accessibility Grouping Rule

/// Flags HStack/VStack patterns where an Image and Text are adjacent siblings
/// but not grouped with .accessibilityElement(children: .combine). Without
/// grouping, VoiceOver reads them as separate elements, which is confusing.
///
/// WCAG 1.3.1 Info and Relationships
public struct AccessibilityGroupingRule: A11yRule {
    public let id = "missing-accessibility-grouping"
    public let name = "Related Elements Missing Accessibility Grouping"
    public let severity = A11ySeverity.info
    public let impact = A11yImpact.minor
    public let wcagCriteria = ["1.3.1"]
    public let description = "Adjacent Image + Text pairs in HStack/VStack should be grouped with .accessibilityElement(children: .combine) so VoiceOver reads them as a single element."

    public init() {}

    private static let containerViews: Set<String> = ["HStack", "VStack"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "HStack") + visitor.views(ofType: "VStack") {
            let chainText = view.chainRoot.trimmedDescription

            // Skip if already has accessibility grouping
            if chainText.contains("accessibilityElement") { continue }

            // Skip if inside a label: closure — VoiceOver groups the entire label as one element
            if isInsideLabelClosure(view.callExpr) { continue }

            // Check if the container's trailing closure has both Image and Text as direct children
            guard let trailingClosure = view.callExpr.trailingClosure else { continue }

            // Analyze only the immediate children of this container
            let innerVisitor = ViewHierarchyVisitor.analyze(trailingClosure)
            let directChildren = innerVisitor.detectedViews

            // Only flag small containers (2-3 children) that look like an
            // icon+label or image+caption pair, not page-level layout containers.
            guard directChildren.count >= 2, directChildren.count <= 3 else { continue }

            let hasImage = directChildren.contains { $0.viewType == "Image" }
            let hasText = directChildren.contains { $0.viewType == "Text" }
            guard hasImage && hasText else { continue }

            // Don't flag if the container has interactive children
            let hasInteractive = directChildren.contains {
                ["Button", "NavigationLink", "Toggle", "Link"].contains($0.viewType)
            }
            if hasInteractive { continue }

            // Don't flag if there's a Label (Label already combines icon + text)
            if directChildren.contains(where: { $0.viewType == "Label" }) { continue }

            let fix = makeModifierFix(
                chainRoot: view.chainRoot,
                modifier: ".accessibilityElement(children: .combine)",
                sourceFile: syntax
            )
            diagnostics.append(makeDiagnostic(
                message: "Image and Text in \(view.viewType) are separate elements for VoiceOver. Consider adding .accessibilityElement(children: .combine) to the \(view.viewType) so they're read as one item.",
                node: view.callExpr,
                context: context,
                fix: fix,
                suggestion: "Add .accessibilityElement(children: .combine) to the \(view.viewType)"
            ))
        }

        return diagnostics
    }
}

// MARK: - ZStack Meaningful Sequence Rule

/// Flags ZStack with multiple interactive children where VoiceOver reading order
/// may not match the visual order. ZStack lays out children back-to-front visually,
/// but VoiceOver reads them in source order (first child first), which may be
/// the back (visually hidden) layer.
///
/// WCAG 1.3.2 Meaningful Sequence
public struct ZStackSequenceRule: A11yRule {
    public let id = "zstack-order-confusing"
    public let name = "ZStack May Have Confusing VoiceOver Order"
    public let severity = A11ySeverity.info
    public let impact = A11yImpact.minor
    public let wcagCriteria = ["1.3.2"]
    public let description = "ZStack children are read by VoiceOver in source order (back-to-front), which may not match the visual order. Use .accessibilityHidden(true) on decorative layers or .accessibilitySortPriority() to fix reading order."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.views(ofType: "ZStack") {
            guard let trailingClosure = view.callExpr.trailingClosure else { continue }
            let closureText = trailingClosure.trimmedDescription
            let chainText = view.chainRoot.trimmedDescription

            // Skip if already managing accessibility order
            if chainText.contains("accessibilitySortPriority") ||
               chainText.contains("accessibilityElement") {
                continue
            }

            // Count interactive elements in the ZStack
            let interactiveKeywords = ["Button(", "NavigationLink(", "Toggle(",
                                       ".onTapGesture", "TextField(", "SecureField(",
                                       "Slider(", "Stepper(", "Picker(", "Link("]
            let interactiveCount = interactiveKeywords.filter { closureText.contains($0) }.count

            // Also check if any child has accessibilityHidden — they're already handling it
            if closureText.contains("accessibilityHidden") { continue }

            // Flag if there are multiple interactive elements or a mix of decorative + interactive
            if interactiveCount >= 2 {
                diagnostics.append(makeDiagnostic(
                    message: "ZStack with multiple interactive elements. VoiceOver reads in source order (bottom layer first), which may not match the visual layout. Use .accessibilityHidden(true) on decorative layers or .accessibilitySortPriority() to control reading order.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add .accessibilityHidden(true) to background/decorative layers or use .accessibilitySortPriority()"
                ))
            }
        }

        return diagnostics
    }
}

// MARK: - Button Group Missing Container Label Rule

/// Flags HStack/VStack/LazyVGrid/LazyHStack containers of 2+ Buttons that are
/// missing `.accessibilityElement(children: .contain)` and/or `.accessibilityLabel()`
/// when a preceding Text sibling suggests they form a labeled group (like radio
/// buttons needing a legend).
///
/// WCAG 1.3.1 Info and Relationships
/// Reference: GroupingControlsView.swift, RadioButtonsView.swift
public struct ButtonGroupMissingContainerLabelRule: A11yRule {
    public let id = "button-group-missing-container-label"
    public let name = "Button Group Missing Container Label"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["1.3.1"]
    public let description = "Containers of related Buttons with a visible group label should use .accessibilityElement(children: .contain) and .accessibilityLabel() so VoiceOver users hear the group context."

    public init() {}

    private static let containerViews: Set<String> = ["HStack", "VStack", "LazyVGrid", "LazyHStack"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for containerType in Self.containerViews {
            for view in visitor.views(ofType: containerType) {
                let chainText = view.chainRoot.trimmedDescription

                // Skip if has accessibilityElement with a non-.contain argument
                // (e.g. .combine means they chose a different grouping strategy)
                if chainText.contains("accessibilityElement") &&
                   !chainText.contains(".contain") { continue }

                // Skip if inside a label: closure
                if isInsideLabelClosure(view.callExpr) { continue }

                // Check trailing closure for Button children
                guard let trailingClosure = view.callExpr.trailingClosure else { continue }

                let innerVisitor = ViewHierarchyVisitor.analyze(trailingClosure)
                let buttons = innerVisitor.views(ofType: "Button")

                // Need at least 2 Buttons to form a group
                guard buttons.count >= 2 else { continue }

                // Look for a preceding Text sibling in the parent — the group label
                guard hasPrecedingTextSibling(view.chainRoot) else { continue }

                // Determine what's missing
                let mods = view.modifiers
                let hasContain = mods.modifiers(named: "accessibilityElement").contains { mod in
                    mod.arguments.contains { $0.label == "children" && $0.text.contains("contain") }
                }
                let hasLabel = mods.hasModifier("accessibilityLabel")

                if hasContain && hasLabel { continue }

                if !hasContain && !hasLabel {
                    let fix = makeModifierFix(
                        chainRoot: view.chainRoot,
                        modifier: ".accessibilityElement(children: .contain)",
                        sourceFile: syntax
                    )
                    diagnostics.append(makeDiagnostic(
                        message: "\(containerType) of Buttons appears to have a visible group label but is missing .accessibilityElement(children: .contain) and .accessibilityLabel(). VoiceOver users won't hear the group context when navigating to these buttons.",
                        node: view.callExpr,
                        context: context,
                        fix: fix,
                        suggestion: "Add .accessibilityElement(children: .contain) and .accessibilityLabel(\"group label\") to the \(containerType)"
                    ))
                } else if !hasLabel {
                    diagnostics.append(makeDiagnostic(
                        message: "\(containerType) of Buttons has .accessibilityElement(children: .contain) but is missing .accessibilityLabel(). VoiceOver won't announce the group context.",
                        node: view.callExpr,
                        context: context,
                        suggestion: "Add .accessibilityLabel(\"group label\") matching the visible label for this group"
                    ))
                } else {
                    let fix = makeModifierFix(
                        chainRoot: view.chainRoot,
                        modifier: ".accessibilityElement(children: .contain)",
                        sourceFile: syntax
                    )
                    diagnostics.append(makeDiagnostic(
                        message: "\(containerType) of Buttons has .accessibilityLabel() but is missing .accessibilityElement(children: .contain). Without .contain, VoiceOver may not announce the group label when entering the group.",
                        node: view.callExpr,
                        context: context,
                        fix: fix,
                        suggestion: "Add .accessibilityElement(children: .contain) to the \(containerType)"
                    ))
                }
            }
        }
        return diagnostics
    }

    /// Walk up from a node to find a preceding Text sibling in the parent container.
    /// Returns true if a Text() call is found among the preceding siblings
    /// (within 5 siblings back), indicating a visible group label above the buttons.
    private func hasPrecedingTextSibling(_ node: ExprSyntax) -> Bool {
        // Find the CodeBlockItemSyntax that contains this node
        var current: Syntax? = Syntax(node)
        var codeBlockItem: CodeBlockItemSyntax?
        while let parent = current?.parent {
            if let item = parent.as(CodeBlockItemSyntax.self) {
                codeBlockItem = item
                break
            }
            current = parent
        }
        guard let item = codeBlockItem else { return false }

        // Get the CodeBlockItemListSyntax (the parent list of statements)
        guard let itemList = item.parent?.as(CodeBlockItemListSyntax.self) else { return false }

        // Collect items into an array and find our item's index
        let items = Array(itemList)
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }) else { return false }

        // Walk backward through preceding siblings (up to 5)
        let startIndex = max(0, itemIndex - 5)
        for i in stride(from: itemIndex - 1, through: startIndex, by: -1) {
            let prev = items[i]
            let text = prev.trimmedDescription

            // Stop if we hit another container view — different group context
            if text.hasPrefix("HStack") || text.hasPrefix("VStack") ||
               text.hasPrefix("LazyVGrid") || text.hasPrefix("LazyHStack") {
                break
            }

            // Check if this sibling contains a Text() call
            if containsTextCall(Syntax(prev)) {
                return true
            }
        }
        return false
    }

    /// Recursively check if a syntax node contains a Text() function call.
    private func containsTextCall(_ node: Syntax) -> Bool {
        if let call = node.as(FunctionCallExprSyntax.self),
           let ref = call.calledExpression.as(DeclReferenceExprSyntax.self),
           ref.baseName.text == "Text" {
            return true
        }
        // Check through member access chains (e.g. Text("...").font(...))
        if let call = node.as(FunctionCallExprSyntax.self),
           let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
            if containsTextCall(Syntax(member)) { return true }
        }
        if let member = node.as(MemberAccessExprSyntax.self),
           let base = member.base {
            if containsTextCall(Syntax(base)) { return true }
        }
        for child in node.children(viewMode: .sourceAccurate) {
            if containsTextCall(child) { return true }
        }
        return false
    }
}

// MARK: - Sort Priority Overused Rule

/// Flags every use of .accessibilitySortPriority() for review. Sort priority
/// overrides VoiceOver's natural reading order and is frequently misused.
/// Prefer restructuring the view hierarchy or using .accessibilityElement
/// before resorting to sort priority.
///
/// WCAG 1.3.2 Meaningful Sequence
public struct SortPriorityOverusedRule: A11yRule {
    public let id = "sort-priority-overused"
    public let name = "Accessibility Sort Priority Needs Review"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["1.3.2"]
    public let description = ".accessibilitySortPriority() overrides VoiceOver's default reading order. Only use when the visual layout doesn't match the logical reading order (e.g., ZStack overlays). Verify the VoiceOver order matches the visual order."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let collector = ModifierCollector.collect(from: syntax)
        var diagnostics: [A11yDiagnostic] = []

        for mod in collector.modifiers(named: "accessibilitySortPriority") {
            diagnostics.append(makeDiagnostic(
                message: ".accessibilitySortPriority() overrides VoiceOver's default left-to-right, top-to-bottom reading order. Verify the resulting VoiceOver order matches the visual layout — incorrect priority values can make bottom elements (e.g., tab bars) get focus first.",
                node: mod.reportNode,
                context: context,
                suggestion: "Verify sort priority values produce the correct VoiceOver reading order"
            ))
        }

        return diagnostics
    }
}
