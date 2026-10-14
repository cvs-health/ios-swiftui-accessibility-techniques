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

import Foundation
import SwiftSyntax

/// Resolves a localised string reference to the English text it renders.
///
/// Rules that judge wording — generic link text, duplicate labels, label-in-name — compare
/// against the *literal* in the source, so a localised app defeats them completely. In one real
/// codebase every label is `Button(Localized.learnMore)` and the only `"Learn more"` literals in
/// the repository are test fixtures, so a rule looking for generic phrases found nothing at all.
///
/// Two hops are needed, and this type owns both:
///
/// 1. `Localized.learnMore` → the key, from `static let learnMore = Localized.string(from: "x.y")`
/// 2. the key → `"Learn More"`, from a `.xcstrings` catalogue or a legacy `.strings` file
///
/// The result is one flat map from constant name to English text, so a rule does a dictionary
/// lookup and nothing more.
public enum StringCatalogIndex {

    /// Function names that take a localisation key as their first string argument.
    static let lookupFunctions: Set<String> = ["string", "localized", "localizedString", "text"]

    // MARK: - Catalogue parsing

    /// Key → English value, from every `.xcstrings` and `.strings` file under `directoryPath`.
    ///
    /// Both formats are read because a codebase part-way through migrating has both, and the
    /// UIKit layer of the app this was built against still uses `.strings`.
    public static func catalogue(at directoryPath: String) -> [String: String] {
        var result: [String: String] = [:]
        let fm = FileManager.default
        guard let walker = fm.enumerator(atPath: directoryPath) else { return result }
        while let relative = walker.nextObject() as? String {
            let full = (directoryPath as NSString).appendingPathComponent(relative)
            if relative.hasSuffix(".xcstrings") {
                result.merge(parseXCStrings(at: full)) { existing, _ in existing }
            } else if relative.hasSuffix(".strings"), relative.contains("en.lproj") || !relative.contains(".lproj") {
                // Only the English table. A `.strings` outside any `.lproj` is the base table.
                result.merge(parseStrings(at: full)) { existing, _ in existing }
            }
        }
        return result
    }

    /// Xcode string catalogue: JSON with `strings[key].localizations.en.stringUnit.value`.
    static func parseXCStrings(at path: String) -> [String: String] {
        guard let data = FileManager.default.contents(atPath: path),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = root["strings"] as? [String: Any]
        else { return [:] }

        var result: [String: String] = [:]
        for (key, entry) in strings {
            guard let entry = entry as? [String: Any] else { continue }
            // A key with no English localisation uses the key itself as the value, which is how
            // Xcode treats an untranslated base string.
            guard let locs = entry["localizations"] as? [String: Any] else {
                result[key] = key
                continue
            }
            if let en = locs["en"] as? [String: Any],
               let unit = en["stringUnit"] as? [String: Any],
               let value = unit["value"] as? String {
                result[key] = value
            }
        }
        return result
    }

    /// Legacy table: `"key" = "value";` with `//` and `/* */` comments.
    static func parseStrings(at path: String) -> [String: String] {
        guard let text = try? String(contentsOfFile: path, encoding: .utf8) else { return [:] }
        var result: [String: String] = [:]
        for line in text.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.hasPrefix("//"), !trimmed.hasPrefix("/*"), trimmed.contains("=") else { continue }
            // "key" = "value";
            let parts = trimmed.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            let key = parts[0].trimmingCharacters(in: CharacterSet(charactersIn: " \"\t"))
            var value = parts[1].trimmingCharacters(in: .whitespaces)
            if value.hasSuffix(";") { value.removeLast() }
            value = value.trimmingCharacters(in: CharacterSet(charactersIn: " \"\t"))
            guard !key.isEmpty, !value.isEmpty else { continue }
            result[key] = value
        }
        return result
    }

    // MARK: - Constant → key

    /// Constant name → localisation key, from `static let x = Localized.string(from: "key")`.
    ///
    /// Only the constant's own name is recorded, not its enclosing type: a call site writes
    /// `Localized.learnMore`, and resolving the type it hangs off would mean tracking the
    /// `private extension Localized` blocks these are always declared in. The cost of ignoring
    /// the type is that two modules declaring the same constant name with different keys
    /// collide, which is why a collision drops the entry rather than guessing.
    public final class KeyCollector: SyntaxVisitor {
        private(set) public var keys: [String: String] = [:]
        private var ambiguous: Set<String> = []

        public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
            super.init(viewMode: viewMode)
        }

        public static func collect(from syntax: some SyntaxProtocol) -> [String: String] {
            let c = KeyCollector()
            c.walk(syntax)
            return c.keys
        }

        public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
            for binding in node.bindings {
                guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                let name = pattern.identifier.text
                let value: ExprSyntax? = binding.initializer?.value
                    ?? binding.accessorBlock.flatMap { Self.singleExpression(of: $0) }
                guard let value, let key = Self.lookupKey(in: value) else { continue }
                record(name: name, key: key)
            }
            return .visitChildren
        }

        private func record(name: String, key: String) {
            guard !ambiguous.contains(name) else { return }
            if let existing = keys[name] {
                if existing != key {
                    keys[name] = nil
                    ambiguous.insert(name)
                }
                return
            }
            keys[name] = key
        }

        private static func singleExpression(of accessor: AccessorBlockSyntax) -> ExprSyntax? {
            guard case .getter(let statements) = accessor.accessors,
                  statements.count == 1,
                  let only = statements.first
            else { return nil }
            return only.item.as(ExprSyntax.self)
        }

        /// The first string-literal argument of a lookup call anywhere in the expression, so
        /// `Localized.string(from: "a.b")` and `Localized.string("a.b", args: x)` both resolve.
        static func lookupKey(in expr: ExprSyntax) -> String? {
            var found: String?
            func walk(_ node: Syntax) {
                if found != nil { return }
                if let call = node.as(FunctionCallExprSyntax.self),
                   let member = call.calledExpression.as(MemberAccessExprSyntax.self),
                   lookupFunctions.contains(member.declName.baseName.text) {
                    for arg in call.arguments {
                        if let lit = arg.expression.as(StringLiteralExprSyntax.self) {
                            found = lit.segments
                                .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
                                .joined()
                            return
                        }
                    }
                }
                for child in node.children(viewMode: .sourceAccurate) { walk(child) }
            }
            walk(Syntax(expr))
            return found
        }
    }
}
