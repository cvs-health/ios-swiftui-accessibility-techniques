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

import XCTest
import SwiftParser
import SwiftSyntax
@testable import A11yCheckCore

final class A11yCheckCoreTests: XCTestCase {

    private var registry: RuleRegistry!

    override func setUp() {
        super.setUp()
        registry = RuleRegistry()
    }

    // MARK: - Helper

    /// Parse source and run all rules, returning diagnostics.
    private func analyze(_ source: String, file: String = "test.swift") -> [A11yDiagnostic] {
        registry.analyze(sourceText: source, filePath: file)
    }

    /// Parse source and run a single rule by ID.
    private func analyze(
        _ source: String,
        ruleID: String,
        configOptions: A11yConfig.ConfigOptions = .init()
    ) -> [A11yDiagnostic] {
        let syntax = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: "test.swift", tree: syntax)
        let context = RuleContext(
            filePath: "test.swift",
            sourceText: source,
            locationConverter: converter,
            configOptions: configOptions
        )
        guard let rule = registry.rules.first(where: { $0.id == ruleID }) else {
            XCTFail("Rule \(ruleID) not found")
            return []
        }
        return rule.check(syntax: syntax, context: context)
    }

    // MARK: - Image Rules

    func testImageMissingLabel_flagsBadImage() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "newspaper")
            }
        }
        """
        let diags = analyze(source, ruleID: "image-missing-label")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("missing .accessibilityLabel"))
    }

    func testImageMissingLabel_passesGoodImage() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "newspaper")
                    .accessibilityLabel("News")
            }
        }
        """
        let diags = analyze(source, ruleID: "image-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testImageMissingLabel_passesDecorativeImage() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(decorative: "background")
            }
        }
        """
        let diags = analyze(source, ruleID: "image-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testImageMissingLabel_passesHiddenImage() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "globe")
                    .accessibilityHidden(true)
            }
        }
        """
        let diags = analyze(source, ruleID: "image-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testImageLabelContainsRole_flagsBadLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "star.fill")
                    .accessibilityLabel("Star icon")
            }
        }
        """
        let diags = analyze(source, ruleID: "image-label-contains-role")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("icon"))
    }

    func testImageLabelContainsRole_passesGoodLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "star.fill")
                    .accessibilityLabel("Favorite")
            }
        }
        """
        let diags = analyze(source, ruleID: "image-label-contains-role")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Heading Rules

    func testHeadingTraitMissing_flagsBadHeading() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Store Hours")
                    .font(.title)
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 1)
    }

    func testHeadingTraitMissing_passesGoodHeading() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Store Hours")
                    .font(.title)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 0)
    }

    /// Most apps style headings through their own type scale, not Apple's styles. Each of these
    /// is a real-world design-system token shape.
    func testHeadingTraitMissing_flagsDesignSystemHeadingTokens() {
        for token in [
            ".themeHeadingXL",              // Aetna Health
            ".appTitleLarge",
            ".dsHeading2",
            ".themeSubheadingM",            // a subheading is a heading
            ".subheadline",                  // ditto, and Apple's own name says so
            ".subtitle",
            ".subHeaderL",
            ".themeDisplayXL",
            ".themeHeadingL.weight(.bold)", // weight chain must not hide the token
            "Font.largeTitle",              // fully qualified
        ] {
            let source = """
            import SwiftUI
            struct MyView: View {
                var body: some View {
                    Text("Store Hours")
                        .font(\(token))
                }
            }
            """
            let diags = analyze(source, ruleID: "heading-trait-missing")
            XCTAssertEqual(diags.count, 1, "\(token) should be treated as a heading font")
        }
    }

    func testHeadingTraitMissing_ignoresBodyFonts() {
        for token in [
            ".themeParagraphM",
            ".caption",
            ".footnote",
            #".custom("AetnaSans", size: 17)"#,
        ] {
            let source = """
            import SwiftUI
            struct MyView: View {
                var body: some View {
                    Text("Store Hours")
                        .font(\(token))
                }
            }
            """
            let diags = analyze(source, ruleID: "heading-trait-missing")
            XCTAssertEqual(diags.count, 0, "\(token) should not be treated as a heading font")
        }
    }

    /// A font passed in by variable is judged by the token it holds, not by its name. This is
    /// the real `InformationBannerView` shape: the stored properties carry no initialiser, so
    /// the only place the fonts appear is the init signature.
    func testHeadingTraitMissing_resolvesVariableFontToDeclaredToken() {
        let source = """
        import SwiftUI
        struct InformationBannerView: View {
            let title: String
            let titleFont: Font
            let subtitleFont: Font
            init(title: String, titleFont: Font = .themeHeadingM, subtitleFont: Font = .themeParagraphXS) {
                self.title = title
                self.titleFont = titleFont
                self.subtitleFont = subtitleFont
            }
            var body: some View {
                VStack {
                    Text(title).font(titleFont)
                    Text("sub").font(subtitleFont)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 1, "the heading-token title should report and the paragraph-token subtitle should not")
        XCTAssertEqual(diags.first?.line, 13)
    }

    /// A note after the rule IDs must not change which rules are suppressed. The whole piece
    /// used to become the ID, so such a line silently suppressed nothing.
    func testInlineSuppression_ignoresProseAfterTheRuleIDs() {
        let withNote = """
        import SwiftUI
        struct S: View {
            var body: some View {
                // a11y-check:disable-next-line heading-trait-missing  (set on the container)
                Text("Hours")
                    .font(.themeHeadingXL)
            }
        }
        """
        XCTAssertTrue(analyze(withNote).filter { $0.ruleID == "heading-trait-missing" }.isEmpty)

        let twoIDsAndNote = """
        import SwiftUI
        struct S: View {
            var body: some View {
                // a11y-check:disable-next-line heading-trait-missing, image-missing-label — handled
                Text("Hours")
                    .font(.themeHeadingXL)
            }
        }
        """
        XCTAssertTrue(analyze(twoIDsAndNote).filter { $0.ruleID == "heading-trait-missing" }.isEmpty)

        // A note must not widen the suppression to rules that were not named.
        let otherRuleOnly = """
        import SwiftUI
        struct S: View {
            var body: some View {
                // a11y-check:disable-next-line image-missing-label  (note)
                Text("Hours")
                    .font(.themeHeadingXL)
            }
        }
        """
        XCTAssertEqual(analyze(otherRuleOnly).filter { $0.ruleID == "heading-trait-missing" }.count, 1)
    }

    /// Replacing a chained modifier must not take the view it is attached to with it.
    func testSmallTouchTarget_fixKeepsTheViewItIsAttachedTo() {
        let source = """
        import SwiftUI
        struct TouchView: View {
            var body: some View {
                Button("x") { }
                    .frame(width: 20, height: 20)
            }
        }
        """
        let diags = analyze(source, ruleID: "small-touch-target")
        XCTAssertEqual(diags.count, 1)
        let fixed = applyFix(diags[0], to: source)
        XCTAssertTrue(fixed.contains("Button(\"x\") { }"), "the Button must survive the fix")
        XCTAssertTrue(fixed.contains(".frame(width: 24, height: 24)"))
        XCTAssertFalse(fixed.contains("width: 20"))
    }

    /// A page title is content. Offering a fix meant writing a literal "Page Title" into the
    /// app and then reporting the file clean.
    func testMissingNavigationTitle_offersNoAutofix() {
        let source = """
        import SwiftUI
        struct NavView: View {
            var body: some View {
                NavigationStack {
                    Text("body")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "missing-navigation-title")
        XCTAssertEqual(diags.count, 1)
        XCTAssertNil(diags[0].fix, "no autofix may invent a page title")
        XCTAssertFalse(diags[0].suggestion?.contains("\"Page Title\"") ?? false)
    }

    /// Apply a diagnostic's fix to the source it came from, the way AutoFixer would.
    private func applyFix(_ diag: A11yDiagnostic, to source: String) -> String {
        guard let fix = diag.fix else { return source }
        var bytes = Array(source.utf8)
        bytes.replaceSubrange(
            fix.startOffset ..< fix.endOffset,
            with: Array(fix.replacementText.utf8)
        )
        return String(decoding: bytes, as: UTF8.self)
    }

    /// An inserted modifier must not steal the trailing comment off the line above it.
    /// `// swiftlint:disable:this` moving onto the new line leaves the real offender
    /// unsuppressed and fails `swiftlint --strict`.
    func testModifierFix_leavesTrailingLineCommentOnItsOwnLine() {
        let source = """
        import SwiftUI
        struct CardView: View {
            let title: String
            var body: some View {
                Text(title)
                    .font(.themeHeadingXL) // swiftlint:disable:this no_swiftui_font
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 1)
        let fixed = applyFix(diags[0], to: source)
        XCTAssertTrue(
            fixed.contains(".font(.themeHeadingXL) // swiftlint:disable:this no_swiftui_font"),
            "the comment must stay with the line it was written on"
        )
        XCTAssertTrue(
            fixed.contains(".accessibilityAddTraits(.isHeader)\n"),
            "the inserted modifier must end its own line, carrying no comment"
        )
        XCTAssertFalse(fixed.contains(".accessibilityAddTraits(.isHeader) //"))
    }

    /// The comment step-over must not fire when real code follows on the same line.
    func testModifierFix_singleLineBodyKeepsTrailingBraces() {
        let source = """
        import SwiftUI
        struct B: View { var body: some View { Text("Hours").font(.title) } }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 1)
        let fixed = applyFix(diags[0], to: source)
        XCTAssertTrue(fixed.contains(".accessibilityAddTraits(.isHeader)"))
        XCTAssertTrue(fixed.contains("} }"), "the closing braces must survive the insert")
    }

    func testLineEndInsertOffset_onlyStepsOverWhitespaceAndLineComments() {
        // "a" then end of line: insert before the newline, after the spaces.
        let plain = "a  \nb"
        XCTAssertEqual(HeadingTraitMissingRule.lineEndInsertOffset(after: 1, in: plain), 3)
        // A line comment is stepped over so it stays on its own line.
        let commented = "a // note\nb"
        XCTAssertEqual(HeadingTraitMissingRule.lineEndInsertOffset(after: 1, in: commented), 9)
        // Real code follows, so the offset is left alone.
        let trailingCode = "a } }\nb"
        XCTAssertEqual(HeadingTraitMissingRule.lineEndInsertOffset(after: 1, in: trailingCode), 1)
        // A lone slash is not a comment.
        let slash = "a / b\nc"
        XCTAssertEqual(HeadingTraitMissingRule.lineEndInsertOffset(after: 1, in: slash), 1)
        // End of file with no newline.
        XCTAssertEqual(HeadingTraitMissingRule.lineEndInsertOffset(after: 1, in: "a"), 1)
    }

    /// A trait on an enclosing view already marks the heading; reporting the inner Text
    /// would flag code that is correct.
    func testHeadingTraitMissing_ancestorAlreadyCarriesHeaderTrait() {
        let source = """
        import SwiftUI
        struct BenefitDetailView: View {
            let title: String
            var body: some View {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.themeHeadingXL)
                    Text("savings")
                }
                .accessibilityAddTraits(.isHeader)
                .accessibilityElement(children: .combine)
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 0)
    }

    /// A merging container is a single element, so the trait belongs on the container.
    /// The finding is retargeted there rather than dropped — the defect is real.
    func testHeadingTraitMissing_retargetsToChildMergingContainer() {
        let source = """
        import SwiftUI
        struct BentoBoxCard: View {
            let title: String
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.themeHeadingXL)
                    Text("description")
                }
                .accessibilityElement(children: .combine)
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags.first?.line, 5, "should report the container, not the Text on line 6")
        XCTAssertTrue(
            diags.first?.message.contains("merges its children") ?? false,
            "the message should explain that the trait belongs on the container"
        )
    }

    /// Two headings inside one merging container are one container defect, not two.
    func testHeadingTraitMissing_reportsMergingContainerOnce() {
        let source = """
        import SwiftUI
        struct TwoHeadings: View {
            var body: some View {
                VStack {
                    Text("first").font(.themeHeadingXL)
                    Text("second").font(.themeHeadingM)
                }
                .accessibilityElement(children: .combine)
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 1)
    }

    /// Preview scaffolding is not shipping UI, so a missing trait there is not actionable.
    func testHeadingTraitMissing_skipsPreviewCode() {
        let macroSource = """
        import SwiftUI
        #Preview("Custom") {
            VStack {
                Text("Custom Header")
                    .font(.themeHeadingXL)
            }
        }
        """
        XCTAssertEqual(analyze(macroSource, ruleID: "heading-trait-missing").count, 0)

        let providerSource = """
        import SwiftUI
        struct MyView_Previews: PreviewProvider {
            static var previews: some View {
                Text("Heading")
                    .font(.themeHeadingXL)
            }
        }
        """
        XCTAssertEqual(analyze(providerSource, ruleID: "heading-trait-missing").count, 0)
    }

    /// The skip must not leak out of previews: a real view in the same file still reports.
    func testHeadingTraitMissing_stillReportsShippingViewAlongsidePreview() {
        let source = """
        import SwiftUI
        struct RealView: View {
            var body: some View {
                Text("Real Heading")
                    .font(.themeHeadingXL)
            }
        }
        #Preview {
            RealView()
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags.first?.line, 4)
    }

    /// `titleFont` holding a paragraph token must not report — the name is not the evidence.
    func testHeadingTraitMissing_variableNameDoesNotOverrideItsValue() {
        let source = """
        import SwiftUI
        struct ValueRow: View {
            var titleFont: Font { .themeParagraphS }
            var body: some View {
                Text("Total").font(titleFont)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing").count, 0)
    }

    func testHeadingTraitMissing_resolvesThroughViewModelProperty() {
        let source = """
        import SwiftUI
        struct CardModel { var titleFont: Font = .themeHeadingXL }
        struct CardView: View {
            let viewModel: CardModel
            var body: some View {
                Text("Card").font(viewModel.titleFont)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing").count, 1)
    }

    /// Two components in one file, each with its own `titleFont` and a different value. There
    /// is no way to tell from the call site which declaration applies, so the name is left
    /// unresolved and falls back to the heuristic rather than borrowing one component's scale.
    func testHeadingTraitMissing_ambiguousVariableFallsBackToName() {
        let source = """
        import SwiftUI
        struct A: View {
            var titleFont: Font { .themeHeadingM }
            var body: some View { Text("A").font(titleFont) }
        }
        struct B: View {
            var titleFont: Font { .themeParagraphS }
            var body: some View { Text("B").font(titleFont) }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 2, "both fall back to the name, which reads as a heading")
    }

    func testFontConstantCollector_recordsDeclarationsAndDropsConflicts() {
        let source = """
        import SwiftUI
        struct V: View {
            var headingFont: Font { .themeHeadingXL }
            var inlineFont = Font.themeParagraphM
            func make(bodyFont: Font = .themeParagraphS) {}
            var clash: Font { .themeHeadingM }
        }
        struct W: View {
            var clash: Font { .themeParagraphXS }
        }
        """
        let constants = FontConstantCollector.collect(from: Parser.parse(source: source))
        XCTAssertEqual(constants["headingFont"], ".themeHeadingXL")
        XCTAssertEqual(constants["inlineFont"], "Font.themeParagraphM")
        XCTAssertEqual(constants["bodyFont"], ".themeParagraphS")
        XCTAssertNil(constants["clash"], "conflicting declarations must not resolve")

        XCTAssertEqual(FontConstantCollector.resolve("headingFont", constants: constants), ".themeHeadingXL")
        XCTAssertEqual(FontConstantCollector.resolve("vm.headingFont", constants: constants), ".themeHeadingXL")
        XCTAssertEqual(FontConstantCollector.resolve(".title", constants: constants), ".title")
        XCTAssertEqual(FontConstantCollector.resolve("unknownFont", constants: constants), "unknownFont")
    }

    /// A conditional font must be judged on the fonts, not on whatever picks between them.
    /// Reading `isHeader` as the font name reported two paragraph rows as unmarked headings.
    func testHeadingTraitMissing_conditionalFontIgnoresTheCondition() {
        let source = """
        import SwiftUI
        struct LimitRow: View {
            let isHeader: Bool
            let isBold: Bool
            var body: some View {
                Text("Label").font(isHeader || isBold ? .themeParagraphMStrong : .themeParagraphM)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing").count, 0)
    }

    /// A font that is a heading in either branch still needs the trait.
    func testHeadingTraitMissing_conditionalFontFlagsHeadingBranch() {
        let source = """
        import SwiftUI
        struct LimitRow: View {
            let isBold: Bool
            var body: some View {
                Text("Label").font(isBold ? .themeHeadingM : .themeParagraphM)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing").count, 1)
    }

    func testHeadingFontTokens_scansMemberAccessNotLeadingIdentifier() {
        XCTAssertEqual(HeadingTraitMissingRule.fontTokens(in: ".title"), ["title"])
        XCTAssertEqual(HeadingTraitMissingRule.fontTokens(in: "Font.largeTitle"), ["largeTitle"])
        XCTAssertEqual(
            HeadingTraitMissingRule.fontTokens(in: ".themeHeadingL.weight(.bold)"),
            ["themeHeadingL", "weight", "bold"]
        )
        XCTAssertEqual(
            HeadingTraitMissingRule.fontTokens(in: #".custom("AetnaSans", size: 17)"#),
            ["custom"]
        )
        XCTAssertEqual(
            HeadingTraitMissingRule.fontTokens(in: "isHeader ? .themeParagraphMStrong : .themeParagraphM"),
            ["themeParagraphMStrong", "themeParagraphM"],
            "the condition is not a font token"
        )
        XCTAssertEqual(HeadingTraitMissingRule.fontTokens(in: "titleFont"), ["titleFont"])
    }

    func testHeadingTraitMissing_configCanOptTokenIn() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Store Hours")
                    .font(.brandJumbo)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing").count, 0)

        let opts = A11yConfig.ConfigOptions(headingFonts: ["brandJumbo"])
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing", configOptions: opts).count, 1)
    }

    func testHeadingTraitMissing_configCanOptTokenOut() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Store Hours")
                    .font(.themeHeadingInline)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing").count, 1)

        let opts = A11yConfig.ConfigOptions(headingFontDeny: ["themeHeadingInline"])
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing", configOptions: opts).count, 0)
    }

    /// Deny wins over allow, so a project can contradict itself without the rule guessing.
    func testHeadingTraitMissing_configDenyBeatsAllow() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Store Hours")
                    .font(.brandJumbo)
            }
        }
        """
        let opts = A11yConfig.ConfigOptions(
            headingFonts: ["brandJumbo"],
            headingFontDeny: ["brandJumbo"]
        )
        XCTAssertEqual(analyze(source, ruleID: "heading-trait-missing", configOptions: opts).count, 0)
    }

    /// A design-system heading token on a Button label is still a control label, not a heading.
    func testHeadingTraitMissing_designSystemTokenOnButtonLabelIsNotFlagged() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button {
                } label: {
                    Text("Refill")
                        .font(.themeHeadingM)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "heading-trait-missing")
        XCTAssertEqual(diags.count, 0)
    }

    /// "Learn more" on a Button fails the same way it does on a Link, and that is how the
    /// defect is usually written: the phrase repeated down a page of cards where the
    /// destination differs every time and the name never does.
    func testGenericLinkText_coversButtonsNotJustLinks() {
        for label in ["Learn more", "More options", "Read more", "Click here"] {
            let source = """
            import SwiftUI
            struct MyView: View {
                var body: some View {
                    Button("\(label)") {}
                }
            }
            """
            let diags = analyze(source, ruleID: "generic-link-text")
            XCTAssertEqual(diags.count, 1, "\(label) on a Button should report")
            XCTAssertTrue(diags[0].message.hasPrefix("Button text"), diags[0].message)
        }
    }

    func testGenericLinkText_passesADescriptiveButton() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Learn more about dental coverage") {}
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "generic-link-text").count, 0)
    }

    /// Restoring focus through a helper is normal, and looking only for the assignment inside
    /// the closure reported code that already did the right thing. This was the rule's single
    /// most precisely-evidenced finding on a real app, and it was a false positive.
    func testSheetFocusReturn_followsFocusRestoredInsideAHelper() {
        let source = """
        import SwiftUI
        struct IDCardView: View {
            @State private var shown = false
            @AccessibilityFocusState private var focus: Bool
            var body: some View {
                Text("x").alert("Share", isPresented: $shown) {
                    Button("Cancel", role: .cancel) { restoreAccessibilityFocus() }
                }
            }
            private func restoreAccessibilityFocus() { focus = true }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "sheet-focus-return").count, 0)
    }

    func testSheetFocusReturn_onDismissDelegatingToAHelperAlsoCounts() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State private var shown = false
            @AccessibilityFocusState private var focus: Bool
            var body: some View {
                Button("Open") { shown = true }
                    .sheet(isPresented: $shown, onDismiss: { restoreFocus() }) { Text("Body") }
            }
            private func restoreFocus() { focus = true }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "sheet-focus-return").count, 0)
    }

    /// A helper that does not touch focus must not count as restoring it.
    func testSheetFocusReturn_unrelatedHelperStillReports() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State private var shown = false
            @AccessibilityFocusState private var focus: Bool
            var body: some View {
                Text("x").alert("Title", isPresented: $shown) {
                    Button("Cancel", role: .cancel) { logDismissal() }
                }
            }
            private func logDismissal() { print("dismissed") }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "sheet-focus-return").count, 1)
    }

    // MARK: - Label in name, adjacent label

    /// TLDAS-1204's shape: a visible Text above a field whose accessible name is different.
    func testLabelInName_flagsAdjacentVisibleLabelThatDoesNotMatch() {
        let source = """
        import SwiftUI
        struct Search: View {
            @State private var text = ""
            var body: some View {
                VStack(alignment: .leading) {
                    Text("Searching near")
                    TextField("", text: $text)
                        .accessibilityLabel("Enter address")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("Searching near"), diags[0].message)
    }

    func testLabelInName_adjacentLabelThatMatchesPasses() {
        let source = """
        import SwiftUI
        struct Search: View {
            @State private var text = ""
            var body: some View {
                VStack(alignment: .leading) {
                    Text("Searching near")
                    TextField("", text: $text)
                        .accessibilityLabel("Searching near, enter an address")
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "label-in-name").count, 0)
    }

    /// When the container groups its children the visible label belongs to the group.
    func testLabelInName_groupedContainerIsSkipped() {
        let source = """
        import SwiftUI
        struct Search: View {
            @State private var text = ""
            var body: some View {
                VStack(alignment: .leading) {
                    Text("Searching near")
                    TextField("", text: $text)
                        .accessibilityLabel("Enter address")
                }
                .accessibilityElement(children: .combine)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "label-in-name").count, 0)
    }

    /// Nothing is inferred from an identifier the run could not resolve.
    func testLabelInName_unresolvedStringsAreLeftAlone() {
        let source = """
        import SwiftUI
        struct Search: View {
            @State private var text = ""
            var body: some View {
                VStack(alignment: .leading) {
                    Text(viewModel.header)
                    TextField("", text: $text)
                        .accessibilityLabel(viewModel.fieldName)
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "label-in-name").count, 0)
    }

    /// A Text two siblings away is not this control's label.
    func testLabelInName_onlyTheImmediatelyPrecedingSiblingCounts() {
        let source = """
        import SwiftUI
        struct Search: View {
            @State private var text = ""
            var body: some View {
                VStack(alignment: .leading) {
                    Text("Section heading")
                    Divider()
                    TextField("", text: $text)
                        .accessibilityLabel("Enter address")
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "label-in-name").count, 0)
    }

    // MARK: - Localised strings

    func testStringCatalogIndex_parsesXCStringsAndLegacyStrings() throws {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("a11y-cat-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let xc = """
        {"strings": {
          "learnMore": {"localizations": {"en": {"stringUnit": {"value": "Learn More"}}}},
          "untranslated": {}
        }}
        """
        try xc.write(to: dir.appendingPathComponent("Localizable.xcstrings"), atomically: true, encoding: .utf8)
        try "\"legacy.key\" = \"Read more\";\n// a comment\n"
            .write(to: dir.appendingPathComponent("Localizable.strings"), atomically: true, encoding: .utf8)

        let cat = StringCatalogIndex.catalogue(at: dir.path)
        XCTAssertEqual(cat["learnMore"], "Learn More")
        XCTAssertEqual(cat["legacy.key"], "Read more")
        XCTAssertEqual(cat["untranslated"], "untranslated", "an untranslated key falls back to itself")
    }

    func testLocalizedKeyCollector_mapsConstantsToKeys() {
        let source = """
        private extension Localized {
            static let learnMore = Localized.string(from: "rewards.learnMore")
            static let withArgs = Localized.string("spending.learnMore", args: 0)
            static var computed: String { Localized.string(from: "a.b") }
            static let notLocalised = "plain"
        }
        """
        let keys = StringCatalogIndex.KeyCollector.collect(from: Parser.parse(source: source))
        XCTAssertEqual(keys["learnMore"], "rewards.learnMore")
        XCTAssertEqual(keys["withArgs"], "spending.learnMore")
        XCTAssertEqual(keys["computed"], "a.b")
        XCTAssertNil(keys["notLocalised"])
    }

    /// The whole point: a localised codebase holds no literal text, so without resolution the
    /// wording rules read nothing at all.
    func testGenericLinkText_resolvesALocalisedLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button(Localized.learnMore) {}
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "generic-link-text").count, 0, "no map, nothing to compare")

        let syntax = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: "test.swift", tree: syntax)
        let context = RuleContext(
            filePath: "test.swift", sourceText: source, locationConverter: converter,
            localizedText: ["learnMore": "Learn More"]
        )
        let rule = registry.rules.first { $0.id == "generic-link-text" }!
        let diags = rule.check(syntax: syntax, context: context)
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("Learn More"), diags[0].message)
    }

    func testGenericLinkText_localisedButDescriptiveLabelPasses() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button(Localized.dentalCoverage) {}
            }
        }
        """
        let syntax = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: "test.swift", tree: syntax)
        let context = RuleContext(
            filePath: "test.swift", sourceText: source, locationConverter: converter,
            localizedText: ["dentalCoverage": "Learn more about dental coverage"]
        )
        let rule = registry.rules.first { $0.id == "generic-link-text" }!
        XCTAssertEqual(rule.check(syntax: syntax, context: context).count, 0)
    }

    // MARK: - Items 2-5

    /// The 2 KB source fallback used to stop only at six hardcoded constructors, so a labelled
    /// view of any other type let the scan claim its label for the field. A `ProgressView`
    /// beside a chat input hid a real finding.
    func testTextFieldMissingLabel_labelOnAnUnlistedSiblingViewDoesNotSilenceTheField() {
        let source = """
        import SwiftUI
        struct Composer: View {
            @State private var m = ""
            var body: some View { HStack { field; spinner } }
            private var field: some View { TextField(Localized.p, text: $m, axis: .vertical) }
            private var spinner: some View {
                ProgressView().accessibilityLabel("Sending message")
            }
        }
        enum Localized { static let p = "Write your message" }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 1, "the field is unlabelled; the spinner's label is not its own")
    }

    func testSheetFocusReturn_coversContextMenuAndMenu() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Upload bill")
                    .contextMenu { Button("Dismiss") {} }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "sheet-focus-return").count, 1)
    }

    /// A checkbox list under a section header is written as a ForEach, so source holds one
    /// control and the runtime count is whatever the data says. Without counting generated
    /// groups the rule missed the exact shape it exists for.
    func testButtonGroup_countsAForEachOfControlsAsAGroup() {
        let source = """
        import SwiftUI
        struct RefillSelections: View {
            let items: [String]
            var body: some View {
                VStack {
                    Text("For Self").font(.themeParagraphMStrong)
                    ForEach(items, id: \\.self) { item in
                        Toggle(item, isOn: .constant(false))
                    }
                }
            }
        }
        """
        XCTAssertGreaterThanOrEqual(
            analyze(source, ruleID: "button-group-missing-container-label").count, 1
        )
    }

    func testButtonGroup_coversToggleGroups() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State private var a = false
            @State private var b = false
            var body: some View {
                VStack {
                    Text("For Self")
                    VStack {
                        Toggle("Zetia", isOn: $a)
                        Toggle("Amoxicillin", isOn: $b)
                    }
                }
            }
        }
        """
        XCTAssertGreaterThanOrEqual(analyze(source, ruleID: "button-group-missing-container-label").count, 1)
    }

    // MARK: - View Aliases

    /// A design-system wrapper is invisible to every rule until it is aliased: rules only look
    /// at names in `recognizedViews`. This is the single biggest coverage gap in a codebase that
    /// wraps SwiftUI in its own components.
    func testViewAliases_wrapperIsInvisibleUntilAliased() {
        let source = """
        import SwiftUI
        struct DeniedRow: View {
            var body: some View {
                IconView(name: "exclamationmark.triangle.fill")
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "image-missing-label").count, 0)

        let opts = A11yConfig.ConfigOptions(viewAliases: ["IconView": "Image"])
        let diags = analyze(source, ruleID: "image-missing-label", configOptions: opts)
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(
            diags[0].message.hasPrefix("IconView renders an image"),
            "message should name the wrapper the author wrote: \(diags[0].message)"
        )
    }

    func testViewAliases_buttonWrapperReachesLabelRules() {
        let source = """
        import SwiftUI
        struct SummaryList: View {
            let items: [String]
            var body: some View {
                VStack {
                    ForEach(items, id: \\.self) { _ in
                        NavigationButton(title: "View Summary")
                    }
                }
            }
        }
        """
        let opts = A11yConfig.ConfigOptions(viewAliases: ["NavigationButton": "Button"])
        XCTAssertGreaterThanOrEqual(
            analyze(source, ruleID: "duplicate-button-label", configOptions: opts).count, 1
        )
    }

    // MARK: - tap-gesture-missing-button-trait: equivalent and removed traits

    /// `.isLink` announces an interactive role too, and is the accurate one for a tap that
    /// opens a URL.
    func testTapGestureTrait_acceptsIsLink() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("Costco authorization")
                    .onTapGesture { open() }
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(.isLink)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "tap-gesture-missing-button-trait").count, 0)
    }

    /// Removing the trait is the author saying this is deliberately not a button. Demanding it
    /// back makes the rule unsatisfiable.
    func testTapGestureTrait_honoursExplicitRemoval() {
        let source = """
        import SwiftUI
        struct V: View {
            @AccessibilityFocusState private var focused: Bool
            var body: some View {
                Text("Dependents")
                    .onTapGesture { focused = true }
                    .accessibilityRemoveTraits([.isButton])
                    .accessibilityFocused($focused)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "tap-gesture-missing-button-trait").count, 0)
    }

    /// A non-interactive trait is not a substitute: a combined element announced as a heading
    /// gives no hint it is tappable.
    func testTapGestureTrait_headerTraitAloneStillReports() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack { Text("Dr Smith") }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isHeader)
                    .onTapGesture { showReviews() }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "tap-gesture-missing-button-trait").count, 1)
    }

    // MARK: - Label arguments need not be literals

    /// `Toggle(viewModel.title, isOn:)` is labelled. `firstStringArgument` is nil for a
    /// non-literal, which is not evidence of an absent label.
    func testToggleMissingLabel_acceptsNonLiteralLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            @State private var on = false
            let title: String
            var body: some View {
                Toggle(title, isOn: $on)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "toggle-missing-label").count, 0)
    }

    func testPickerMissingLabel_acceptsNonLiteralLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            @State private var sel = 0
            let title: String
            var body: some View {
                Picker(title, selection: $sel) { Text("a") }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "picker-missing-label").count, 0)
    }

    /// An explicitly empty literal *is* evidence of an absent label.
    func testLabelArguments_emptyLiteralStillReports() {
        let source = """
        import SwiftUI
        struct V: View {
            @State private var on = false
            @State private var sel = 0
            var body: some View {
                VStack {
                    Toggle("", isOn: $on)
                    Picker("", selection: $sel) { Text("a") }
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "toggle-missing-label").count, 1)
        XCTAssertEqual(analyze(source, ruleID: "picker-missing-label").count, 1)
    }

    /// `.labelsHidden()` removes the visible label, so a non-literal one no longer saves it.
    func testToggleMissingLabel_labelsHiddenStillReportsWithNonLiteralLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            @State private var on = false
            let title: String
            var body: some View {
                Toggle(title, isOn: $on).labelsHidden()
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "toggle-missing-label").count, 1)
    }

    /// An interpolated literal has no plain segments but is still a label.
    func testLabelArguments_acceptsInterpolatedLiteral() {
        let source = """
        import SwiftUI
        struct V: View {
            @State private var on = false
            let count: Int
            var body: some View {
                Toggle("Items: \\(count)", isOn: $on)
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "toggle-missing-label").count, 0)
    }

    // MARK: - image-missing-label: Image produced as a value

    /// An `extension Image` builds Image values for callers; the label depends on use.
    func testImageMissingLabel_skipsExtensionImageFactory() {
        let source = """
        import SwiftUI
        extension Image {
            init(illustration: String) { self = Image(illustration) }
            static let sample = Image("sample")
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "image-missing-label").count, 0)
    }

    /// A function returning `Image` is a factory for the same reason.
    func testImageMissingLabel_skipsFunctionReturningImage() {
        let source = """
        import SwiftUI
        struct Helper {
            func image(for name: String) -> Image { Image(name) }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "image-missing-label").count, 0)
    }

    /// `-> some View` is a view being rendered, so it stays reportable. This is the
    /// distinction that keeps the factory exemption narrow.
    func testImageMissingLabel_stillReportsViewReturningFunction() {
        let source = """
        import SwiftUI
        struct Helper: View {
            var body: some View { icon }
            var icon: some View { Image("logo") }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "image-missing-label").count, 1)
    }

    // MARK: - missing-navigation-title: the deprecated titling API

    /// `.navigationBarTitle` is deprecated but still titles the screen, and VoiceOver still
    /// announces it. A screen using it is titled.
    func testMissingNavigationTitle_acceptsDeprecatedNavigationBarTitle() {
        let source = """
        import SwiftUI
        struct LoginAsView: View {
            var body: some View {
                NavigationStack {
                    Text("body")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle(Text("Login As"))
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "missing-navigation-title").count, 0)
    }

    /// `navigationBarTitleDisplayMode` only says *how* a title displays. A screen can carry it
    /// and still have no title, so it must not count — this is the substring trap that makes the
    /// check require an opening paren.
    func testMissingNavigationTitle_displayModeAloneIsNotATitle() {
        let source = """
        import SwiftUI
        struct UntitledView: View {
            var body: some View {
                NavigationStack {
                    Text("body")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "missing-navigation-title").count, 1)
    }

    /// A display-mode modifier earlier in the body must not mask a real title later in it.
    func testMissingNavigationTitle_displayModeBeforeTitleStillCounts() {
        let source = """
        import SwiftUI
        struct Screen: View {
            var body: some View {
                ScrollView {
                    VStack { Text("content") }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle("Claims")
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "missing-navigation-title").count, 0)
    }

    /// A title read off a view model is still a title.
    func testMissingNavigationTitle_acceptsNonLiteralTitle() {
        let source = """
        import SwiftUI
        struct Screen: View {
            let viewModel: ViewModel
            var body: some View {
                NavigationStack {
                    Text("body")
                        .navigationBarTitle(viewModel.navigationTitle)
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "missing-navigation-title").count, 0)
    }

    // MARK: - duplicate-button-label: mutually exclusive branches

    /// `if`/`else` renders one button or the other, never both, so VoiceOver can never
    /// encounter the pair.
    func testDuplicateButtonLabel_ignoresIfElseBranches() {
        let source = """
        import SwiftUI
        struct DebugView: View {
            let token: String?
            var body: some View {
                Group {
                    if token == nil {
                        Button("Load Plan Groups") { }
                    } else {
                        Button("Load Plan Groups") { }
                    }
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "duplicate-button-label").count, 0)
    }

    /// Siblings in the same branch still collide on screen.
    func testDuplicateButtonLabel_flagsDuplicatesWithinOneBranch() {
        let source = """
        import SwiftUI
        struct V: View {
            let on: Bool
            var body: some View {
                Group {
                    if on {
                        HStack {
                            Button("Load") { }
                            Button("Load") { }
                        }
                    } else {
                        Text("off")
                    }
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "duplicate-button-label")
        XCTAssertEqual(diags.count, 2)
        XCTAssertTrue(
            diags[0].message.contains("appears 2 times"),
            "count should be the buttons that can coexist: \(diags[0].message)"
        )
    }

    /// Different `switch` cases are arms of one conditional, same as `if`/`else`.
    func testDuplicateButtonLabel_ignoresSeparateSwitchCases() {
        let source = """
        import SwiftUI
        struct V: View {
            enum State { case a, b }
            let state: State
            var body: some View {
                Group {
                    switch state {
                    case .a: Button("Retry") { }
                    case .b: Button("Retry") { }
                    }
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "duplicate-button-label").count, 0)
    }

    /// `else if` chains: the first and last arms are still mutually exclusive.
    func testDuplicateButtonLabel_ignoresElseIfChain() {
        let source = """
        import SwiftUI
        struct V: View {
            let n: Int
            var body: some View {
                Group {
                    if n == 0 {
                        Button("Go") { }
                    } else if n == 1 {
                        Button("Go") { }
                    } else {
                        Button("Go") { }
                    }
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "duplicate-button-label").count, 0)
    }

    /// Unrelated conditionals are not exclusive — both can be true at once.
    func testDuplicateButtonLabel_flagsAcrossIndependentConditionals() {
        let source = """
        import SwiftUI
        struct V: View {
            let showA: Bool
            let showB: Bool
            var body: some View {
                VStack {
                    if showA { Button("Save") { } }
                    if showB { Button("Save") { } }
                }
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "duplicate-button-label").count, 2)
    }

    /// Three buttons where only two can coexist: the exclusive one is dropped and the count
    /// reported is two, not three.
    func testDuplicateButtonLabel_countsOnlySimultaneousButtons() {
        let source = """
        import SwiftUI
        struct V: View {
            let on: Bool
            var body: some View {
                VStack {
                    Button("Edit") { }
                    Group {
                        if on {
                            Button("Edit") { }
                        } else {
                            Text("off")
                        }
                    }
                    Button("Edit") { }
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "duplicate-button-label")
        XCTAssertEqual(diags.count, 3, "all three can pair with at least one other")
        XCTAssertTrue(
            diags.allSatisfy { $0.message.contains("appears") },
            "every finding should state a count"
        )
    }

    /// A project must not be able to redefine a type the rules already know.
    func testViewAliases_cannotShadowABuiltInViewName() {
        let source = """
        import SwiftUI
        struct V: View { var body: some View { Image(systemName: "star") } }
        """
        let found = ViewHierarchyVisitor.analyze(
            Parser.parse(source: source), viewAliases: ["Image": "Button"]
        )
        XCTAssertEqual(found.views(ofType: "Image").count, 1, "Image must still resolve to Image")
        XCTAssertEqual(found.views(ofType: "Button").count, 0)
    }

    /// The catalogue that defines a token usually lives in a different directory from the call
    /// sites. Indexing as each directory is analysed left the index empty for whichever
    /// directory came first, so the index is built across all paths up front and accumulates.
    func testLabelledTokenIndex_accumulatesAcrossDirectories() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("a11y-xpkg-\(UUID().uuidString)")
        let pkgA = root.appendingPathComponent("PkgA")
        let pkgB = root.appendingPathComponent("PkgB")
        try FileManager.default.createDirectory(at: pkgA, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: pkgB, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        try """
        import SwiftUI
        public enum Icon {
            case errorFill, externalLink
            public var a11yLabel: String? {
                switch self {
                case .errorFill: return "Error"
                default: return nil
                }
            }
        }
        """.write(to: pkgA.appendingPathComponent("Catalog.swift"), atomically: true, encoding: .utf8)

        let reg = RuleRegistry()
        reg.config = A11yConfig(
            severityOverrides: [:], disabledRules: [], enabledOnly: [],
            options: .init(viewAliases: ["IconView": "Image"]), excludePaths: []
        )
        // Index the call-site directory first — the order that used to produce an empty index.
        reg.buildIndexes(at: pkgB.path)
        XCTAssertTrue(reg.labelledTokens.isEmpty)
        reg.buildIndexes(at: pkgA.path)
        XCTAssertEqual(reg.labelledTokens, ["errorFill"], "the second directory must add, not replace")
    }

    /// The real shape from a design system: a label property with a handful of labelled cases
    /// and a `default: nil` covering everything else.
    func testLabelledTokenScanner_collectsOnlyTheLabelledCases() {
        let source = """
        public enum Messaging {
            case errorFill, infoFill, successFill, warningFill, errorOutline, chevron
            public var a11yLabel: String? {
                switch self {
                case .errorFill:
                    return Localized.errorImageText
                case .infoFill:
                    return Localized.informationImageText
                case .successFill, .warningFill:
                    return Localized.statusImageText
                default:
                    return nil
                }
            }
        }
        """
        let tokens = LabelledTokenScanner.scan(Parser.parse(source: source))
        XCTAssertEqual(tokens, ["errorFill", "infoFill", "successFill", "warningFill"])
        XCTAssertFalse(tokens.contains("errorOutline"), "a token falling to default: nil is unlabelled")
        XCTAssertFalse(tokens.contains("chevron"))
    }

    /// An aliased wrapper whose token already carries a label must not be reported — this was
    /// 33 of 218 new findings when aliases first landed.
    func testViewAliases_skipsWrapperWhoseTokenCarriesALabel() {
        let source = """
        import SwiftUI
        struct Row: View {
            var body: some View {
                VStack {
                    IconView(.messaging(.errorFill))
                    IconView(.utilities(.externalLink))
                }
            }
        }
        """
        let opts = A11yConfig.ConfigOptions(viewAliases: ["IconView": "Image"])
        let syntax = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: "test.swift", tree: syntax)
        let context = RuleContext(
            filePath: "test.swift", sourceText: source, locationConverter: converter,
            configOptions: opts, labelledTokens: ["errorFill"]
        )
        let rule = registry.rules.first { $0.id == "image-missing-label" }!
        let diags = rule.check(syntax: syntax, context: context)
        XCTAssertEqual(diags.count, 1, "only the unlabelled token should report")
        XCTAssertEqual(diags[0].line, 6, "the externalLink icon, not the errorFill one")
    }

    /// The same wrapper name may be a UIView elsewhere in the project. Reading UIKit as SwiftUI
    /// produced 16 false positives before this guard.
    func testViewAliases_ignoreAliasedWrappersInNonSwiftUIFiles() {
        let source = """
        import UIKit
        final class IconCell: UITableViewCell {
            func setup() {
                let icon = IconView(renderingType: .template)
                icon.tintColor = .label
            }
        }
        """
        let opts = A11yConfig.ConfigOptions(viewAliases: ["IconView": "Image"])
        XCTAssertEqual(analyze(source, ruleID: "image-missing-label", configOptions: opts).count, 0)
    }

    func testViewAliases_parsesFromYAMLAndDropsUnknownTargets() throws {
        let yaml = """
        options:
          view_aliases:
            IconView: Image
            NavigationButton: Button
            BogusWrapper: NotARealView
        """
        let config = try ConfigLoader.parse(yaml)
        XCTAssertEqual(config.options.viewAliases["IconView"], "Image")
        XCTAssertEqual(config.options.viewAliases["NavigationButton"], "Button")
        XCTAssertNil(config.options.viewAliases["BogusWrapper"], "alias to an unknown type is dropped")
    }

    func testHeadingFontConfig_parsesFromYAML() throws {
        let yaml = """
        options:
          heading_fonts:
            - brandJumbo
          heading_font_deny:
            - themeHeadingInline
        """
        let config = try ConfigLoader.parse(yaml)
        XCTAssertEqual(config.options.headingFonts, ["brandJumbo"])
        XCTAssertEqual(config.options.headingFontDeny, ["themeHeadingInline"])
    }

    func testFakeHeadingInLabel_flagsBadLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Store Hours")
                    .accessibilityLabel("Store Hours heading")
            }
        }
        """
        let diags = analyze(source, ruleID: "fake-heading-in-label")
        XCTAssertEqual(diags.count, 1)
    }

    // MARK: - Button Rules

    func testButtonLabelContainsRole_flagsBadButton() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Edit button") { }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-label-contains-role")
        XCTAssertEqual(diags.count, 1)
    }

    func testIconButtonMissingLabel_flagsBadButton() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button {
                    // action
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "icon-button-missing-label")
        XCTAssertEqual(diags.count, 1)
    }

    func testIconButtonMissingLabel_passesWithLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button {
                    // action
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Edit Username")
            }
        }
        """
        let diags = analyze(source, ruleID: "icon-button-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Sort Priority Negative Rule

    func testSortPriorityNegative_flagsNegativeOne() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Home") { }
                    .accessibilitySortPriority(-1)
            }
        }
        """
        let diags = analyze(source, ruleID: "sort-priority-negative")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("Explore by Touch"))
        XCTAssertEqual(diags[0].severity, .error)
    }

    func testSortPriorityNegative_flagsNegativeLargeValue() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Bar")
                    .accessibilitySortPriority(-10)
            }
        }
        """
        let diags = analyze(source, ruleID: "sort-priority-negative")
        XCTAssertEqual(diags.count, 1)
    }

    func testSortPriorityNegative_passesPositiveValue() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Bar")
                    .accessibilitySortPriority(1)
            }
        }
        """
        let diags = analyze(source, ruleID: "sort-priority-negative")
        XCTAssertEqual(diags.count, 0)
    }

    func testSortPriorityNegative_passesZero() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Bar")
                    .accessibilitySortPriority(0)
            }
        }
        """
        let diags = analyze(source, ruleID: "sort-priority-negative")
        XCTAssertEqual(diags.count, 0)
    }

    func testSortPriorityOverused_suppressedWhenNegative() {
        // Negative values are handled by sort-priority-negative with an error
        // message. sort-priority-overused should not also fire on the same line
        // to avoid duplicate diagnostics.
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Bar")
                    .accessibilitySortPriority(-1)
            }
        }
        """
        let diags = analyze(source, ruleID: "sort-priority-overused")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Accessibility Value Rules

    func testValueContainsRole_flagsTabInValue() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Home") { }
                    .accessibilityValue("Tab 1 of 5")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("'tab'"))
    }

    func testValueContainsRole_flagsButtonInValue() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Toggle("Wi-Fi", isOn: .constant(true))
                    .accessibilityValue("On, button")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("'button'"))
    }

    func testValueContainsRole_flagsLinkInValue() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Terms")
                    .accessibilityValue("External link")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("'link'"))
    }

    func testValueContainsRole_passesStateOnlyValue() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Slider(value: .constant(0.5))
                    .accessibilityValue("50 percent")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 0)
    }

    func testValueContainsRole_passesNoValueModifier() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Home") { }
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 0)
    }

    func testValueContainsRole_flagsCheckboxWithToggleGuidance() {
        // Fake-checkbox pattern is not an exception — the correct approach is
        // Toggle + custom toggleStyle, which supplies the Switch button trait
        // automatically, and the value should be state-only ("Checked"/"Unchecked").
        // Downgraded to a warning because iOS has no checkbox trait — WCAG 4.1.2
        // is satisfied by the Switch trait regardless, so this is best-practice
        // guidance rather than a hard failure.
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Toggle("Terms", isOn: .constant(true))
                    .accessibilityValue("checkbox, checked")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("'checkbox'"))
        XCTAssertTrue(diags[0].message.contains("CheckboxToggleStyle"))
        XCTAssertEqual(diags[0].severity, .warning)
    }

    func testValueContainsRole_flagsOtherRoleWordsAsError() {
        // All non-checkbox role words remain errors — those roles all have
        // native iOS traits, so there is no defensible reason to embed the
        // role word in the value string.
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Home") { }
                    .accessibilityValue("Tab 1 of 5")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags[0].severity, .error)
    }

    func testValueContainsRole_passesCheckedStateOnly() {
        // The recommended fake-checkbox value is state-only.
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Toggle("Terms", isOn: .constant(true))
                    .accessibilityValue("Checked")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 0)
    }

    func testValueContainsRole_wholeWordMatchingSkipsSubstrings() {
        // "linked" contains "link" as a substring but is not the role word.
        // "buttonhole" contains "button" as a substring but is not the role.
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Account")
                    .accessibilityValue("Linked to your buttonhole account")
            }
        }
        """
        let diags = analyze(source, ruleID: "value-contains-role")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Tap Gesture Rules

    func testTapGestureMissingTrait_flagsBad() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "barcode")
                    .onTapGesture { }
            }
        }
        """
        let diags = analyze(source, ruleID: "tap-gesture-missing-button-trait")
        XCTAssertEqual(diags.count, 1)
    }

    func testTapGestureMissingTrait_passesWithTrait() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "barcode")
                    .onTapGesture { }
                    .accessibilityAddTraits(.isButton)
            }
        }
        """
        let diags = analyze(source, ruleID: "tap-gesture-missing-button-trait")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Toggle Rules

    func testToggleMissingLabel_flagsEmptyLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var isOn = false
            var body: some View {
                Toggle("", isOn: $isOn)
            }
        }
        """
        let diags = analyze(source, ruleID: "toggle-missing-label")
        XCTAssertEqual(diags.count, 1)
    }

    func testToggleMissingLabel_passesWithLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var isOn = false
            var body: some View {
                Toggle("Use Face ID", isOn: $isOn)
            }
        }
        """
        let diags = analyze(source, ruleID: "toggle-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Link Rules

    func testGenericLinkText_flagsClickHere() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Link("Click here", destination: URL(string: "https://example.com")!)
            }
        }
        """
        let diags = analyze(source, ruleID: "generic-link-text")
        XCTAssertEqual(diags.count, 1)
    }

    func testGenericLinkText_passesDescriptive() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Link("CVS Health website", destination: URL(string: "https://cvshealth.com")!)
            }
        }
        """
        let diags = analyze(source, ruleID: "generic-link-text")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Dynamic Type Rules

    func testFixedFontSize_flagsBad() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hello")
                    .font(.system(size: 30))
            }
        }
        """
        let diags = analyze(source, ruleID: "fixed-font-size")
        XCTAssertEqual(diags.count, 1)
    }

    func testFixedFontSize_passesDynamicType() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hello")
                    .font(.body)
            }
        }
        """
        let diags = analyze(source, ruleID: "fixed-font-size")
        XCTAssertEqual(diags.count, 0)
    }

    func testLineLimit1_flagsBad() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hello")
                    .lineLimit(1)
            }
        }
        """
        let diags = analyze(source, ruleID: "line-limit-1")
        XCTAssertEqual(diags.count, 1)
    }

    // MARK: - TextField Rules

    func testTextFieldMissingLabel_flagsEmptyLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var text = ""
            var body: some View {
                TextField("", text: $text)
            }
        }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 1)
    }

    func testTextFieldMissingLabel_flagsPlaceholderOnlyAsError() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var text = ""
            var body: some View {
                TextField("First Name", text: $text)
            }
        }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags.first?.severity, .error)
        XCTAssertTrue(diags.first?.message.contains("placeholder text") == true)
    }

    func testTextFieldMissingLabel_flagsPromptWithoutAccessibilityLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var text = ""
            var body: some View {
                TextField("First Name", text: $text, prompt: Text("Enter your first name"))
            }
        }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags.first?.severity, .error)
    }

    func testTextFieldMissingLabel_passesWithPromptAndAccessibilityLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var text = ""
            var body: some View {
                TextField("First Name", text: $text, prompt: Text("Enter your first name"))
                    .accessibilityLabel("First Name")
            }
        }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testTextFieldMissingLabel_passesWithAccessibilityLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var text = ""
            var body: some View {
                TextField("", text: $text)
                    .accessibilityLabel("First Name")
            }
        }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testTextFieldMissingLabel_passesInsideLabeledContent() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var text = ""
            var body: some View {
                LabeledContent("First Name") {
                    TextField("", text: $text)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testSecureFieldMissingLabel_flagsPlaceholderOnly() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var text = ""
            var body: some View {
                SecureField("Password", text: $text)
            }
        }
        """
        let diags = analyze(source, ruleID: "textfield-missing-label")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags.first?.severity, .error)
    }

    // MARK: - Hardcoded Color Rules

    func testHardcodedColor_flagsBlack() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hello")
                    .foregroundColor(.black)
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertEqual(diags.count, 1)
    }

    // MARK: - Picker Style Accessibility Rules

    func testPickerStyleAccessibility_flagsWheelWithoutModifiers() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var selection = "A"
            var body: some View {
                Picker("Choice", selection: $selection) {
                    Text("A").tag("A")
                }
                .pickerStyle(.wheel)
            }
        }
        """
        let diags = analyze(source, ruleID: "picker-style-missing-accessibility")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("missing both"))
    }

    func testPickerStyleAccessibility_flagsSegmentedWithoutModifiers() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var selection = "A"
            var body: some View {
                Picker("Choice", selection: $selection) {
                    Text("A").tag("A")
                }
                .pickerStyle(.segmented)
            }
        }
        """
        let diags = analyze(source, ruleID: "picker-style-missing-accessibility")
        XCTAssertEqual(diags.count, 1)
    }

    func testPickerStyleAccessibility_flagsMissingContain() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var selection = "A"
            var body: some View {
                Picker("Choice", selection: $selection) {
                    Text("A").tag("A")
                }
                .pickerStyle(.wheel)
                .accessibilityLabel("Choice")
            }
        }
        """
        let diags = analyze(source, ruleID: "picker-style-missing-accessibility")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("missing .accessibilityElement"))
    }

    func testPickerStyleAccessibility_flagsMissingLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var selection = "A"
            var body: some View {
                Picker("Choice", selection: $selection) {
                    Text("A").tag("A")
                }
                .pickerStyle(.wheel)
                .accessibilityElement(children: .contain)
            }
        }
        """
        let diags = analyze(source, ruleID: "picker-style-missing-accessibility")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("missing .accessibilityLabel"))
    }

    func testPickerStyleAccessibility_passesWithBothModifiers() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var selection = "A"
            var body: some View {
                Picker("Choice", selection: $selection) {
                    Text("A").tag("A")
                }
                .pickerStyle(.wheel)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Choice")
            }
        }
        """
        let diags = analyze(source, ruleID: "picker-style-missing-accessibility")
        XCTAssertEqual(diags.count, 0)
    }

    func testPickerStyleAccessibility_passesDefaultStyle() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var selection = "A"
            var body: some View {
                Picker("Choice", selection: $selection) {
                    Text("A").tag("A")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "picker-style-missing-accessibility")
        XCTAssertEqual(diags.count, 0)
    }

    func testPickerStyleAccessibility_flagsOldStyleSyntax() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @State var selection = "A"
            var body: some View {
                Picker("Choice", selection: $selection) {
                    Text("A").tag("A")
                }
                .pickerStyle(WheelPickerStyle())
            }
        }
        """
        let diags = analyze(source, ruleID: "picker-style-missing-accessibility")
        XCTAssertEqual(diags.count, 1)
    }

    // MARK: - Button Group Missing Container Label

    func testButtonGroupMissingContainerLabel_flagsBothMissing() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Rate this experience")
                    HStack {
                        Button("Yes") {}
                        Button("No") {}
                    }
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-group-missing-container-label")
        XCTAssertEqual(diags.count, 1)
        XCTAssert(diags[0].message.contains("missing .accessibilityElement(children: .contain) and .accessibilityLabel()"))
    }

    func testButtonGroupMissingContainerLabel_flagsMissingLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Rate this experience")
                    HStack {
                        Button("Yes") {}
                        Button("No") {}
                    }
                    .accessibilityElement(children: .contain)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-group-missing-container-label")
        XCTAssertEqual(diags.count, 1)
        XCTAssert(diags[0].message.contains("missing .accessibilityLabel()"))
    }

    func testButtonGroupMissingContainerLabel_flagsMissingContain() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Rate this experience")
                    HStack {
                        Button("Yes") {}
                        Button("No") {}
                    }
                    .accessibilityLabel("Rate this experience")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-group-missing-container-label")
        XCTAssertEqual(diags.count, 1)
        XCTAssert(diags[0].message.contains("missing .accessibilityElement(children: .contain)"))
    }

    func testButtonGroupMissingContainerLabel_passesBothPresent() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Rate this experience")
                    HStack {
                        Button("Yes") {}
                        Button("No") {}
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Rate this experience")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-group-missing-container-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testButtonGroupMissingContainerLabel_passesNoPrecedingText() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                HStack {
                    Button("Edit") {}
                    Button("Delete") {}
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-group-missing-container-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testButtonGroupMissingContainerLabel_passesSingleButton() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Actions")
                    HStack {
                        Button("Submit") {}
                    }
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-group-missing-container-label")
        XCTAssertEqual(diags.count, 0)
    }

    func testButtonGroupMissingContainerLabel_passesAlreadyHasAccessibilityElement() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Choose one")
                    HStack {
                        Button("A") {}
                        Button("B") {}
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "button-group-missing-container-label")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Registry

    func testRegistryHasAllRules() {
        XCTAssertEqual(registry.rules.count, 45)
    }

    func testDisableRule() {
        registry.disabledRuleIDs = ["image-missing-label"]
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "newspaper")
            }
        }
        """
        let diags = analyze(source, ruleID: "image-missing-label")
        // Rule still runs when called directly — disabling is checked in enabledRules
        XCTAssertEqual(diags.count, 1)

        // But when run through the registry, it should be skipped
        let registryDiags = registry.analyze(sourceText: source, filePath: "test.swift")
        let imageRuleDiags = registryDiags.filter { $0.ruleID == "image-missing-label" }
        XCTAssertEqual(imageRuleDiags.count, 0)
    }

    // MARK: - Fixture Files

    func testFixtureFile_images() throws {
        let fixtureURL = try XCTUnwrap(
            Bundle.module.url(forResource: "ImageFixtures", withExtension: "swift", subdirectory: "Fixtures")
        )
        let source = try String(contentsOf: fixtureURL, encoding: .utf8)
        let diags = registry.analyze(sourceText: source, filePath: fixtureURL.path)

        // Should flag: BadImageNoLabel, BadFileImageNoLabel (image-missing-label)
        // Should flag: BadImageLabelWithRole (image-label-contains-role)
        let missingLabelDiags = diags.filter { $0.ruleID == "image-missing-label" }
        XCTAssertGreaterThanOrEqual(missingLabelDiags.count, 2, "Should flag at least 2 images missing labels")

        let roleInLabelDiags = diags.filter { $0.ruleID == "image-label-contains-role" }
        XCTAssertGreaterThanOrEqual(roleInLabelDiags.count, 1, "Should flag 'Star icon' label")
    }

    func testFixtureFile_headings() throws {
        let fixtureURL = try XCTUnwrap(
            Bundle.module.url(forResource: "HeadingFixtures", withExtension: "swift", subdirectory: "Fixtures")
        )
        let source = try String(contentsOf: fixtureURL, encoding: .utf8)
        let diags = registry.analyze(sourceText: source, filePath: fixtureURL.path)

        let missingTraitDiags = diags.filter { $0.ruleID == "heading-trait-missing" }
        XCTAssertGreaterThanOrEqual(missingTraitDiags.count, 1, "Should flag heading without trait")

        let fakeHeadingDiags = diags.filter { $0.ruleID == "fake-heading-in-label" }
        XCTAssertGreaterThanOrEqual(fakeHeadingDiags.count, 1, "Should flag fake heading label")
    }

    func testFixtureFile_buttons() throws {
        let fixtureURL = try XCTUnwrap(
            Bundle.module.url(forResource: "ButtonFixtures", withExtension: "swift", subdirectory: "Fixtures")
        )
        let source = try String(contentsOf: fixtureURL, encoding: .utf8)
        let diags = registry.analyze(sourceText: source, filePath: fixtureURL.path)

        let roleInLabel = diags.filter { $0.ruleID == "button-label-contains-role" }
        XCTAssertGreaterThanOrEqual(roleInLabel.count, 1, "Should flag 'Edit button'")

        let tapGesture = diags.filter { $0.ruleID == "tap-gesture-missing-button-trait" }
        XCTAssertGreaterThanOrEqual(tapGesture.count, 1, "Should flag onTapGesture without .isButton")
    }

    // MARK: - Xcode Formatter

    func testXcodeFormatter_emitsCorrectFormat() {
        let diag = A11yDiagnostic(
            ruleID: "test-rule",
            severity: .warning,
            message: "Test message",
            filePath: "/path/to/File.swift",
            line: 10,
            column: 5,
            wcagCriteria: ["1.1.1"]
        )
        let formatter = XcodeFormatter()
        let output = formatter.format([diag])
        XCTAssertEqual(output, "/path/to/File.swift:10:5: warning: [test-rule] [moderate] Test message [WCAG 1.1.1]\n")
    }

    func testXcodeFormatter_mapsInfoToNote() {
        let diag = A11yDiagnostic(
            ruleID: "test-rule",
            severity: .info,
            message: "Info message",
            filePath: "/path/File.swift",
            line: 1,
            column: 1
        )
        let formatter = XcodeFormatter()
        let output = formatter.format([diag])
        XCTAssertTrue(output.contains(": note:"))
    }

    // MARK: - Inline Suppression

    func testInlineSuppression_disableSameLine() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "star") // a11y-check:disable image-missing-label
            }
        }
        """
        let diags = analyze(source)
        let imageRuleDiags = diags.filter { $0.ruleID == "image-missing-label" }
        XCTAssertEqual(imageRuleDiags.count, 0)
    }

    func testInlineSuppression_disableNextLine() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                // a11y-check:disable-next-line image-missing-label
                Image(systemName: "star")
            }
        }
        """
        let diags = analyze(source)
        let imageRuleDiags = diags.filter { $0.ruleID == "image-missing-label" }
        XCTAssertEqual(imageRuleDiags.count, 0)
    }

    func testInlineSuppression_disableAllRulesOnLine() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "star") // a11y-check:disable
            }
        }
        """
        let diags = analyze(source)
        let line4Diags = diags.filter { $0.line == 4 }
        XCTAssertEqual(line4Diags.count, 0)
    }

    func testInlineSuppression_doesNotAffectOtherLines() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "star") // a11y-check:disable image-missing-label
                Image(systemName: "heart")
            }
        }
        """
        let diags = analyze(source)
        let imageRuleDiags = diags.filter { $0.ruleID == "image-missing-label" }
        XCTAssertEqual(imageRuleDiags.count, 1, "Second Image should still be flagged")
    }

    // MARK: - Config

    func testConfigParsing_severityOverrides() throws {
        let yaml = """
        severity_overrides:
          image-missing-label: warning
          hardcoded-color: info
        disabled_rules:
          - line-limit-1
        exclude_paths:
          - "*/Generated/*"
        """
        let config = try ConfigLoader.parse(yaml)
        XCTAssertEqual(config.severityOverrides["image-missing-label"], .warning)
        XCTAssertEqual(config.severityOverrides["hardcoded-color"], .info)
        XCTAssertTrue(config.disabledRules.contains("line-limit-1"))
        XCTAssertEqual(config.excludePaths, ["*/Generated/*"])
    }

    func testConfigExcludePaths() throws {
        let yaml = """
        exclude_paths:
          - "*/Generated/*"
          - "*Tests*"
        """
        let config = try ConfigLoader.parse(yaml)
        XCTAssertTrue(config.shouldExclude(relativePath: "Sources/Generated/Auto.swift"))
        XCTAssertTrue(config.shouldExclude(relativePath: "MyTests/Test.swift"))
        XCTAssertFalse(config.shouldExclude(relativePath: "Sources/MyView.swift"))
    }

    func testConfigExcludePaths_explicitFileArguments() throws {
        let yaml = """
        exclude_paths:
          - "**/App/*Example/**"
          - "**/GeneratedMocks.swift"
        """
        let config = try ConfigLoader.parse(yaml)
        let root = "/tmp/checkout/MyApp"
        let example = "Modules/Feature/App/FeatureSwiftUIExample/ContentView.swift"

        XCTAssertTrue(config.shouldExclude(filePath: "./\(example)", relativeTo: root))
        XCTAssertTrue(config.shouldExclude(filePath: "\(root)/\(example)", relativeTo: root))
        XCTAssertTrue(config.shouldExclude(filePath: "\(root)/./\(example)", relativeTo: root))
        XCTAssertTrue(config.shouldExclude(
            filePath: "\(root)/Modules/X/Sources/FooMocks/GeneratedMocks.swift",
            relativeTo: root
        ))
        XCTAssertFalse(config.shouldExclude(
            filePath: "\(root)/Modules/Feature/Sources/UI/CardView.swift",
            relativeTo: root
        ))
    }

    func testConfigSeverityOverrideApplied() throws {
        let yaml = """
        severity_overrides:
          image-missing-label: info
        """
        let config = try ConfigLoader.parse(yaml)
        registry.applyConfig(config)

        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "newspaper")
            }
        }
        """
        let diags = analyze(source)
        let imageDiags = diags.filter { $0.ruleID == "image-missing-label" }
        XCTAssertEqual(imageDiags.first?.severity, .info)
    }

    // MARK: - Color Contrast

    func testContrastCalculator_blackOnWhite() {
        let black = ContrastCalculator.RGBA(r: 0, g: 0, b: 0)
        let white = ContrastCalculator.RGBA(r: 1, g: 1, b: 1)
        let ratio = ContrastCalculator.contrastRatio(black, white)
        XCTAssertEqual(ratio, 21.0, accuracy: 0.1)
    }

    func testContrastCalculator_sameColor() {
        let red = ContrastCalculator.RGBA(r: 1, g: 0, b: 0)
        let ratio = ContrastCalculator.contrastRatio(red, red)
        XCTAssertEqual(ratio, 1.0, accuracy: 0.01)
    }

    func testColorParser_systemColors() {
        let black = ColorParser.parse(".black")
        XCTAssertNotNil(black)
        XCTAssertEqual(black?.r, 0)

        let white = ColorParser.parse(".white")
        XCTAssertNotNil(white)
        XCTAssertEqual(white?.r, 1)
    }

    func testColorParser_rgbLiteral() throws {
        let color = try XCTUnwrap(ColorParser.parse("Color(red: 0.5, green: 0.3, blue: 0.1)"))
        XCTAssertEqual(color.r, 0.5, accuracy: 0.01)
        XCTAssertEqual(color.g, 0.3, accuracy: 0.01)
        XCTAssertEqual(color.b, 0.1, accuracy: 0.01)
    }

    func testColorContrastRule_flagsLowContrast() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hello")
                    .foregroundColor(.white)
                    .background(.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags.first?.message.contains("Contrast ratio") ?? false)
    }

    func testColorContrastRule_passesHighContrast() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hello")
                    .foregroundColor(.black)
                    .background(.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 0)
    }

    func testColorContrastRule_doesNotPairSiblingViewColors() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                ScrollView {
                    Text("Good Example")
                        .foregroundColor(.green)
                    Divider()
                        .background(.green)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        // The Text has no background of its own, so it is compared against the assumed
        // system background. What must never happen is pairing it with the sibling
        // Divider's .background(.green), which would read as green-on-green.
        XCTAssertFalse(
            diags.contains { $0.message.contains("background (.green)") },
            "Should not pair foreground from Text with background from sibling Divider"
        )
    }

    // MARK: - Color Gaps: constants, assumed background, HSB, severity

    func testColorContrastRule_resolvesColorHeldInConstant() {
        let source = """
        import SwiftUI
        struct MyView: View {
            private var faint = Color(red: 0.75, green: 0.75, blue: 0.75)
            var body: some View {
                Text("Hi").foregroundColor(faint).background(Color.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 1, "A colour stored in a property must still be checked")
        XCTAssertTrue(diags[0].message.contains("1.8:1"))
    }

    /// Run the contrast rule with `assume_default_background` turned on, which is opt-in.
    private func contrastWithAssumedBackground(_ source: String) -> [A11yDiagnostic] {
        let syntax = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: "test.swift", tree: syntax)
        let context = RuleContext(
            filePath: "test.swift",
            sourceText: source,
            locationConverter: converter,
            configOptions: A11yConfig.ConfigOptions(assumeDefaultBackground: true)
        )
        return ColorContrastRule().check(syntax: syntax, context: context)
    }

    func testColorContrastRule_assumesSystemBackgroundWhenNoneDeclared() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hi").foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            }
        }
        """
        // Opt-in: the assumption is off by default because it misfires on views whose
        // background comes from a style or an image.
        XCTAssertEqual(analyze(source, ruleID: "color-contrast-insufficient").count, 0)
        let diags = contrastWithAssumedBackground(source)
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("assumed system background"))
    }

    func testColorContrastRule_styleProvidedBackgroundIsNotAssumed() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Save") {}.foregroundColor(.white).buttonStyle(.borderedProminent)
            }
        }
        """
        // .borderedProminent paints a fill this rule cannot read, so the background is
        // unknown rather than absent. Assuming it produced a bogus "1.0:1 white on white".
        XCTAssertEqual(contrastWithAssumedBackground(source).count, 0)
    }

    func testColorContrastRule_plainButtonStyleStillAssumesBackground() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Save") {}.foregroundColor(.white).buttonStyle(.plain)
            }
        }
        """
        // .plain paints nothing, so white text really is on the default background.
        XCTAssertEqual(contrastWithAssumedBackground(source).count, 1)
    }

    func testColorContrastRule_findsBackgroundOnEnclosingNonContainerView() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button(action: {}) {
                    Text("child").foregroundColor(.white)
                }
                .background(Color.blue)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        // The ancestor walk used to consider only VStack-style containers, so a Button's
        // background was invisible to its own label.
        XCTAssertTrue(
            diags.contains { $0.message.contains("background (Color.blue)") },
            "A background on an enclosing Button must be paired with its label's foreground"
        )
        XCTAssertFalse(diags.contains { $0.message.contains("assumed system background") })
    }

    func testColorContrastRule_assumedBackgroundCanBeDisabled() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hi").foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            }
        }
        """
        let syntax = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: "test.swift", tree: syntax)
        let context = RuleContext(
            filePath: "test.swift",
            sourceText: source,
            locationConverter: converter,
            configOptions: A11yConfig.ConfigOptions(assumeDefaultBackground: false)
        )
        let rule = ColorContrastRule()
        XCTAssertEqual(rule.check(syntax: syntax, context: context).count, 0)
    }

    func testColorContrastRule_parsesHSBColors() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Hi")
                    .foregroundColor(Color(hue: 0, saturation: 0, brightness: 0.85))
                    .background(Color(hue: 0, saturation: 0, brightness: 1))
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 1, "HSB colours must resolve for contrast maths")
    }

    func testHardcodedColor_foregroundIsWarningBackgroundIsInfo() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").foregroundColor(.black)
                    Divider().background(.white)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        let fg = diags.first { $0.message.contains(".foregroundColor()") }
        let bg = diags.first { $0.message.contains(".background()") }
        XCTAssertEqual(fg?.severity, .warning, "A fixed text colour is a Dark Mode defect")
        XCTAssertEqual(bg?.severity, .info)
    }

    func testHardcodedColor_flagsAdditionalInlineForms() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").foregroundColor(Color(white: 0.8))
                    Text("b").foregroundColor(Color(hue: 0.5, saturation: 1, brightness: 1))
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertEqual(diags.filter { $0.message.contains("Inline color definition") }.count, 2)
    }

    func testHardcodedColor_skipsSelfContainedForegroundBackgroundPair() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black)
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertEqual(
            diags.count, 0,
            "A chain pinning both colours renders the same in either appearance, so Dark Mode does not apply"
        )
    }

    func testHardcodedColor_pairDetectionResolvesConstants() {
        let source = """
        import SwiftUI
        struct MyView: View {
            private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
            var body: some View {
                Text("3").foregroundColor(.white).background(darkRed)
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertEqual(
            diags.count, 0,
            "A background held in a constant still forms a self-contained pair"
        )
    }

    func testHardcodedColor_systemColourBackgroundPinsThePair() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").foregroundColor(.white).background(Color.blue)
                    Text("b").foregroundColor(.white).background(Color.accentColor)
                    Text("c").foregroundColor(.white).background(Color(.systemRed))
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertEqual(diags.count, 0, "A named accent background makes the pair self-contained")
    }

    func testHardcodedColor_ternaryBackgroundPinsThePair() {
        let source = """
        import SwiftUI
        struct MyView: View {
            @Environment(\\.colorScheme) var colorScheme
            private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
            var body: some View {
                Text("3")
                    .foregroundColor(.white)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertEqual(diags.count, 0, "A colorScheme ternary already handles both appearances")
    }

    func testHardcodedColor_appearanceFollowingBackgroundIsStillFlagged() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").foregroundColor(.black).background(Color(.systemBackground))
                    Text("b").foregroundColor(.black).background(Color.primary)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        // The surface flips with the appearance, so the fixed text colour disappears.
        // This is the bug the rule exists to catch and must never be suppressed.
        XCTAssertEqual(diags.count, 2)
        XCTAssertTrue(diags.allSatisfy { $0.severity == .warning })
    }

    // MARK: - Dynamic Type: custom fonts

    func testFixedFontSize_flagsCustomFontWithoutRelativeTo() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").font(.custom("Helvetica", size: 17))
                    Text("b").font(Font.custom("Helvetica", size: 17))
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "fixed-font-size")
        XCTAssertEqual(diags.count, 2)
        XCTAssertTrue(diags.allSatisfy { $0.message.contains("relativeTo:") })
    }

    func testFixedFontSize_allowsCustomFontWithRelativeTo() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("a").font(.custom("Helvetica", size: 17, relativeTo: .body))
            }
        }
        """
        XCTAssertEqual(analyze(source, ruleID: "fixed-font-size").count, 0)
    }

    func testFixedFontSize_flagsUnscaledUIFontButNotScaledOnes() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").font(Font(UIFont(name: "Helvetica", size: 17)!))
                    Text("b").font(Font(UIFont.systemFont(ofSize: 17)))
                    Text("c").font(Font(UIFont.preferredFont(forTextStyle: .body)))
                    Text("d").font(Font(UIFontMetrics(forTextStyle: .body)
                        .scaledFont(for: UIFont(name: "Helvetica", size: 17)!)))
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "fixed-font-size")
        // preferredFont and UIFontMetrics already scale, so only the first two are defects.
        XCTAssertEqual(diags.count, 2)
        XCTAssertTrue(diags.allSatisfy { $0.message.contains("UIFont") })
    }

    // MARK: - Fixed height clipping text

    func testFixedHeightClipsText_flagsSnugTextBoxes() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").frame(height: 30)
                    Text("b").frame(width: 100, height: 40)
                    Button(action: {}) { Text("c") }.frame(height: 44)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "fixed-height-clips-text")
        XCTAssertEqual(diags.count, 3)
        XCTAssertTrue(diags.allSatisfy { $0.message.contains("minHeight") })
    }

    func testFixedHeightClipsText_exemptions() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("minHeight grows").frame(minHeight: 30)
                    Text("maxHeight").frame(maxHeight: 30)
                    Text("generous").frame(height: 120)
                    Text("shrinks").frame(height: 30).minimumScaleFactor(0.6)
                    Text("width only").frame(width: 30)
                    Text("chrome badge").frame(width: 16, height: 16)
                    Image(systemName: "star").frame(height: 30)
                    Rectangle().frame(height: 4)
                    Button(action: {}) { Rectangle() }.frame(height: 40)
                    Button("⬅️") {}.frame(height: 40)
                }
            }
        }
        """
        // Each of these either grows, shrinks to fit, is too small to be a text box, or
        // renders no text at all.
        XCTAssertEqual(analyze(source, ruleID: "fixed-height-clips-text").count, 0)
    }

    func testHardcodedColor_nonColourBackdropPinsTheForeground() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("a").foregroundColor(.white)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                    Text("b").foregroundColor(.white).background(.ultraThinMaterial)
                    Button("c") {}.foregroundColor(.white).buttonStyle(.borderedProminent)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        // The backdrop was chosen deliberately, so "may not adapt to Dark Mode" is the wrong
        // complaint even though none of these backdrops is a colour this rule can read.
        XCTAssertEqual(diags.count, 0)
    }

    func testHardcodedColor_backdropOnEnclosingViewPinsTheForeground() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button(action: {}) {
                    Text("child").foregroundColor(.black)
                }
                .background(Color.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertFalse(
            diags.contains { $0.message.contains(".foregroundColor()") },
            "A backdrop on an enclosing view pins the child's foreground"
        )
    }

    func testHardcodedColor_appearanceFollowingBackdropOnAncestorStillFlags() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("child").foregroundColor(.black)
                }
                .background(Color(.systemBackground))
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        // The surface flips to black in Dark Mode, so the fixed text colour disappears.
        XCTAssertTrue(diags.contains { $0.message.contains(".foregroundColor()") })
    }

    func testHardcodedColor_stillFlagsLoneFixedColors() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("lone").foregroundColor(.black)
                    Divider().background(.white)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "hardcoded-color")
        XCTAssertEqual(diags.count, 2, "Unpaired fixed colours must still be reported")
    }

    func testColorParser_hsbToRGBMatchesKnownValues() {
        // Pure red at full saturation and brightness.
        let red = ColorParser.hsbToRGBA(hue: 0, saturation: 1, brightness: 1, alpha: 1)
        XCTAssertEqual(red.r, 1, accuracy: 0.001)
        XCTAssertEqual(red.g, 0, accuracy: 0.001)
        XCTAssertEqual(red.b, 0, accuracy: 0.001)
        // Zero saturation is a grey of the given brightness.
        let grey = ColorParser.hsbToRGBA(hue: 0.3, saturation: 0, brightness: 0.5, alpha: 1)
        XCTAssertEqual(grey.r, 0.5, accuracy: 0.001)
        XCTAssertEqual(grey.g, 0.5, accuracy: 0.001)
        XCTAssertEqual(grey.b, 0.5, accuracy: 0.001)
    }

    func testColorContrastRule_pairsTextWithAncestorContainerBackground() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Hello")
                        .foregroundColor(.white)
                }
                .background(.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 1, "Text foreground should be paired with the enclosing VStack background")
        XCTAssertTrue(diags.first?.message.contains("inherited from enclosing container") ?? false)
    }

    func testColorContrastRule_largeNumericFontUsesLowerThreshold() {
        // .font(.system(size: 18)) → large text → 3.0:1 threshold
        // gray-on-white is ~3.95:1, which fails 4.5:1 but passes 3.0:1
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Big")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .background(.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 0, ".font(.system(size: 18)) should be treated as large text (3.0:1 threshold)")
    }

    func testColorContrastRule_boldNumericFontUsesLowerThreshold() {
        // .font(.system(size: 14, weight: .bold)) → large text per WCAG 1.4.3
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Bold")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .background(.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 0, ".font(.system(size: 14, weight: .bold)) should be treated as large text (3.0:1 threshold)")
    }

    func testColorContrastRule_smallNumericFontUsesNormalThreshold() {
        // .font(.system(size: 16)) → normal text → 4.5:1 threshold; gray-on-white ~3.95:1 → fail
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Small")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .background(.white)
            }
        }
        """
        let diags = analyze(source, ruleID: "color-contrast-insufficient")
        XCTAssertEqual(diags.count, 1, ".font(.system(size: 16)) should use the 4.5:1 normal-text threshold")
    }

    func testAssetCatalogParser_parsesThemedVariants() {
        let themedColor = AssetCatalogParser.ThemedColor(
            light: ContrastCalculator.RGBA(r: 1, g: 1, b: 1),
            dark: ContrastCalculator.RGBA(r: 0, g: 0, b: 0),
            highContrast: nil,
            darkHighContrast: nil
        )
        XCTAssertEqual(themedColor.resolve(darkMode: false, contrastMode: false).r, 1.0)
        XCTAssertEqual(themedColor.resolve(darkMode: true, contrastMode: false).r, 0.0)
        XCTAssertTrue(themedColor.hasDarkVariant)
        XCTAssertFalse(themedColor.hasHighContrastVariant)
    }

    // MARK: - Diff Filter

    func testDiffFilterParsesUnifiedDiff() {
        let diff = """
        diff --git a/Sources/MyView.swift b/Sources/MyView.swift
        --- a/Sources/MyView.swift
        +++ b/Sources/MyView.swift
        @@ -10,0 +11,3 @@ struct MyView {
        +    func newMethod() {
        +        print("hello")
        +    }
        """
        let result = DiffFilter.parseUnifiedDiff(diff, workingDirectory: "/project")
        let lines = result["/project/Sources/MyView.swift"]
        XCTAssertNotNil(lines)
        XCTAssertEqual(lines, [11, 12, 13])
    }

    func testDiffFilterRemovesUnchangedLines() {
        let diag1 = A11yDiagnostic(ruleID: "test", severity: .error, message: "msg", filePath: "/project/File.swift", line: 5, column: 1)
        let diag2 = A11yDiagnostic(ruleID: "test", severity: .error, message: "msg", filePath: "/project/File.swift", line: 10, column: 1)
        let changedLines: DiffFilter.ChangedLineMap = ["/project/File.swift": [10]]
        let filtered = DiffFilter.filter([diag1, diag2], changedLines: changedLines)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.line, 10)
    }

    // MARK: - HTML Formatter

    func testHTMLFormatterProducesValidHTML() {
        let diag = A11yDiagnostic(
            ruleID: "test-rule",
            severity: .error,
            message: "Test <message>",
            filePath: "/path/to/File.swift",
            line: 10,
            column: 5,
            wcagCriteria: ["1.1.1"]
        )
        let formatter = HTMLFormatter()
        let output = formatter.format([diag], allRules: registry.rules)
        XCTAssertTrue(output.contains("<!DOCTYPE html>"))
        XCTAssertTrue(output.contains("WCAG 2.2 Conformance"))
        XCTAssertTrue(output.contains("Test &lt;message&gt;"))
        XCTAssertTrue(output.contains("Errors</div>"))
    }

    /// The bar chart used to keep its own partial list of criterion names, so a
    /// criterion it omitted was labelled with its number twice ("2.2.2 2.2.2").
    /// Every criterion a rule can cite must come out of the scoring catalogue named.
    func testBarChartLabelsEveryCriterionWithItsName() {
        let cited = Set(registry.rules.flatMap(\.wcagCriteria))
        XCTAssertFalse(cited.isEmpty)

        let catalogued = Dictionary(
            uniqueKeysWithValues: ScoreCalculator.wcagCatalog.map { ($0.criterion, $0.name) }
        )

        for criterion in cited.sorted() {
            guard let name = catalogued[criterion] else {
                XCTFail("A rule cites WCAG \(criterion) but ScoreCalculator.wcagCatalog does not list it")
                continue
            }

            let diag = A11yDiagnostic(
                ruleID: "test-rule",
                severity: .error,
                message: "m",
                filePath: "/path/to/File.swift",
                line: 1,
                column: 1,
                wcagCriteria: [criterion]
            )
            let output = HTMLFormatter().format([diag], allRules: registry.rules)
            XCTAssertTrue(
                output.contains("\(criterion) \(escapeHTMLForTest(name))"),
                "Chart label for \(criterion) should read its name, not the number again"
            )
            XCTAssertFalse(
                output.contains("\(criterion) \(criterion)"),
                "Chart label for \(criterion) repeated the number instead of naming it"
            )
        }
    }

    private func escapeHTMLForTest(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    // MARK: - Fixture Files

    func testFixtureFile_misc() throws {
        let fixtureURL = try XCTUnwrap(
            Bundle.module.url(forResource: "MiscFixtures", withExtension: "swift", subdirectory: "Fixtures")
        )
        let source = try String(contentsOf: fixtureURL, encoding: .utf8)
        let diags = registry.analyze(sourceText: source, filePath: fixtureURL.path)

        // Check various rules fire on their respective bad examples
        XCTAssertTrue(diags.contains { $0.ruleID == "toggle-missing-label" }, "Should flag empty toggle label")
        XCTAssertTrue(diags.contains { $0.ruleID == "generic-link-text" }, "Should flag 'Click here'")
        XCTAssertTrue(diags.contains { $0.ruleID == "fixed-font-size" }, "Should flag .system(size:)")
        XCTAssertTrue(diags.contains { $0.ruleID == "line-limit-1" }, "Should flag .lineLimit(1)")
        XCTAssertTrue(diags.contains { $0.ruleID == "textfield-missing-label" }, "Should flag empty TextField")
    }

    // MARK: - Score Calculator

    func testScoreCalculator_perfectScore() {
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: [],
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        XCTAssertEqual(score.score, 100.0)
        XCTAssertEqual(score.grade, "A+")
        XCTAssertEqual(score.totalErrors, 0)
        XCTAssertEqual(score.totalWarnings, 0)
        XCTAssertEqual(score.criteriaFailed, 0)
    }

    func testScoreCalculator_errorsReduceScore() {
        let diags = [
            A11yDiagnostic(ruleID: "image-missing-label", severity: .error, message: "msg",
                           filePath: "test.swift", line: 1, column: 1, wcagCriteria: ["1.1.1"]),
            A11yDiagnostic(ruleID: "icon-button-missing-label", severity: .error, message: "msg",
                           filePath: "test.swift", line: 5, column: 1, wcagCriteria: ["4.1.2"]),
        ]
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: diags,
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        XCTAssertLessThan(score.score, 100.0, "Errors should reduce score below 100")
        XCTAssertEqual(score.totalErrors, 2)
        XCTAssertGreaterThan(score.criteriaFailed, 0)
    }

    func testScoreCalculator_warningsCountAsReview() {
        let diags = [
            A11yDiagnostic(ruleID: "heading-trait-missing", severity: .warning, message: "msg",
                           filePath: "test.swift", line: 1, column: 1, wcagCriteria: ["1.3.1"]),
        ]
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: diags,
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        // Warnings result in "review" status, not "fail"
        let criterion131 = score.criteriaScores.first { $0.criterion == "1.3.1" }
        XCTAssertEqual(criterion131?.status, .review)
        XCTAssertEqual(score.criteriaFailed, 0)
    }

    func testScoreCalculator_perFileScores() {
        let diags = [
            A11yDiagnostic(ruleID: "image-missing-label", severity: .error, message: "msg",
                           filePath: "bad.swift", line: 1, column: 1, wcagCriteria: ["1.1.1"]),
        ]
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: diags,
            rules: registry.enabledRules,
            filePaths: ["bad.swift", "good.swift"]
        )
        XCTAssertEqual(score.fileScores.count, 2)
        let badFile = score.fileScores.first { $0.filePath == "bad.swift" }
        let goodFile = score.fileScores.first { $0.filePath == "good.swift" }
        XCTAssertLessThan(badFile!.score, goodFile!.score)
        XCTAssertEqual(goodFile!.score, 100.0)
    }

    func testScoreCalculator_principleScores() {
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: [],
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        // With no issues, all principle scores should be 100
        for (_, pScore) in score.principleScores {
            XCTAssertEqual(pScore, 100.0)
        }
    }

    func testScoreCalculator_criterionCreditBounds() {
        XCTAssertEqual(ScoreCalculator.criterionCredit(status: .pass, warnings: 0), 1.0)
        XCTAssertEqual(ScoreCalculator.criterionCredit(status: .fail, warnings: 0), 0.0)
        XCTAssertEqual(ScoreCalculator.criterionCredit(status: .review, warnings: 0), 1.0)

        let few = ScoreCalculator.criterionCredit(status: .review, warnings: 10)
        let many = ScoreCalculator.criterionCredit(status: .review, warnings: 5000)
        XCTAssertGreaterThan(few, many, "More warnings must cost more credit")
        XCTAssertGreaterThanOrEqual(many, 0.5, "A reviewed criterion never drops below half credit")
        XCTAssertLessThanOrEqual(few, 1.0)
    }

    func testScoreCalculator_warningVolumeCannotFloorPrinciple() {
        // A large pile of warnings on one criterion must not zero its principle.
        let diags = (0..<5000).map { i in
            A11yDiagnostic(ruleID: "heading-trait-missing", severity: .warning, message: "msg",
                           filePath: "test.swift", line: i + 1, column: 1, wcagCriteria: ["1.3.1"])
        }
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: diags,
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        let perceivable = score.principleScores[.perceivable]
        XCTAssertNotNil(perceivable)
        XCTAssertGreaterThan(perceivable!, 0.0,
                             "Warnings alone must not zero a principle, was \(perceivable!)")
    }

    func testScoreCalculator_uncoveredPrinciplesAreAbsentNotPerfect() {
        // A rule set covering only 1.1.1 leaves the other three principles uncovered.
        let rule = ImageMissingLabelRule()
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: [],
            rules: [rule],
            filePaths: ["test.swift"]
        )
        let covered = Set(rule.wcagCriteria.map { WCAGPrinciple.from(criterion: $0) })
        XCTAssertEqual(Set(score.principleScores.keys), covered,
                       "Only principles with a checked criterion should have an entry")
        for principle in WCAGPrinciple.allCases where !covered.contains(principle) {
            XCTAssertNil(score.principleScores[principle],
                         "\(principle) has no rule coverage and must not score 100")
        }
    }

    func testScoreCalculator_criteriaNotChecked() {
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: [],
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        // Many WCAG criteria have no rules, so criteriaNotChecked should be > 0
        XCTAssertGreaterThan(score.criteriaNotChecked, 0)
        // Checked criteria = passed + failed
        let totalInCatalog = ScoreCalculator.wcagCatalog.count
        XCTAssertEqual(score.criteriaPassed + score.criteriaFailed + score.criteriaNotChecked, totalInCatalog)
    }

    func testLetterGrade_boundaries() {
        XCTAssertEqual(A11yScore.letterGrade(for: 100), "A+")
        XCTAssertEqual(A11yScore.letterGrade(for: 97), "A+")
        XCTAssertEqual(A11yScore.letterGrade(for: 95), "A")
        XCTAssertEqual(A11yScore.letterGrade(for: 91), "A-")
        XCTAssertEqual(A11yScore.letterGrade(for: 85), "B")
        XCTAssertEqual(A11yScore.letterGrade(for: 75), "C")
        XCTAssertEqual(A11yScore.letterGrade(for: 65), "D")
        XCTAssertEqual(A11yScore.letterGrade(for: 50), "F")
        XCTAssertEqual(A11yScore.letterGrade(for: 0), "F")
    }

    func testFileScore_computation() {
        // 0 issues = 100
        XCTAssertEqual(ScoreCalculator.computeFileScore(errors: 0, warnings: 0, info: 0), 100.0)
        // 1 error = 95 (100 - 5)
        XCTAssertEqual(ScoreCalculator.computeFileScore(errors: 1, warnings: 0, info: 0), 95.0)
        // 1 warning = 98 (100 - 2)
        XCTAssertEqual(ScoreCalculator.computeFileScore(errors: 0, warnings: 1, info: 0), 98.0)
        // Clamped to 0
        XCTAssertEqual(ScoreCalculator.computeFileScore(errors: 100, warnings: 0, info: 0), 0.0)
    }

    func testWCAGPrinciple_mapping() {
        XCTAssertEqual(WCAGPrinciple.from(criterion: "1.1.1"), .perceivable)
        XCTAssertEqual(WCAGPrinciple.from(criterion: "2.4.3"), .operable)
        XCTAssertEqual(WCAGPrinciple.from(criterion: "3.1.1"), .understandable)
        XCTAssertEqual(WCAGPrinciple.from(criterion: "4.1.2"), .robust)
    }

    func testScoreCalculator_integrationWithRegistry() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Image(systemName: "newspaper")
            }
        }
        """
        let diags = registry.analyze(sourceText: source, filePath: "test.swift")
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: diags,
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        XCTAssertLessThan(score.score, 100.0, "File with issues should score below 100")
        XCTAssertGreaterThan(score.score, 0.0, "Score should still be positive")
        XCTAssertFalse(score.grade.isEmpty)
    }

    func testScoreJSONFormatter_producesValidJSON() throws {
        let calculator = ScoreCalculator()
        let score = calculator.calculate(
            diagnostics: [],
            rules: registry.enabledRules,
            filePaths: ["test.swift"]
        )
        let formatter = ScoreJSONFormatter()
        let output = try formatter.format(score)
        let data = output.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["score"] as? Double, 100.0)
        XCTAssertEqual(json["grade"] as? String, "A+")
        XCTAssertNotNil(json["criteria"])
        XCTAssertNotNil(json["principleScores"])
        XCTAssertNotNil(json["fileScores"])
    }

    // MARK: - Label in Name Rule

    func testLabelInName_flagsMismatchedButton() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Save") { }.accessibilityLabel("Submit form")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags[0].severity, .error)
    }

    func testLabelInName_flagsMismatchedText() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Text("Visible").accessibilityLabel("Something else")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags[0].severity, .error)
    }

    func testLabelInName_flagsMismatchedLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Label("Edit", systemImage: "pencil").accessibilityLabel("Modify item")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 1)
        XCTAssertEqual(diags[0].severity, .error)
    }

    func testLabelInName_flagsSuffixOnly() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Save").accessibilityLabel("Quick Save")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 1)
        // Visible text present but not at the start is an error, not a warning:
        // Voice Control prefix-matches against what the user sees.
        XCTAssertEqual(diags[0].severity, .error)
    }

    func testLabelInName_passesExactMatch() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Save").accessibilityLabel("Save")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 0)
    }

    func testLabelInName_passesStartsWith() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Save").accessibilityLabel("Save document")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 0)
    }

    func testLabelInName_passesCaseInsensitive() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("SAVE").accessibilityLabel("save document")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 0)
    }

    func testLabelInName_passesNoAccessibilityLabel() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button("Save") { }
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 0)
    }

    func testLabelInName_passesNoVisibleText() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                Button { Image(systemName: "pencil") }.accessibilityLabel("Edit")
            }
        }
        """
        let diags = analyze(source, ruleID: "label-in-name")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Sort Priority Overused

    func testSortPriorityOverused_flagsUsage() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("First")
                        .accessibilitySortPriority(2)
                    Text("Second")
                        .accessibilitySortPriority(1)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "sort-priority-overused")
        XCTAssertEqual(diags.count, 2)
        XCTAssertEqual(diags.first?.severity, .warning)
    }

    func testSortPriorityOverused_passesWithoutModifier() {
        let source = """
        import SwiftUI
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("First")
                    Text("Second")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "sort-priority-overused")
        XCTAssertEqual(diags.count, 0)
    }

    func testMissingNavTitle_flagsScreenWithScrollView() {
        let source = """
        import SwiftUI
        struct PageBad: View {
            var body: some View {
                ScrollView {
                    Text("No title")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "missing-navigation-title")
        XCTAssertEqual(diags.count, 1, "Expected 1 diagnostic, got \(diags.count)")
    }

    // MARK: - Draggable Missing Accessibility Action (WCAG 2.5.7)

    func testDraggable_flagsMissingAction() {
        let source = """
        import SwiftUI
        struct ReorderList: View {
            var body: some View {
                ForEach(items) { item in
                    Text(item.name)
                        .draggable(item)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "draggable-missing-accessibility-action")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("accessibilityAction"))
        XCTAssertEqual(diags[0].severity, .warning)
    }

    func testDraggable_passesWithAccessibilityAction() {
        let source = """
        import SwiftUI
        struct ReorderList: View {
            var body: some View {
                ForEach(items) { item in
                    Text(item.name)
                        .draggable(item)
                        .accessibilityAction(named: "Move Up") { moveUp(item) }
                        .accessibilityAction(named: "Move Down") { moveDown(item) }
                        .accessibilityHint("Reorderable. Use actions to move.")
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "draggable-missing-accessibility-action")
        XCTAssertEqual(diags.count, 0)
    }

    func testDropDestination_flagsMissingAction() {
        let source = """
        import SwiftUI
        struct DropZone: View {
            var body: some View {
                Rectangle()
                    .dropDestination(for: String.self) { items, _ in true }
            }
        }
        """
        let diags = analyze(source, ruleID: "draggable-missing-accessibility-action")
        XCTAssertEqual(diags.count, 1)
    }

    // MARK: - Motion Actuation Missing Alternative (WCAG 2.5.4)

    func testMotion_flagsCMMotionManager() {
        let source = """
        import CoreMotion
        import SwiftUI
        struct ShakeView: View {
            let manager = CMMotionManager()
            var body: some View { Text("Shake to undo") }
        }
        """
        let diags = analyze(source, ruleID: "motion-actuation-missing-alternative")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("CMMotionManager"))
        XCTAssertEqual(diags[0].severity, .warning)
    }

    func testMotion_flagsStartDeviceMotionUpdates() {
        let source = """
        import CoreMotion
        class MotionService {
            let motionManager = CMMotionManager()
            func start() {
                motionManager.startDeviceMotionUpdates(to: .main) { _, _ in
                    self.handleShake()
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "motion-actuation-missing-alternative")
        XCTAssertFalse(diags.isEmpty)
        XCTAssertEqual(diags[0].severity, .warning)
    }

    func testMotion_noFalsePositiveWithoutMotion() {
        let source = """
        import SwiftUI
        struct StaticView: View {
            var body: some View { Text("Hello") }
        }
        """
        let diags = analyze(source, ruleID: "motion-actuation-missing-alternative")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Input Triggers Context Change (WCAG 3.2.2)

    func testContextChange_flagsPickerWithDismiss() {
        let source = """
        import SwiftUI
        struct FilterSheet: View {
            @Environment(\\.dismiss) var dismiss
            @State var filter = "All"
            var body: some View {
                Picker("Filter", selection: $filter) {
                    Text("All").tag("All")
                    Text("Recent").tag("Recent")
                }
                .onChange(of: filter) { _ in
                    dismiss()
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "input-triggers-context-change")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("Picker"))
        XCTAssertTrue(diags[0].message.contains("dismiss()"))
        XCTAssertEqual(diags[0].severity, .warning)
    }

    func testContextChange_flagsToggleWithDismiss() {
        let source = """
        import SwiftUI
        struct SettingsView: View {
            @Environment(\\.dismiss) var dismiss
            @State var enabled = false
            var body: some View {
                Toggle("Enable", isOn: $enabled)
                    .onChange(of: enabled) { _ in dismiss() }
            }
        }
        """
        let diags = analyze(source, ruleID: "input-triggers-context-change")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("Toggle"))
    }

    func testContextChange_passesPickerWithConfirmButton() {
        let source = """
        import SwiftUI
        struct FilterView: View {
            @Environment(\\.dismiss) var dismiss
            @State var filter = "All"
            var body: some View {
                Picker("Filter", selection: $filter) {
                    Text("All").tag("All")
                }
                .onChange(of: filter) { _ in
                    updateResults()
                }
                Button("Done") { dismiss() }
            }
        }
        """
        let diags = analyze(source, ruleID: "input-triggers-context-change")
        XCTAssertEqual(diags.count, 0)
    }

    func testContextChange_passesPickerWithNonNavigatingOnChange() {
        let source = """
        import SwiftUI
        struct SortView: View {
            @State var sort = "Name"
            var body: some View {
                Picker("Sort", selection: $sort) {
                    Text("Name").tag("Name")
                    Text("Date").tag("Date")
                }
                .onChange(of: sort) { newValue in
                    applySorting(newValue)
                }
            }
        }
        """
        let diags = analyze(source, ruleID: "input-triggers-context-change")
        XCTAssertEqual(diags.count, 0)
    }

    // MARK: - Video Auto-play Rules

    func testVideoAutoplay_flagsOnAppearPlay() {
        let source = """
        import SwiftUI
        import AVKit
        struct VideoView: View {
            let player = AVPlayer(url: URL(string: "https://example.com/video.mp4")!)
            var body: some View {
                VideoPlayer(player: player)
                    .onAppear { player.play() }
            }
        }
        """
        let diags = analyze(source, ruleID: "video-audio-autoplay")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("onAppear"))
        XCTAssertTrue(diags[0].message.contains("WCAG 1.4.2"))
    }

    func testVideoAutoplay_flagsTaskPlay() {
        let source = """
        import SwiftUI
        import AVFoundation
        struct AudioView: View {
            let player = AVPlayer(url: URL(string: "https://example.com/audio.mp3")!)
            var body: some View {
                Text("Now Playing")
                    .task { player.play() }
            }
        }
        """
        let diags = analyze(source, ruleID: "video-audio-autoplay")
        XCTAssertEqual(diags.count, 1)
        XCTAssertTrue(diags[0].message.contains("task"))
    }

    func testVideoAutoplay_passesButtonTriggeredPlay() {
        let source = """
        import SwiftUI
        import AVKit
        struct VideoView: View {
            let player = AVPlayer(url: URL(string: "https://example.com/video.mp4")!)
            @State private var isPlaying = false
            var body: some View {
                VideoPlayer(player: player)
                    .accessibilityElement(children: .contain)
                Button(isPlaying ? "Pause" : "Play") {
                    isPlaying ? player.pause() : player.play()
                    isPlaying.toggle()
                }
                .accessibilityLabel(isPlaying ? "Pause" : "Play")
            }
        }
        """
        let diags = analyze(source, ruleID: "video-audio-autoplay")
        XCTAssertEqual(diags.count, 0)
    }

    func testVideoAutoplay_passesOnDisappearPause() {
        let source = """
        import SwiftUI
        import AVKit
        struct VideoView: View {
            let player = AVPlayer(url: URL(string: "https://example.com/video.mp4")!)
            var body: some View {
                VideoPlayer(player: player)
                    .onDisappear { player.pause() }
            }
        }
        """
        let diags = analyze(source, ruleID: "video-audio-autoplay")
        XCTAssertEqual(diags.count, 0)
    }
}
