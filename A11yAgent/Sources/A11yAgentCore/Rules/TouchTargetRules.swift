import SwiftSyntax

// MARK: - Small Touch Target Rule

/// Flags interactive elements with `.frame(width:, height:)` below 24x24 points
/// (WCAG 2.2 Level AA minimum). Accounts for `.padding()` adding to the
/// effective touch target. Skips when only one dimension is small and the other
/// is undefined or `.infinity` — the element likely has adequate spacing.
///
/// WCAG 2.5.8 Target Size (Minimum)
/// Reference: TouchTargetSize.swift — bad example uses .frame(width: 18, height: 18)
public struct SmallTouchTargetRule: A11yRule {
    public let id = "small-touch-target"
    public let name = "Touch Target Below Minimum Size"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.5.8"]
    public let description = "Interactive elements should have a minimum touch target size of 24x24 points (WCAG 2.2 AA). Padding and spacing count toward the target size."

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

            // Determine padding on this element (adds to effective touch target)
            let padding = extractPadding(from: view.modifiers)

            for frameMod in frameMods {
                let argText = frameMod.arguments.map(\.text).joined(separator: ", ")

                // Check if dimensions are .infinity (not a constraint)
                let widthIsInfinity = argText.contains("width") && argText.contains(".infinity")
                    || argText.contains("maxWidth") && argText.contains(".infinity")
                let heightIsInfinity = argText.contains("height") && argText.contains(".infinity")
                    || argText.contains("maxHeight") && argText.contains(".infinity")

                let rawWidth = extractNumericArg(frameMod, label: "width")
                    ?? extractNumericArg(frameMod, label: "maxWidth")
                let rawHeight = extractNumericArg(frameMod, label: "height")
                    ?? extractNumericArg(frameMod, label: "maxHeight")

                // Effective size includes padding on both sides
                let effectiveWidth = rawWidth.map { $0 + padding.horizontal * 2 }
                let effectiveHeight = rawHeight.map { $0 + padding.vertical * 2 }

                let widthTooSmall = effectiveWidth.map { $0 < Self.minimumSize } ?? false
                let heightTooSmall = effectiveHeight.map { $0 < Self.minimumSize } ?? false

                // Skip if the dimension is .infinity — it fills available space
                let widthConstrained = !widthIsInfinity && rawWidth != nil
                let heightConstrained = !heightIsInfinity && rawHeight != nil

                // Only flag if both dimensions are explicitly small,
                // or one is explicitly small and the other is also constrained small
                if widthConstrained && widthTooSmall && heightConstrained && heightTooSmall {
                    diagnostics.append(makeDiagnostic(
                        message: "Touch target \(Int(rawWidth!))x\(Int(rawHeight!))pt is below the \(Int(Self.minimumSize))x\(Int(Self.minimumSize))pt minimum (WCAG 2.5.8). Use at least 24pt, ideally 44pt.",
                        node: frameMod.reportNode,
                        context: context,
                        suggestion: "Increase .frame(width:height:) to at least 44x44pt, or add .padding() for spacing"
                    ))
                } else if widthConstrained && widthTooSmall && !heightConstrained {
                    diagnostics.append(makeDiagnostic(
                        message: "Touch target width \(Int(rawWidth!))pt is below the \(Int(Self.minimumSize))pt minimum (WCAG 2.5.8). Use at least 24pt, ideally 44pt.",
                        node: frameMod.reportNode,
                        context: context,
                        suggestion: "Increase .frame(width:) to at least 44pt, or add horizontal .padding() for spacing"
                    ))
                } else if heightConstrained && heightTooSmall && !widthConstrained {
                    diagnostics.append(makeDiagnostic(
                        message: "Touch target height \(Int(rawHeight!))pt is below the \(Int(Self.minimumSize))pt minimum (WCAG 2.5.8). Use at least 24pt, ideally 44pt.",
                        node: frameMod.reportNode,
                        context: context,
                        suggestion: "Increase .frame(height:) to at least 44pt, or add vertical .padding() for spacing"
                    ))
                }
            }
        }
        return diagnostics
    }

    private func extractNumericArg(_ mod: ModifierCollector.CollectedModifier, label: String) -> Double? {
        guard let arg = mod.arguments.first(where: { $0.label == label }) else { return nil }
        // Skip .infinity values
        if arg.text.contains("infinity") { return nil }
        return Double(arg.text)
    }

    /// Extract padding values from modifiers. Returns combined horizontal and vertical padding.
    private func extractPadding(from modifiers: ModifierCollector) -> (horizontal: Double, vertical: Double) {
        var horizontal = 0.0
        var vertical = 0.0

        for mod in modifiers.modifiers(named: "padding") {
            if mod.arguments.isEmpty {
                // .padding() with no args = 16pt default on all edges
                horizontal += 16.0
                vertical += 16.0
            } else if let allSides = mod.arguments.first(where: { $0.label == nil }), let val = Double(allSides.text) {
                // .padding(N) = N on all edges
                horizontal += val
                vertical += val
            } else {
                // .padding(.horizontal, N) or .padding(EdgeInsets(...))
                for arg in mod.arguments {
                    if arg.text.contains("horizontal"), let next = mod.arguments.dropFirst().first, let val = Double(next.text) {
                        horizontal += val
                    } else if arg.text.contains("vertical"), let next = mod.arguments.dropFirst().first, let val = Double(next.text) {
                        vertical += val
                    }
                }
            }
        }
        return (horizontal, vertical)
    }
}
