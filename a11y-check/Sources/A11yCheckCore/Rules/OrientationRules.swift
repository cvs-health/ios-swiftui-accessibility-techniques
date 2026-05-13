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

/// Flags views that force a specific device orientation, preventing users
/// from using the app in their preferred orientation (e.g. mounted wheelchair users
/// who can only use landscape).
///
/// WCAG 1.3.4 Orientation (Level AA)
public struct OrientationLockRule: A11yRule {
    public let id = "orientation-lock"
    public let name = "Content Locked to One Orientation"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.3.4"]
    public let description = "Content should not be locked to a single display orientation (portrait or landscape only) unless a specific orientation is essential. Users with mounted devices may not be able to rotate them."

    public init() {}

    private static let orientationLockPatterns: [String] = [
        "supportedInterfaceOrientations",
        "UISupportedInterfaceOrientations",
        "UIInterfaceOrientationMask.portrait",
        "UIInterfaceOrientationMask.landscape",
        ".portrait",
        ".landscapeLeft",
        ".landscapeRight",
    ]

    private static let lockingAPIs: Set<String> = [
        "supportedInterfaceOrientations",
        "requestGeometryUpdate",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        var diagnostics: [A11yDiagnostic] = []
        let sourceText = context.sourceText

        guard sourceText.contains("orientation") ||
              sourceText.contains("Orientation") ||
              sourceText.contains("InterfaceOrientation") else {
            return []
        }

        let visitor = OrientationVisitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)

        for node in visitor.lockingCalls {
            diagnostics.append(makeDiagnostic(
                message: "Content appears to be locked to a specific orientation. Users with mounted devices or motor disabilities may not be able to rotate their device. Ensure the app supports both portrait and landscape unless a specific orientation is essential (WCAG 1.3.4).",
                node: node,
                context: context,
                suggestion: "Support both portrait and landscape orientations"
            ))
        }

        for node in visitor.lockingProperties {
            diagnostics.append(makeDiagnostic(
                message: "supportedInterfaceOrientations restricts orientation. Ensure both portrait and landscape are supported unless a specific orientation is essential (WCAG 1.3.4).",
                node: node,
                context: context,
                suggestion: "Return .all or .allButUpsideDown to support both orientations"
            ))
        }

        return diagnostics
    }
}

private class OrientationVisitor: SyntaxVisitor {
    var lockingCalls: [SyntaxProtocol] = []
    var lockingProperties: [SyntaxProtocol] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let member = node.calledExpression.as(MemberAccessExprSyntax.self),
           member.declName.baseName.text == "requestGeometryUpdate" {
            lockingCalls.append(node)
        }
        return .visitChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.name.text == "supportedInterfaceOrientations" {
            let bodyText = node.body?.description ?? ""
            if !bodyText.contains(".all") && !bodyText.contains("allButUpsideDown") {
                lockingProperties.append(node)
            }
        }
        return .visitChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        let text = node.description
        if text.contains("supportedInterfaceOrientations") {
            if !text.contains(".all") && !text.contains("allButUpsideDown") {
                lockingProperties.append(node)
            }
        }
        return .visitChildren
    }
}
