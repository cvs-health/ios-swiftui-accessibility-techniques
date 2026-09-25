import SwiftSyntax

// MARK: - Fixed Height Clips Text Rule

/// Flags a text-bearing view pinned to an exact height that cannot fit its own text once
/// Dynamic Type grows.
///
/// A single line of body text is roughly 22pt at the default size and roughly 53pt at
/// `AX5`, so `Text("Total").frame(height: 30)` is legible as written and clipped for anyone
/// using large text. `.frame(minHeight:)` has no such problem, which is what makes this
/// mechanically fixable.
///
/// WCAG 1.4.4 Resize Text
///
/// Deliberately conservative, because the rule cannot see how much text will actually be
/// rendered. It only fires when every one of these holds:
///
/// - the height is an exact numeric `height:`, not `minHeight:` or `maxHeight:`
/// - the height is below ``clippingThreshold``, so generous containers are left alone
/// - the view renders text — `Text`, `Label`, `Button`, `Link`, `TextField`, `SecureField`
/// - the chain has no `.minimumScaleFactor`, which is a deliberate shrink-to-fit mitigation
///
/// Reported as a warning rather than an error for the same reason: a short string in a
/// snug-but-adequate box is indistinguishable, statically, from one that clips.
public struct FixedHeightTextRule: A11yRule {
    public let id = "fixed-height-clips-text"
    public let name = "Fixed Height Clips Text at Large Sizes"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.4.4"]
    public let description = "A text view pinned to an exact height clips its own text once Dynamic Type grows. Use .frame(minHeight:) so the view can grow."

    public init() {}

    /// Heights at or above this are assumed to have room for a grown line of text.
    ///
    /// One line of `.body` is about 53pt at the largest accessibility size, so 60 leaves a
    /// little headroom while still catching the snug 30–50pt boxes that actually clip.
    public static let clippingThreshold: Double = 60.0

    /// Heights below this are chrome, not text boxes.
    ///
    /// A notification badge, a page-indicator dot, or an icon frame is deliberately small and
    /// holds at most a digit or a glyph. One line of text does not fit in 24pt at *any* size,
    /// so a height this small says "this is decoration", not "this is a text container that
    /// forgot to grow". Measured against this repository: without this floor the rule reported
    /// ten findings of which six were on good examples — badges and carousel dots.
    public static let minimumTextBoxHeight: Double = 28.0

    /// Views that render text of their own, and so grow with Dynamic Type.
    private static let textBearingViews: Set<String> = [
        "Text", "Label", "Button", "Link", "TextField", "SecureField", "TextEditor",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.detectedViews where Self.textBearingViews.contains(view.viewType) {
            // A Button is only text-bearing if its label actually renders text. A page
            // indicator built from `Button { Rectangle() }` grows with nothing.
            guard Self.rendersText(view) else { continue }

            // Chain-only, so a height on a sibling or a child closure is never attributed here.
            let mods = ModifierCollector.collectChainOnly(from: view.chainRoot, callExpr: view.callExpr)

            // An explicit shrink-to-fit is a deliberate answer to this problem.
            if !mods.modifiers(named: "minimumScaleFactor").isEmpty { continue }

            for frameMod in mods.modifiers(named: "frame") {
                let labels = Set(frameMod.arguments.compactMap(\.label))
                // minHeight/maxHeight let the view grow, so they are not the defect.
                guard labels.contains("height"),
                      !labels.contains("minHeight"),
                      let height = Self.exactHeight(frameMod),
                      height >= Self.minimumTextBoxHeight,
                      height < Self.clippingThreshold else { continue }

                let fix = Self.minHeightFix(frameMod, syntax: syntax)
                diagnostics.append(makeDiagnostic(
                    message: "Text pinned to an exact height of \(Self.format(height))pt will be clipped at larger Dynamic Type sizes — one line of body text is about 53pt at the largest accessibility size. Use .frame(minHeight: \(Self.format(height))) so the view can grow.",
                    node: frameMod.reportNode,
                    context: context,
                    fix: fix,
                    suggestion: "Change height: to minHeight: so the view grows with the text"
                ))
            }
        }
        return diagnostics
    }

    /// Whether the view actually renders text that Dynamic Type will grow.
    ///
    /// `Text`, `Label`, and the field types always do. A `Button` only does when it has a
    /// word-bearing title or a `Text` in its label — `Button { Rectangle() }` is a shape, and
    /// `Button("⬅️")` is a glyph used as an icon, neither of which is a text box.
    private static func rendersText(_ view: ViewHierarchyVisitor.DetectedView) -> Bool {
        guard view.viewType == "Button" || view.viewType == "Link" else { return true }
        let source = view.callExpr.trimmedDescription
        if source.contains("Text(") { return true }
        // A title string counts only if it contains a letter or digit, so emoji-as-icon
        // labels are treated as glyphs rather than prose.
        if let title = view.callExpr.arguments.first?.expression.as(StringLiteralExprSyntax.self) {
            return title.segments.description.contains(where: { $0.isLetter || $0.isNumber })
        }
        return false
    }

    /// The numeric `height:` value, or nil when it is `.infinity` or not a literal.
    private static func exactHeight(_ mod: ModifierCollector.CollectedModifier) -> Double? {
        guard let arg = mod.arguments.first(where: { $0.label == "height" }) else { return nil }
        if arg.text.contains("infinity") { return nil }
        return Double(arg.text)
    }

    /// Rewrite `height:` as `minHeight:`, which is the whole fix.
    private static func minHeightFix(
        _ mod: ModifierCollector.CollectedModifier,
        syntax: SourceFileSyntax
    ) -> A11yFix? {
        guard let arg = mod.callExpr.arguments.first(where: { $0.label?.text == "height" }),
              let label = arg.label,
              let colon = arg.colon else { return nil }
        let offset = syntax.position.utf8Offset
        return A11yFix(
            description: "Change height: to minHeight:",
            replacementText: "minHeight:",
            startOffset: label.position.utf8Offset - offset,
            endOffset: colon.endPositionBeforeTrailingTrivia.utf8Offset - offset
        )
    }

    private static func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }
}
