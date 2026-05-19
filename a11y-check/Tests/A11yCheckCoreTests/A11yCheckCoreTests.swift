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
    private func analyze(_ source: String, ruleID: String) -> [A11yDiagnostic] {
        let syntax = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: "test.swift", tree: syntax)
        let context = RuleContext(filePath: "test.swift", sourceText: source, locationConverter: converter)
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

    // MARK: - Registry

    func testRegistryHasAllRules() {
        XCTAssertEqual(registry.rules.count, 35)
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
        XCTAssertEqual(diags.count, 0, "Should not pair foreground from Text with background from sibling Divider")
    }

    func testColorContrastRule_skipsContainerViews() {
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
        XCTAssertEqual(diags.count, 0, "VStack is a container; its children's colors should not be paired with its own background")
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
        XCTAssertEqual(diags[0].severity, .warning)
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
}
