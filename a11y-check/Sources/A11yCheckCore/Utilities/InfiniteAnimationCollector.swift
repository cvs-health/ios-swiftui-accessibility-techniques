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

/// Collects the names of file-local bindings that hold an endlessly repeating animation, so a
/// rule can see through an identifier to the animation it names.
///
/// Spinners are routinely written with the animation held in a property:
///
/// ```swift
/// var foreverAnimation: Animation {
///     Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
/// }
/// // …
/// .animation(isAnimating ? foreverAnimation : .default, value: isAnimating)
/// ```
///
/// Matching `repeatForever` at the call site alone misses this, which is how a set of
/// indefinitely rotating spinners went unreported while dozens of brief user-initiated
/// transitions were flagged.
public final class InfiniteAnimationCollector: SyntaxVisitor {
    /// Names of bindings whose value repeats without end.
    private(set) public var names: Set<String> = []

    public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    public static func collect(from syntax: some SyntaxProtocol) -> Set<String> {
        let collector = InfiniteAnimationCollector()
        collector.walk(syntax)
        return collector.names
    }

    /// Whether an animation expression repeats without end.
    ///
    /// `repeatForever` is unambiguous. `repeatCount:` is only endless when the count is an
    /// infinity — a finite count eventually stops, and 2.2.2 exempts motion under five
    /// seconds, so a small count is not this rule's business.
    public static func describesInfiniteRepeat(_ text: String) -> Bool {
        if text.contains("repeatForever") { return true }
        guard text.contains("repeatCount") else { return false }
        return text.contains("infinity")
            || text.contains(".infinite")
            || text.contains("greatestFiniteMagnitude")
    }

    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for binding in node.bindings {
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
            let name = pattern.identifier.text

            // `let spin = Animation.linear(duration: 1).repeatForever()`
            if let initializer = binding.initializer {
                record(name: name, text: initializer.value.trimmedDescription)
                continue
            }

            // `var spin: Animation { .linear(duration: 1).repeatForever() }`
            if let accessor = binding.accessorBlock,
               let text = Self.singleExpressionBody(of: accessor) {
                record(name: name, text: text)
            }
        }
        return .visitChildren
    }

    /// `init(spin: Animation = .linear(duration: 1).repeatForever())`, and the same for any
    /// function parameter — it reads identically at the call site.
    public override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        guard let defaultValue = node.defaultValue else { return .visitChildren }
        let name = (node.secondName ?? node.firstName).text
        record(name: name, text: defaultValue.value.trimmedDescription)
        return .visitChildren
    }

    private func record(name: String, text: String) {
        guard Self.describesInfiniteRepeat(text) else { return }
        names.insert(name)
    }

    /// The sole expression of a computed property body, if it has exactly one statement.
    private static func singleExpressionBody(of accessor: AccessorBlockSyntax) -> String? {
        guard case .getter(let statements) = accessor.accessors else { return nil }
        guard statements.count == 1, let only = statements.first else { return nil }
        return only.item.trimmedDescription
    }
}
