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

// MARK: - Video / Audio Auto-play Rule

/// Flags `.onAppear` or `.task` closures that call `.play()`, causing audio or
/// video to start automatically without user initiation.
///
/// WCAG 1.4.2 Audio Control requires that if any audio or video plays automatically
/// for more than 3 seconds, the user must be able to pause, stop, or adjust its
/// volume independently of the system volume. Auto-playing media disorients
/// VoiceOver users (their screen reader speech is drowned out) and users with
/// cognitive disabilities.
///
/// Compliant pattern — use a play/pause Button:
/// ```swift
/// @State private var isPlaying = false
/// VideoPlayer(player: player)
///     .accessibilityElement(children: .contain)
///     .accessibilityLabel("Tutorial Video")
/// Button(isPlaying ? "Pause" : "Play") {
///     isPlaying ? player.pause() : player.play()
///     isPlaying.toggle()
/// }
/// .accessibilityLabel(isPlaying ? "Pause" : "Play")
/// ```
///
/// This rule fires as a **warning** because there are edge cases where silent
/// video used as decoration, or audio explicitly acknowledged by the user before
/// navigation, may be acceptable. Review manually to confirm the media is either
/// inaudible, user-initiated, or provides an immediately reachable stop mechanism.
///
/// WCAG 1.4.2 Audio Control (Level A)
public struct VideoAudioAutoplayRule: A11yRule {
    public let id = "video-audio-autoplay"
    public let name = "Video or Audio Starts Playing Automatically"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["1.4.2"]
    public let description = "Video or audio that calls .play() inside .onAppear or .task starts without user initiation. Provide a play/pause Button so users can control when media plays. Auto-playing media drowns out VoiceOver speech and disorients users with cognitive disabilities."

    public init() {}

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let source = context.sourceText
        guard source.contains("play()") else { return [] }
        guard source.contains("onAppear") || source.contains(".task") else { return [] }

        let visitor = AutoplayVisitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)

        return visitor.violations.map { violation in
            makeDiagnostic(
                message: "Media .play() called inside .\(violation.modifierName) { } causes audio or video to start automatically without user initiation. VoiceOver speech is disrupted and users with cognitive disabilities cannot stop the media in time. Provide a play/pause Button instead (WCAG 1.4.2).",
                node: violation.callNode,
                context: context,
                suggestion: "Remove .play() from .\(violation.modifierName) { } and expose a play/pause Button the user can focus on and activate"
            )
        }
    }
}

// MARK: - Visitor

private struct AutoplayViolation {
    let modifierName: String
    let callNode: FunctionCallExprSyntax
}

private class AutoplayVisitor: SyntaxVisitor {
    var violations: [AutoplayViolation] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) else {
            return .visitChildren
        }

        let modName = memberAccess.declName.baseName.text
        guard modName == "onAppear" || modName == "task" else {
            return .visitChildren
        }

        let closureText: String
        if let trailing = node.trailingClosure {
            closureText = trailing.trimmedDescription
        } else if let inlineArg = node.arguments.first(where: {
            $0.expression.as(ClosureExprSyntax.self) != nil
        }) {
            closureText = inlineArg.expression.trimmedDescription
        } else {
            return .visitChildren
        }

        if closureText.contains(".play()") {
            violations.append(AutoplayViolation(modifierName: modName, callNode: node))
        }

        return .visitChildren
    }
}
