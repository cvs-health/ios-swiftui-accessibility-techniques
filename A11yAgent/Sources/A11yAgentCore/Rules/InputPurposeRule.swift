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
    public let severity = A11ySeverity.info
    public let wcagCriteria = ["1.3.5"]
    public let description = "TextFields and SecureFields should have .textContentType() so iOS can offer autofill and assistive technologies can identify the input purpose."

    public init() {}

    private static let inputViews: Set<String> = ["TextField", "SecureField"]

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
        (["street", "streetaddress", "street_address", "address", "addressline"], ".streetAddressLine1"),
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

    /// Infer the best `.textContentType()` from binding name, label, or placeholder text.
    private static func inferContentType(from view: ViewHierarchyVisitor.DetectedView) -> String? {
        // Collect hints from the binding variable name and string arguments
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
                diagnostics.append(makeDiagnostic(
                    message: "SecureField without .textContentType(). Add .textContentType(\(inferred)) or .textContentType(.newPassword) so iOS offers password autofill.",
                    node: view.callExpr,
                    context: context,
                    suggestion: "Add .textContentType(\(inferred))"
                ))
                continue
            }

            // TextField without textContentType — info-level suggestion
            if view.viewType == "TextField" && !hasContentType && !hasKeyboardType {
                let inferred = Self.inferContentType(from: view)
                let suggestionType = inferred ?? ".name"
                let message: String
                let suggestion: String
                if let inferred = inferred {
                    message = "TextField without .textContentType(). Consider adding .textContentType(\(inferred)) so iOS can offer autofill and assistive technologies know the input purpose."
                    suggestion = "Add .textContentType(\(inferred))"
                } else {
                    message = "TextField without .textContentType(). Consider adding .textContentType(.name), .textContentType(.emailAddress), etc. so iOS can offer autofill and assistive technologies know the input purpose."
                    suggestion = "Add .textContentType(\(suggestionType)) or appropriate content type"
                }
                diagnostics.append(makeDiagnostic(
                    message: message,
                    node: view.callExpr,
                    context: context,
                    suggestion: suggestion
                ))
            }
        }

        return diagnostics
    }
}
