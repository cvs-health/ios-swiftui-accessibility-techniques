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

/// Collects the names of `@ScaledMetric` properties in a file, so a rule looking at a
/// numeric size can tell a fixed value from one that already scales.
///
/// `@ScaledMetric` is the sanctioned way to get a custom size that tracks Dynamic Type:
///
/// ```swift
/// @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 16
/// // …
/// Image(systemName: "star").font(.system(size: iconSize))
/// ```
///
/// A size rule that matched `.system(size:` on the text alone reported this, which is the
/// worst kind of false positive: it flags the correct fix. The wrapper scales the value as
/// the user's text-size preference changes, so the font does too.
///
/// `relativeTo:` is optional — without it the metric is relative to `.body` — so its absence
/// is not evidence of anything.
public final class ScaledMetricCollector: SyntaxVisitor {
    /// Names of properties declared with `@ScaledMetric`.
    private(set) public var names: Set<String> = []

    public override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    public static func collect(from syntax: some SyntaxProtocol) -> Set<String> {
        let collector = ScaledMetricCollector()
        collector.walk(syntax)
        return collector.names
    }

    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        let isScaled = node.attributes.contains { element in
            guard case .attribute(let attribute) = element else { return false }
            return attribute.attributeName.trimmedDescription == "ScaledMetric"
        }
        guard isScaled else { return .visitChildren }

        for binding in node.bindings {
            if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                names.insert(pattern.identifier.text)
            }
        }
        return .visitChildren
    }
}
