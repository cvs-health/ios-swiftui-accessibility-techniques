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

/// Collects file-local numeric constants so a rule can resolve an identifier to the number it
/// holds rather than giving up on it.
///
/// A duration is rarely written inline at the point it matters:
///
/// ```swift
/// private let loadingDuration: TimeInterval = 20.0
/// // …
/// withAnimation(.linear(duration: loadingDuration)) { progress = 1.0 }
/// ```
///
/// A rule that only read literals would see `duration: loadingDuration`, learn nothing, and
/// either stay silent on a twenty-second animation or report every animation to be safe.
public final class NumericConstantCollector: SyntaxVisitor {
    /// Identifier name to its numeric value.
    private(set) public var constants: [String: Double] = [:]

    /// Names declared more than once with different values. A call site cannot say which was
    /// meant, so these are dropped rather than guessed.
    private var ambiguous: Set<String> = []

    public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    public static func collect(from syntax: some SyntaxProtocol) -> [String: Double] {
        let collector = NumericConstantCollector()
        collector.walk(syntax)
        return collector.constants
    }

    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for binding in node.bindings {
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
            let name = pattern.identifier.text

            if let initializer = binding.initializer,
               let value = Self.numericValue(of: initializer.value) {
                record(name: name, value: value)
                continue
            }

            if let accessor = binding.accessorBlock,
               case .getter(let statements) = accessor.accessors,
               statements.count == 1,
               let only = statements.first,
               let expression = only.item.as(ExprSyntax.self),
               let value = Self.numericValue(of: expression) {
                record(name: name, value: value)
            }
        }
        return .visitChildren
    }

    /// `init(animationDuration: Double = 8.0)` — the default value of a parameter.
    public override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        guard let defaultValue = node.defaultValue,
              let value = Self.numericValue(of: defaultValue.value) else { return .visitChildren }
        let name = (node.secondName ?? node.firstName).text
        record(name: name, value: value)
        return .visitChildren
    }

    /// A float or integer literal, with or without a leading minus.
    public static func numericValue(of expr: ExprSyntax) -> Double? {
        if let float = expr.as(FloatLiteralExprSyntax.self) {
            return Double(float.literal.text.replacingOccurrences(of: "_", with: ""))
        }
        if let integer = expr.as(IntegerLiteralExprSyntax.self) {
            return Double(integer.literal.text.replacingOccurrences(of: "_", with: ""))
        }
        if let prefix = expr.as(PrefixOperatorExprSyntax.self),
           prefix.operator.text == "-",
           let inner = Self.numericValue(of: prefix.expression) {
            return -inner
        }
        return nil
    }

    private func record(name: String, value: Double) {
        guard !ambiguous.contains(name) else { return }
        if let existing = constants[name] {
            if existing != value {
                constants[name] = nil
                ambiguous.insert(name)
            }
            return
        }
        constants[name] = value
    }
}
