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
