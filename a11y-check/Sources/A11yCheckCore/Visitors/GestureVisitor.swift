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

/// Visitor that finds `.onTapGesture` usages and checks whether
/// the element also has `.accessibilityAddTraits(.isButton)`.
///
/// Also finds custom gesture modifiers that imply interactive behavior.
public final class GestureVisitor: SyntaxVisitor {

    /// A detected gesture usage with context about accessibility traits.
    public struct DetectedGesture {
        /// The modifier name (e.g. "onTapGesture", "onLongPressGesture").
        public let gestureName: String
        /// The function call expression for this gesture modifier.
        public let callExpr: FunctionCallExprSyntax
        /// Whether the chain also contains `.accessibilityAddTraits(.isButton)`.
        public let hasButtonTrait: Bool
        /// Whether the chain also contains `.accessibilityLabel(...)`.
        public let hasAccessibilityLabel: Bool
        /// Whether the gesture closure is a keyboard-dismiss pattern —
        /// e.g. `.onTapGesture { hideKeyboard() }` on a background view.
        /// These don't represent interactive UI controls and should not
        /// require `.accessibilityAddTraits(.isButton)`.
        public let isKeyboardDismiss: Bool
        /// Whether the gesture sits in the `makeBody(configuration:)` of a style
        /// conformance for a native control — a `DisclosureGroupStyle`, `ButtonStyle`
        /// and friends. The control the style is applied to already supplies the role,
        /// so the tap does not need a trait of its own.
        public let isNativeControlStyleBody: Bool

        /// Node positioned at the gesture modifier token rather than the
        /// base of the chain. Use for diagnostic reporting.
        public var reportNode: any SyntaxProtocol {
            if let memberAccess = callExpr.calledExpression.as(MemberAccessExprSyntax.self) {
                return memberAccess.period
            }
            return callExpr
        }
    }

    /// Gestures that imply the element is interactive.
    private static let interactiveGestures: Set<String> = [
        "onTapGesture",
        "onLongPressGesture",
    ]

    public private(set) var detectedGestures: [DetectedGesture] = []

    public init() {
        super.init(viewMode: .sourceAccurate)
    }

    public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) else {
            return .visitChildren
        }
        let name = memberAccess.declName.baseName.text
        guard Self.interactiveGestures.contains(name) else {
            return .visitChildren
        }

        // Walk up the modifier chain to find the root, then collect all modifiers
        let chainRoot = findChainRoot(for: ExprSyntax(node))
        let modifiers = ModifierCollector.collect(from: chainRoot)

        // The trait may sit on the gesture's own chain or on a container enclosing it, so both
        // are checked through the same predicate.
        let hasTraitOnOwnChain = modifiers.allModifiers.contains { mod in
            Self.announcesInteractiveRole(modifierName: mod.name, arguments: mod.arguments)
        }
        let hasTraitOnEnclosingChain = Self.enclosingChainAnnouncesInteractiveRole(chainRoot)

        let hasLabel = modifiers.hasModifier("accessibilityLabel")

        detectedGestures.append(DetectedGesture(
            gestureName: name,
            callExpr: node,
            hasButtonTrait: hasTraitOnOwnChain || hasTraitOnEnclosingChain,
            hasAccessibilityLabel: hasLabel,
            isKeyboardDismiss: Self.isKeyboardDismissGesture(node),
            isNativeControlStyleBody: Self.isInsideNativeControlStyleBody(node)
        ))

        return .visitChildren
    }

    /// Traits that announce an interactive role. `.isLink` counts as well as `.isButton`:
    /// the requirement is that a tappable element announces an interactive role, and for
    /// something opening a URL "Link" is the more accurate one — a real case was
    /// `.accessibilityAddTraits(.isLink)` beside an external-link alert, reported as though
    /// it announced nothing. This matches SwiftLint's `accessibility_trait_for_button`,
    /// which accepts either trait.
    private static let interactiveTraits = ["isButton", "isLink"]

    /// Presentation modifiers whose closure is a separate screen. A trait on the presenting
    /// view says nothing about a tap inside the sheet it presents, so the enclosing-chain
    /// walk stops rather than crossing one of these.
    private static let presentationModifiers: Set<String> = [
        "sheet",
        "fullScreenCover",
        "popover",
        "alert",
        "confirmationDialog",
        "contextMenu",
    ]

    /// Style protocols whose `makeBody(configuration:)` decorates a native control. The
    /// control itself carries the role and state, so a tap wired to `configuration` inside
    /// one of these is already announced correctly.
    private static let nativeControlStyleProtocols: Set<String> = [
        "DisclosureGroupStyle",
        "ButtonStyle",
        "PrimitiveButtonStyle",
        "ToggleStyle",
        "MenuStyle",
    ]

    /// Whether a single modifier announces an interactive role, or is the author explicitly
    /// opting out of one.
    static func announcesInteractiveRole(
        modifierName: String,
        arguments: [(label: String?, text: String)]
    ) -> Bool {
        switch modifierName {
        case "accessibilityAddTraits":
            return arguments.contains { arg in
                interactiveTraits.contains { arg.text.contains($0) }
            }
        case "accessibility":
            // The older `.accessibility(addTraits:)` API.
            return arguments.contains { arg in
                arg.label == "addTraits" && interactiveTraits.contains { arg.text.contains($0) }
            }
        case "accessibilityRemoveTraits":
            // `.accessibilityRemoveTraits([.isButton])` is the author stating this is
            // deliberately not a button — a tap used to move focus, say. Asking them to add
            // back the trait they just removed makes the rule unsatisfiable, so an explicit
            // opt-out is honoured.
            return arguments.contains { $0.text.contains("isButton") }
        default:
            return false
        }
    }

    /// Whether a container enclosing the gesture announces the interactive role.
    ///
    /// An accessibility modifier on a container applies to the element that container
    /// produces — whether it is collapsed into one element by
    /// `.accessibilityElement(children: .combine)` or propagated down to its children — so a
    /// trait there does reach the tapped element. Only the gesture's own chain was being
    /// inspected, which reported a correctly-announced card as announcing nothing.
    static func enclosingChainAnnouncesInteractiveRole(_ chainRoot: ExprSyntax) -> Bool {
        var current = Syntax(chainRoot)

        while let parent = current.parent {
            // A closure belonging to a presentation modifier is a different screen; and a
            // declaration boundary means we have left the view this gesture lives in.
            if let closure = parent.as(ClosureExprSyntax.self),
               enclosesPresentationModifier(closure) {
                return false
            }
            if parent.is(FunctionDeclSyntax.self) || parent.is(VariableDeclSyntax.self) {
                return false
            }

            if let funcCall = parent.as(FunctionCallExprSyntax.self),
               let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self) {
                let args: [(label: String?, text: String)] = funcCall.arguments.map { arg in
                    (label: arg.label?.text, text: arg.expression.trimmedDescription)
                }
                if announcesInteractiveRole(
                    modifierName: memberAccess.declName.baseName.text,
                    arguments: args
                ) {
                    return true
                }
            }

            current = parent
        }
        return false
    }

    /// Whether this closure is the content of a presentation modifier.
    private static func enclosesPresentationModifier(_ closure: ClosureExprSyntax) -> Bool {
        var owner: Syntax? = closure.parent
        // The closure is either trailing on the call or wrapped in its argument list.
        while let node = owner {
            if let funcCall = node.as(FunctionCallExprSyntax.self) {
                guard let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self)
                else { return false }
                return presentationModifiers.contains(memberAccess.declName.baseName.text)
            }
            if node.is(LabeledExprSyntax.self) || node.is(LabeledExprListSyntax.self) {
                owner = node.parent
                continue
            }
            return false
        }
        return false
    }

    /// Whether the gesture sits inside a `makeBody(configuration:)` on a type conforming to
    /// one of the native-control style protocols.
    static func isInsideNativeControlStyleBody(_ node: some SyntaxProtocol) -> Bool {
        var current: Syntax? = Syntax(node)
        var insideMakeBody = false

        while let parent = current?.parent {
            if let funcDecl = parent.as(FunctionDeclSyntax.self),
               funcDecl.name.text == "makeBody" {
                insideMakeBody = true
            }
            if insideMakeBody, let inherited = inheritedTypeNames(of: parent),
               !inherited.isDisjoint(with: nativeControlStyleProtocols) {
                return true
            }
            current = parent
        }
        return false
    }

    /// The names a declaration conforms to, for the declaration kinds a style can be on.
    private static func inheritedTypeNames(of node: Syntax) -> Set<String>? {
        let clause: InheritanceClauseSyntax?
        switch node.kind {
        case .structDecl: clause = node.as(StructDeclSyntax.self)?.inheritanceClause
        case .classDecl: clause = node.as(ClassDeclSyntax.self)?.inheritanceClause
        case .enumDecl: clause = node.as(EnumDeclSyntax.self)?.inheritanceClause
        case .extensionDecl: clause = node.as(ExtensionDeclSyntax.self)?.inheritanceClause
        default: return nil
        }
        guard let clause else { return nil }
        return Set(clause.inheritedTypes.map { $0.type.trimmedDescription })
    }

    /// Returns true when the closure body is a single keyboard-dismiss call:
    /// `hideKeyboard()`, `dismissKeyboard()`, `endEditing(...)`, `resignFirstResponder()`.
    private static func isKeyboardDismissGesture(_ node: FunctionCallExprSyntax) -> Bool {
        guard let closure = node.trailingClosure
                ?? node.arguments.first?.expression.as(ClosureExprSyntax.self),
              closure.statements.count == 1 else { return false }

        let text = closure.statements.description.lowercased()
        return ["hidekeyboard", "dismisskeyboard", "endediting", "resignfirstresponder"]
            .contains { text.contains($0) }
    }

    private func findChainRoot(for expr: ExprSyntax) -> ExprSyntax {
        var current = expr
        while let parent = current.parent {
            if let memberAccess = parent.as(MemberAccessExprSyntax.self) {
                if let grandparent = memberAccess.parent?.as(FunctionCallExprSyntax.self) {
                    current = ExprSyntax(grandparent)
                    continue
                }
            }
            if let funcCall = parent.as(FunctionCallExprSyntax.self),
               let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
               memberAccess.base?.id == current.id {
                current = ExprSyntax(funcCall)
                continue
            }
            break
        }
        return current
    }
}

