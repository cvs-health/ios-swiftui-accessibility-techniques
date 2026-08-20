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

// MARK: - Motion Actuation Missing Alternative Rule

/// Flags files that use CoreMotion to drive app functionality (device shake, tilt,
/// accelerometer, gyroscope) without a visible UI control alternative.
///
/// WCAG 2.5.4 requires that any functionality triggered by device motion can also be
/// operated through a standard UI control — users who have their device mounted in a
/// fixed position (e.g. wheelchair users) or who have motor disabilities cannot
/// physically move the device to trigger motion-based actions.
///
/// Example of a compliant pattern:
/// ```swift
/// // Motion trigger
/// motionManager.startDeviceMotionUpdates(to: .main) { _, _ in
///     undoLastAction()
/// }
/// // Required: equivalent UI control
/// Button("Undo") { undoLastAction() }
/// ```
///
/// This rule fires as a **warning** because the UI alternative may be defined in a
/// parent view or a different file that static analysis cannot see. Review manually
/// to confirm a standard control alternative exists and is reachable.
///
/// WCAG 2.5.4 Motion Actuation (Level A)
public struct MotionActuationMissingAlternativeRule: A11yRule {
    public let id = "motion-actuation-missing-alternative"
    public let name = "Motion Actuation Missing UI Control Alternative"
    public let severity = A11ySeverity.warning
    public let impact = A11yImpact.serious
    public let wcagCriteria = ["2.5.4"]
    public let description = "CoreMotion-driven functionality (shake, tilt, accelerometer, gyroscope) must also be operable through a standard UI control. Users with mounted devices or motor disabilities cannot physically move their device to trigger motion-based actions."

    public init() {}

    private static let motionTypeNames: Set<String> = [
        "CMMotionManager",
        "CMDeviceMotion",
        "CMAccelerometerData",
        "CMGyroData",
        "CMAttitude",
        "CMMagnetometerData",
    ]

    private static let motionMethodNames: Set<String> = [
        "startAccelerometerUpdates",
        "startGyroUpdates",
        "startDeviceMotionUpdates",
        "startMagnetometerUpdates",
        "accelerometerData",
        "gyroData",
        "deviceMotion",
    ]

    public func check(syntax: SourceFileSyntax, context: RuleContext) -> [A11yDiagnostic] {
        let sourceText = context.sourceText
        let hasMotionType   = Self.motionTypeNames.contains   { sourceText.contains($0) }
        let hasMotionMethod = Self.motionMethodNames.contains { sourceText.contains($0) }
        guard hasMotionType || hasMotionMethod else { return [] }

        let visitor = MotionActuationVisitor(viewMode: .sourceAccurate)
        visitor.walk(syntax)

        guard !visitor.motionUsages.isEmpty else { return [] }

        return visitor.motionUsages.map { node in
            makeDiagnostic(
                message: "CoreMotion detected (\(node.symbolName)) without a confirmed UI control alternative in this file. Functionality triggered by device motion (shake, tilt, accelerometer) must also be operable via a standard Button or control so users with mounted devices can access it (WCAG 2.5.4). Confirm a UI alternative exists — it may be in a parent view or a different file.",
                node: node.syntaxNode,
                context: context,
                suggestion: "Add a Button that triggers the same action as the motion event, or an on-screen control to disable motion input"
            )
        }
    }
}

// MARK: - Visitor

private struct MotionUsage {
    let symbolName: String
    let syntaxNode: any SyntaxProtocol
}

private class MotionActuationVisitor: SyntaxVisitor {
    var motionUsages: [MotionUsage] = []

    private static let motionTypeNames: Set<String> = [
        "CMMotionManager",
        "CMDeviceMotion",
        "CMAccelerometerData",
        "CMGyroData",
        "CMAttitude",
        "CMMagnetometerData",
    ]

    private static let motionMethodNames: Set<String> = [
        "startAccelerometerUpdates",
        "startGyroUpdates",
        "startDeviceMotionUpdates",
        "startMagnetometerUpdates",
    ]

    // Flag CoreMotion type declarations (e.g. `let manager = CMMotionManager()`)
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let ref = node.calledExpression.as(DeclReferenceExprSyntax.self),
           Self.motionTypeNames.contains(ref.baseName.text) {
            motionUsages.append(MotionUsage(symbolName: ref.baseName.text, syntaxNode: node))
        }
        return .visitChildren
    }

    // Flag CoreMotion method calls (e.g. `manager.startAccelerometerUpdates(...)`)
    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        if Self.motionMethodNames.contains(node.declName.baseName.text) {
            motionUsages.append(MotionUsage(symbolName: node.declName.baseName.text, syntaxNode: node))
        }
        return .visitChildren
    }
}
