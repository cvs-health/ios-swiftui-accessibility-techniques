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

/// Reference example for driving VoiceOver from a UI test with `XCUIVoiceOverService`.
/// See Documentation/VoiceOverAutomationTesting.md.
///
/// Every guard below exists because its absence produces a test that **passes while
/// measuring nothing**, which is the failure mode that makes this API easy to misuse.
@available(iOS 27.0, *)
final class VoiceOverAutomationExampleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    /// Walks to the top of the screen.
    ///
    /// The VoiceOver cursor persists across app launches and test runs and there is no
    /// API to focus the first element — movement is relative only. Without this, a run
    /// that inherits a cursor parked on a tab bar walks straight off the end and reports
    /// almost nothing.
    ///
    /// `moveBackward()` **throws** at the top of the screen, where `moveForward()`
    /// saturates silently at the bottom, so this needs `try?` rather than
    /// repeat-detection alone.
    @MainActor
    private func rewindToTop(_ vo: XCUIVoiceOverService) {
        var previous = ""
        for _ in 1...150 {
            guard let utterance = try? vo.moveBackward().utterance else { return }
            if utterance == previous { return }
            previous = utterance
        }
    }

    /// Collects the utterance for every element from the cursor to the end of the screen.
    ///
    /// The break on a repeated utterance is required: `moveForward()` does not throw at
    /// the last element, it returns the same utterance forever.
    @MainActor
    private func readToEndOfScreen(_ vo: XCUIVoiceOverService, limit: Int = 80) throws -> [String] {
        var utterances: [String] = []
        var previous = ""
        for _ in 1...limit {
            let utterance = try vo.moveForward().utterance
            if utterance == previous { break }
            utterances.append(utterance)
            previous = utterance
        }
        return utterances
    }

    @MainActor
    private func openTechnique(_ name: String, in app: XCUIApplication) {
        app.searchFields["Search"].tap()
        app.typeText(name)
        app.otherElements.buttons[name].tap()
        XCTAssertTrue(app.staticTexts.firstMatch.waitForExistence(timeout: 15))
    }

    // MARK: - Reading order

    /// The sequence of utterances *is* the VoiceOver reading order, which static
    /// analysis cannot determine.
    @MainActor
    func testHeadingsPageReadingOrder() throws {
        let app = XCUIApplication()
        app.launch()
        openTechnique("Headings", in: app)

        let vo = XCUIDevice.shared.voiceOverService
        try vo.enable()
        defer { try? vo.disable() }

        rewindToTop(vo)
        let utterances = try readToEndOfScreen(vo)

        XCTAssertFalse(utterances.isEmpty, "Read nothing — the cursor was probably not at the top")

        // A heading level only reaches the utterance when .accessibilityHeading is paired
        // with .accessibilityAddTraits(.isHeader). Apple does not document the pairing.
        XCTAssertTrue(
            utterances.contains { $0.contains("Store Hours Heading level 2") },
            "Expected a level-2 heading. Got:\n\(utterances.joined(separator: "\n"))"
        )
    }

    // MARK: - Keyboard quick navigation

    /// `typeKey` reaches VoiceOver, so quick-nav commands work. Collecting what
    /// `VO-Cmd-H` lands on verifies a heading is reachable the way the Rotor reaches it —
    /// a heading absent from this sequence is one users cannot jump to.
    ///
    /// Note `ctrl+opt+H` is **Home**, not "next heading". It backgrounds the app and
    /// invalidates every later assertion.
    @MainActor
    func testHeadingQuickNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        openTechnique("Headings", in: app)

        let vo = XCUIDevice.shared.voiceOverService
        try vo.enable()
        defer { try? vo.disable() }

        // currentSpeech() throws noSpeech until VoiceOver has focused something, so
        // anchor the cursor with one real move before reading it.
        _ = try vo.moveForward()

        var landedOn: [String] = []
        var previous = ""
        for _ in 1...20 {
            app.typeKey("h", modifierFlags: [.control, .option, .command])
            Thread.sleep(forTimeInterval: 1.5)

            // VoiceOver speaks "Heading not found" rather than throwing when there is
            // no next heading.
            guard let utterance = try? vo.currentSpeech().utterance,
                  !utterance.contains("not found") else { break }
            if utterance == previous { break }
            landedOn.append(utterance)
            previous = utterance
        }

        XCTAssertFalse(landedOn.isEmpty, "VO-Cmd-H never reached a heading")
        XCTAssertTrue(
            landedOn.allSatisfy { $0.contains("Heading") },
            "Quick nav stopped on a non-heading:\n\(landedOn.joined(separator: "\n"))"
        )
    }

    // MARK: - Why string matching is not enough

    /// The automation-testing page carries a real heading and a fake one. The fake puts
    /// the word "Heading" in `.accessibilityLabel` with no header trait, so its utterance
    /// contains "Heading" and a `contains("Heading")` assertion passes — while VoiceOver
    /// users cannot reach it with the Rotor at all.
    ///
    /// Quick navigation is the assertion that distinguishes them, because it reports
    /// where the cursor *lands* rather than what a string says. It is also immune to the
    /// 64-character truncation that makes string matching unreliable on long labels.
    @MainActor
    func testFakeHeadingIsNotReachableByQuickNav() throws {
        let app = XCUIApplication()
        app.launch()
        openTechnique("VoiceOver Automation Testing", in: app)

        let vo = XCUIDevice.shared.voiceOverService
        try vo.enable()
        defer { try? vo.disable() }

        rewindToTop(vo)
        let utterances = try readToEndOfScreen(vo)

        // Both announce the word "Heading", so neither can be told apart by text alone.
        XCTAssertTrue(
            utterances.contains { $0.contains("Store Hours Heading level 2") },
            "Expected the real heading. Got:\n\(utterances.joined(separator: "\n"))"
        )
        XCTAssertTrue(
            utterances.contains { $0.contains("Store Hours, Heading") },
            "Expected the fake heading's label to contain the word Heading"
        )

        // Now the assertion that actually distinguishes them.
        rewindToTop(vo)
        _ = try vo.moveForward()

        var landedOn: [String] = []
        var previous = ""
        for _ in 1...20 {
            app.typeKey("h", modifierFlags: [.control, .option, .command])
            Thread.sleep(forTimeInterval: 1.5)
            guard let utterance = try? vo.currentSpeech().utterance,
                  !utterance.contains("not found") else { break }
            if utterance == previous { break }
            landedOn.append(utterance)
            previous = utterance
        }

        XCTAssertTrue(
            landedOn.contains { $0.contains("Store Hours Heading level 2") },
            "Quick nav should reach the real heading. Landed on:\n\(landedOn.joined(separator: "\n"))"
        )
        XCTAssertFalse(
            landedOn.contains { $0.contains("Store Hours, Heading") },
            "Quick nav must not reach the fake heading. Landed on:\n\(landedOn.joined(separator: "\n"))"
        )
    }
}
