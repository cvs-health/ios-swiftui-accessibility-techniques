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

            // Check if the container's trailing closure has both Image and Text as direct children
            guard let trailingClosure = view.callExpr.trailingClosure else { continue }
            let closureText = trailingClosure.trimmedDescription

            let hasImage = closureText.contains("Image(") || closureText.contains("Image(systemName:")
            let hasText = closureText.contains("Text(")

            // Only flag simple Image + Text pairs (not deeply nested ones)
            if hasImage && hasText {
                // Don't flag if the container has interactive children (Button, NavigationLink, etc.)
                let hasInteractive = closureText.contains("Button(") ||
                    closureText.contains("NavigationLink(") ||
                    closureText.contains("Toggle(") ||
                    closureText.contains(".onTapGesture")
                if hasInteractive { continue }

                // Don't flag if there's a Label (Label already combines icon + text)
                if closureText.contains("Label(") { continue }

                diagnostics.append(makeDiagnostic(
                    message: "Image and Text in \(view.viewType) are separate elements for VoiceOver. Consider adding .accessibilityElement(children: .combine) to the \(view.viewType) so they're read as one item.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add .accessibilityElement(children: .combine) to the \(view.viewType)"
                ))
            }
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
