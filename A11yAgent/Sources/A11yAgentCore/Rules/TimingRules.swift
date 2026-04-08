import SwiftSyntax

// MARK: - Timing Adjustable Rule

/// Flags auto-dismissing patterns (Task.sleep followed by dismiss/toggle) that
/// don't provide user control over timing. Users with cognitive or motor
/// disabilities may need more time to read and interact with timed content.
///
/// WCAG 2.2.1 Timing Adjustable
public struct TimingAdjustableRule: A11yRule {
    public let id = "auto-dismiss-no-control"
    public let name = "Auto-Dismiss Without User Control"
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["2.2.1"]
    public let description = "Auto-dismissing content (toasts, banners, alerts) should give users control over timing. Users with cognitive or motor disabilities may need more time."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = AutoDismissVisitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for pattern in visitor.patterns {
            diagnostics.append(makeDiagnostic(
                message: "Auto-dismiss pattern detected (Task.sleep then state change). Users with disabilities may not have enough time to read or interact with this content. Consider adding a close button or making the duration configurable.",
                node: pattern,
                context: context,
                suggestion: "Add a manual close/dismiss button alongside the auto-dismiss timer"
            ))
        }

        return diagnostics
    }
}

/// Finds patterns like:
/// ```
/// .task {
///     try? await Task.sleep(...)
///     showBanner = false  // or dismiss()
/// }
/// ```
/// or
/// ```
/// .onAppear {
///     DispatchQueue.main.asyncAfter(deadline: ...) {
///         dismiss()
///     }
/// }
/// ```
private class AutoDismissVisitor: SyntaxVisitor {
    var patterns: [FunctionCallExprSyntax] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) else {
            return .visitChildren
        }

        let modName = memberAccess.declName.baseName.text

        // Check .task { } and .onAppear { } modifiers
        if modName == "task" || modName == "onAppear" {
            if let closure = node.trailingClosure {
                let text = closure.trimmedDescription

                // Pattern 1: Task.sleep followed by state toggle or dismiss
                let hasSleep = text.contains("Task.sleep") || text.contains("sleep(")
                let hasDismiss = text.contains("dismiss()") ||
                    text.contains("= false") ||
                    text.contains("= true") ||
                    text.contains(".toggle()")

                if hasSleep && hasDismiss {
                    patterns.append(node)
                }

                // Pattern 2: DispatchQueue.main.asyncAfter + dismiss
                let hasAsyncAfter = text.contains("asyncAfter")
                if hasAsyncAfter && hasDismiss {
                    patterns.append(node)
                }
            }
        }

        return .visitChildren
    }
}
