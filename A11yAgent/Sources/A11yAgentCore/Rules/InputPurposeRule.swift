import Foundation
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
    public let severity = A11ySeverity.error
    public let impact = A11yImpact.moderate
    public let wcagCriteria = ["1.3.5"]
    public let description = "TextFields and SecureFields should have .textContentType() so iOS can offer autofill and assistive technologies can identify the input purpose."

    public init() {}

    private static let inputViews: Set<String> = ["TextField", "SecureField"]

    private static let searchKeywords: Set<String> = ["search", "query", "filter", "find"]

    /// Map of lowercase keywords to their UITextContentType values.
    private static let contentTypeKeywords: [(keywords: [String], contentType: String)] = [
        (["password", "passwd", "pwd"],          ".password"),
        (["newpassword", "new_password", "confirmpassword", "confirm_password"], ".newPassword"),
        (["email", "emailaddress", "e_mail"],    ".emailAddress"),
        (["phone", "phonenumber", "telephone", "tel"], ".telephoneNumber"),
        (["firstname", "first_name", "fname", "givenname", "given_name"], ".givenName"),
        (["lastname", "last_name", "lname", "surname", "familyname", "family_name"], ".familyName"),
        (["middlename", "middle_name", "mname"], ".middleName"),
        (["fullname", "full_name"],              ".name"),
        (["name", "username", "user_name"],      ".name"),
        (["address2", "addressline2", "street2", "streetaddress2", "street_address2", "address_line2", "address_line_2", "addresslinetwo"], ".streetAddressLine2"),
        (["street", "streetaddress", "street_address", "address1", "addressline1", "address", "addressline"], ".streetAddressLine1"),
        (["city"],                               ".addressCity"),
        (["state", "province", "region"],        ".addressState"),
        (["zip", "zipcode", "zip_code", "postalcode", "postal_code"], ".postalCode"),
        (["country"],                            ".countryName"),
        (["url", "website", "webpage", "homepage"], ".URL"),
        (["organization", "organisation", "company", "org"], ".organizationName"),
        (["jobtitle", "job_title", "title"],     ".jobTitle"),
        (["nickname", "nick_name"],              ".nickname"),
        (["creditcard", "credit_card", "cardnumber", "card_number"], ".creditCardNumber"),
    ]

    /// Collect hint strings from binding variable name and string arguments.
    private static func collectHints(from view: ViewHierarchyVisitor.DetectedView) -> [String] {
        var hints: [String] = []

        // Extract binding variable name from `text: $varName`
        let callText = view.callExpr.description
        if let regex = try? NSRegularExpression(pattern: #"text:\s*\$(\w+)"#),
           let match = regex.firstMatch(in: callText, range: NSRange(callText.startIndex..., in: callText)),
           let range = Range(match.range(at: 1), in: callText) {
            hints.append(String(callText[range]).lowercased())
        }

        // Collect string literal arguments (label text, placeholder, prompt, etc.)
        for arg in view.callExpr.arguments {
            if let stringLiteral = arg.expression.as(StringLiteralExprSyntax.self) {
                let text = stringLiteral.segments.description.lowercased()
                if !text.isEmpty {
                    hints.append(text)
                }
            }
        }

        return hints
    }

    /// Returns true if the field appears to be a search field (no standard textContentType exists).
    private static func isSearchField(_ view: ViewHierarchyVisitor.DetectedView) -> Bool {
        var hints = collectHints(from: view)

        // Also check .accessibilityLabel value
        if let labelMod = view.modifiers.modifiers(named: "accessibilityLabel").first,
           let labelText = labelMod.firstStringArgument {
            hints.append(labelText.lowercased())
        }

        for hint in hints {
            let normalized = hint.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: "_", with: "")
                .lowercased()
            for keyword in searchKeywords {
                if normalized == keyword || normalized.contains(keyword) {
                    return true
                }
            }
        }
        return false
    }

    /// Infer the best `.textContentType()` from binding name, label, or placeholder text.
    private static func inferContentType(from view: ViewHierarchyVisitor.DetectedView) -> String? {
        let hints = collectHints(from: view)

        // Match against known keywords
        for hint in hints {
            // Normalize: remove spaces, dashes, underscores for matching
            let normalized = hint.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .lowercased()
            for (keywords, contentType) in contentTypeKeywords {
                for keyword in keywords {
                    if normalized == keyword || normalized.contains(keyword) {
                        return contentType
                    }
                }
            }
        }

        return nil
    }

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
                let inferred = Self.inferContentType(from: view) ?? ".password"
                let fix = Self.makeModifierFix(
                    chainRoot: view.chainRoot,
                    modifier: ".textContentType(\(inferred))",
                    sourceFile: syntax
                )
                diagnostics.append(makeDiagnostic(
                    message: "SecureField without .textContentType(). Add .textContentType(\(inferred)) or .textContentType(.newPassword) so iOS offers password autofill.",
                    node: view.callExpr,
                    context: context,
                    fix: fix,
                    suggestion: "Add .textContentType(\(inferred))"
                ))
                continue
            }

            // TextField without textContentType — only flag when we can infer a specific content type.
            // Generic input fields (task names, folder names, notes, etc.) have no standard
            // UITextContentType and would be false positives.
            if view.viewType == "TextField" && !hasContentType && !hasKeyboardType && !Self.isSearchField(view) {
                if let inferred = Self.inferContentType(from: view) {
                    let fix = Self.makeModifierFix(
                        chainRoot: view.chainRoot,
                        modifier: ".textContentType(\(inferred))",
                        sourceFile: syntax
                    )
                    diagnostics.append(makeDiagnostic(
                        message: "TextField without .textContentType(). Consider adding .textContentType(\(inferred)) so iOS can offer autofill and assistive technologies know the input purpose.",
                        node: view.callExpr,
                        context: context,
                        fix: fix,
                        suggestion: "Add .textContentType(\(inferred))"
                    ))
                }
            }
        }

        return diagnostics
    }

    /// Build an A11yFix that appends a modifier at the end of the view's chain.
    private static func makeModifierFix(
        chainRoot: ExprSyntax,
        modifier: String,
        sourceFile: SourceFileSyntax
    ) -> A11yFix? {
        let endPosition = chainRoot.endPositionBeforeTrailingTrivia
        let offset = sourceFile.position.utf8Offset
        let insertOffset = endPosition.utf8Offset - offset

        let indentEnd = chainRoot.positionAfterSkippingLeadingTrivia
        let lineStart = chainRoot.position
        let leadingTrivia = sourceFile.description[
            sourceFile.description.utf8.index(sourceFile.description.utf8.startIndex, offsetBy: lineStart.utf8Offset - offset)
            ..<
            sourceFile.description.utf8.index(sourceFile.description.utf8.startIndex, offsetBy: indentEnd.utf8Offset - offset)
        ]
        let indent = leadingTrivia.filter { $0 == " " || $0 == "\t" }

        let replacement = "\n\(indent)    \(modifier)"

        return A11yFix(
            description: "Add \(modifier)",
            replacementText: replacement,
            startOffset: insertOffset,
            endOffset: insertOffset
        )
    }
}
