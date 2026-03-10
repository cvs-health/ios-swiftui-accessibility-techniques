import SwiftSyntax

// MARK: - Small Touch Target Rule

/// Flags interactive elements with `.frame(width:, height:)` below 24x24 points
/// (WCAG 2.2 Level AA minimum).
///
/// WCAG 2.5.8 Target Size (Minimum)
/// Reference: TouchTargetSize.swift — bad example uses .frame(width: 18, height: 18)
public struct SmallTouchTargetRule: A11yRule {
    public let id = "small-touch-target"
    public let name = "Touch Target Below Minimum Size"
    public let severity = A11ySeverity.warning
    public let wcagCriteria = ["2.5.8"]
    public let description = "Interactive elements should have a minimum touch target size of 24x24 points (WCAG 2.2 AA)."

    public init() {}

    /// The minimum dimension in points (WCAG 2.2 Level AA is 24; Apple HIG recommends 44).
    public static let minimumSize: Double = 24.0

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        // Check Buttons and images with tap gestures
        let interactiveViews = visitor.views(ofType: "Button") + visitor.views(ofType: "Image")

        for view in interactiveViews {
            let frameMods = view.modifiers.modifiers(named: "frame")
            for frameMod in frameMods {
                let width = extractNumericArg(frameMod, label: "width")
                    ?? extractNumericArg(frameMod, label: "maxWidth")
                let height = extractNumericArg(frameMod, label: "height")
                    ?? extractNumericArg(frameMod, label: "maxHeight")

                // Only flag if we can determine a dimension that's too small
                if let w = width, w < Self.minimumSize {
                    diagnostics.append(makeDiagnostic(
                        message: "Touch target width \(Int(w))pt is below the \(Int(Self.minimumSize))pt minimum (WCAG 2.5.8). Use at least 24pt, ideally 44pt.",
                        node: frameMod.callExpr,
                        context: context
                    ))
                } else if let h = height, h < Self.minimumSize {
                    diagnostics.append(makeDiagnostic(
                        message: "Touch target height \(Int(h))pt is below the \(Int(Self.minimumSize))pt minimum (WCAG 2.5.8). Use at least 24pt, ideally 44pt.",
                        node: frameMod.callExpr,
                        context: context
                    ))
                }
            }
        }
        return diagnostics
    }

    private func extractNumericArg(_ mod: ModifierCollector.CollectedModifier, label: String) -> Double? {
        guard let arg = mod.arguments.first(where: { $0.label == label }) else { return nil }
        return Double(arg.text)
    }
}
