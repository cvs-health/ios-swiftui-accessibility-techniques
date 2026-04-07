import SwiftSyntax

// MARK: - Input Purpose Rule

/// Flags TextField/SecureField that lack a `.textContentType()` modifier.
/// Without textContentType, iOS can't offer autofill for names, emails,
/// passwords, etc.
///
/// WCAG 1.3.5 Identify Input Purpose
public struct InputPurposeRule: A11yRule {
    public let id = "input-missing-purpose"
    public let name = "Text Input Missing Content Type"
    public let severity = A11ySeverity.info
    public let wcagCriteria = ["1.3.5"]
    public let description = "TextFields and SecureFields should have .textContentType() so iOS can offer autofill and assistive technologies can identify the input purpose."

    public init() {}

    private static let inputViews: Set<String> = ["TextField", "SecureField"]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let visitor = ViewHierarchyVisitor.analyze(syntax)
        var diagnostics: [A11yDiagnostic] = []

        for view in visitor.detectedViews {
            guard Self.inputViews.contains(view.viewType) else { continue }

            let mods = view.modifiers
            let hasContentType = mods.hasModifier("textContentType")
            let hasKeyboardType = mods.hasModifier("keyboardType")

            // SecureField almost always needs .textContentType(.password) or .textContentType(.newPassword)
            if view.viewType == "SecureField" && !hasContentType {
                diagnostics.append(makeDiagnostic(
                    message: "SecureField without .textContentType(). Add .textContentType(.password) or .textContentType(.newPassword) so iOS offers password autofill.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add .textContentType(.password)"
                ))
                continue
            }

            // TextField without textContentType — info-level suggestion
            if view.viewType == "TextField" && !hasContentType && !hasKeyboardType {
                diagnostics.append(makeDiagnostic(
                    message: "TextField without .textContentType(). Consider adding .textContentType(.name), .textContentType(.emailAddress), etc. so iOS can offer autofill and assistive technologies know the input purpose.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add .textContentType(.emailAddress) or appropriate content type"
                ))
            }
        }

        return diagnostics
    }
}
