import XCTest
import SwiftParser
import SwiftSyntax
@testable import A11yAgentCore

final class A11yAgentCoreTests: XCTestCase {

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

    func testTextFieldMissingLabel_passesWithLabel() {
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
        XCTAssertEqual(diags.count, 0)
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

    // MARK: - Registry

    func testRegistryHasAllRules() {
        XCTAssertEqual(registry.rules.count, 21)
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
}
