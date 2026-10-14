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

/// Scans a source file for design-system tokens that carry their own accessibility label.
///
/// A design system often keeps the accessible name next to the token rather than at the call
/// site, so the component supplies it automatically:
///
/// ```swift
/// public var a11yLabel: String? {
///     switch self {
///     case .errorFill:   return Localized.errorImageText
///     case .warningFill: return Localized.warningImageText
///     default:           return nil      // every other icon is unlabelled
///     }
/// }
/// ```
///
/// `IconView(.messaging(.errorFill))` is therefore announced, while
/// `IconView(.utilities(.externalLink))` is not — and nothing at either call site says which.
/// Without this index, aliasing a wrapper into the image rules reports both, and the labelled
/// ones are false positives. Measured on one app: 33 of 218 new findings.
///
/// Collects the case names a label property returns a *non-nil* value for. The `default: nil`
/// arm is what makes this worth indexing: the unlabelled tokens are the majority and are never
/// written down individually.
public final class LabelledTokenScanner: SyntaxVisitor {

    /// Property names that supply an accessible name for a token. Covers the common spellings;
    /// a design system using another name simply gets no index, which fails toward reporting.
    public static let labelPropertyNames: Set<String> = [
        "a11yLabel", "accessibilityLabel", "accessibilityText", "altText", "a11yText",
    ]

    /// Enum case names whose label property returns something.
    private(set) public var labelledTokens: Set<String> = []

    public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    public static func scan(_ syntax: some SyntaxProtocol) -> Set<String> {
        let scanner = LabelledTokenScanner()
        scanner.walk(syntax)
        return scanner.labelledTokens
    }

    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for binding in node.bindings {
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                  Self.labelPropertyNames.contains(pattern.identifier.text),
                  let accessor = binding.accessorBlock
            else { continue }
            collectCases(in: Syntax(accessor))
        }
        return .visitChildren
    }

    /// A `switch self` arm counts when its body returns anything other than `nil`.
    ///
    /// Only `case .foo:` patterns are read. A `default:` arm is deliberately ignored even when
    /// it returns a value: it would otherwise mean "every token is labelled", which is both
    /// unknowable from here and the opposite of the usual shape.
    private func collectCases(in node: Syntax) {
        for switchCase in node.children(viewMode: .sourceAccurate).compactMap({ $0.as(SwitchCaseSyntax.self) }) {
            handle(switchCase)
        }
        // Switch cases sit inside nested statement nodes, so recurse rather than assuming depth.
        for child in node.children(viewMode: .sourceAccurate) {
            if let switchCase = child.as(SwitchCaseSyntax.self) {
                handle(switchCase)
            } else {
                collectCases(in: child)
            }
        }
    }

    private func handle(_ switchCase: SwitchCaseSyntax) {
        guard case .case(let label) = switchCase.label else { return }
        let body = switchCase.statements.trimmedDescription
        guard !returnsOnlyNil(body) else { return }
        for item in label.caseItems {
            for name in Self.caseNames(in: item.pattern) {
                labelledTokens.insert(name)
            }
        }
    }

    /// True when the arm yields nothing — `return nil`, `nil`, or an empty body.
    private func returnsOnlyNil(_ body: String) -> Bool {
        let t = body.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty || t == "nil" || t == "return nil"
    }

    /// Case names in a pattern: `.errorFill` yields `errorFill`; `.a, .b` yields both.
    static func caseNames(in pattern: PatternSyntax) -> [String] {
        var names: [String] = []
        func walk(_ node: Syntax) {
            if let member = node.as(MemberAccessExprSyntax.self), member.base == nil {
                names.append(member.declName.baseName.text)
            }
            for child in node.children(viewMode: .sourceAccurate) { walk(child) }
        }
        walk(Syntax(pattern))
        return names
    }
}
