# VoiceOver Testing
`XCUIVoiceOverService` (iOS, macOS, tvOS, watchOS and visionOS 27.0) drives VoiceOver from a UI test and returns what it **speaks** as a `String`. That makes the announcement itself assertable, instead of inspecting source for a modifier and assuming the modifier reaches VoiceOver.

Reach it through `XCUIDevice.shared.voiceOverService`. The whole API is eight members:

```swift
@MainActor
func readTheScreen() throws {
    let vo = XCUIDevice.shared.voiceOverService
    try vo.enable()                                 // also: vo.disable(), vo.isEnabled

    let first = try vo.moveForward().utterance       // -> "Store Hours Heading level 2"
    _ = try vo.currentSpeech().utterance             // re-read the focused element
    _ = try vo.moveBackward()
    try vo.moveIn()                                  // into a container (iOS + macOS only)
    try vo.moveOut()

    try vo.disable()
}
```

`Output.utterance` is the spoken string, trait included and space separated — `Add Favorites Button`, `Store Hours Heading`, `Store Hours Heading level 2`. Apple's header comments it as `"Add Favorites, button"`, with a comma and a lowercase trait; the real output has neither, so do not write assertions against the documented shape. Hints are part of the utterance too (`Notifications Switch button on Double tap to toggle setting.`), which makes exact-match assertions sensitive to hint text.

## Walking a screen

```swift
var utterances: [String] = []
var previous = ""
for _ in 1...80 {
    let current = try vo.moveForward().utterance
    if current == previous { break }          // end of screen — see Notes
    utterances.append(current)
    previous = current
}
```

The resulting sequence **is** the VoiceOver reading order, which no static analysis can tell you.

## Keyboard quick navigation

`XCUIElement.typeKey(_:modifierFlags:)` reaches VoiceOver, so quick-nav commands work and you can jump heading to heading the way a VoiceOver user does:

```swift
app.typeKey("h", modifierFlags: [.control, .option, .command])   // VO-Cmd-H, next heading
app.typeKey(.rightArrow, modifierFlags: [.control, .option])     // VO-Right, next item
app.typeKey("h", modifierFlags: [])                              // single-key Quick Nav
```

This is the closest thing to verifying that a heading is reachable the way the Rotor reaches it. Collect what `VO-Cmd-H` lands on and a heading that never appears in the sequence is a heading users cannot jump to.

Notes:

* `currentSpeech()` throws `noSpeech` until VoiceOver has focused something. Anchor the cursor with one `moveForward()` before calling it, or every read returns an error — and a test that swallows those errors **passes while measuring nothing**.
* `moveForward()` saturates silently at the last element, returning the same utterance forever instead of throwing. `moveBackward()` is not symmetric: at the top of the screen it **throws** `noSpeech` ("Failed to send moveBackward command"). Guard the forward walk with repeat-detection and the backward walk with `try?`.
* The VoiceOver cursor persists across app launches and test runs, and there is no API to focus the first element — only relative movement. A run that inherits a cursor parked on the tab bar walks straight off the end and reports almost nothing. Rewind with `moveBackward()` first to normalize the starting position.
* `ctrl+opt+H` is Home, not "next heading". It backgrounds the app and leaves the cursor on the Home screen, silently invalidating every later assertion in the test.
* The heading **level** reaches the utterance only when `.accessibilityHeading(.h1–.h6)` and `.accessibilityAddTraits(.isHeader)` are **both** applied — `Store Hours Heading level 2`. `.accessibilityHeading` on its own does nothing. Apple does not document that the pairing is required, which makes this an easy defect to ship: the level is set in code, review sees it, and VoiceOver never says it. `.isHeader` alone announces a bare `Heading`, so a screen whose headings all read `Heading` has no level structure at all. Testing the utterance is the only way to tell those three states apart. See [Headings.md](Headings.md).
* The VoiceOver caption panel is rendered into the framebuffer, so `XCUIScreen.main.screenshot()` captures the announcement as visible text with the VoiceOver cursor drawn around the focused element. The caption fills in **progressively** and the trait only lands at the end of the utterance, so a screenshot taken immediately after `moveForward()` catches it mid-speech showing the label alone. Sleep before capturing, and scale the delay to the length of the utterance.
* The cursor box in a screenshot outlines the whole accessibility element. A box drawn around an entire card is evidence that the card is one element and that any trait on a view inside it is unreachable.

Known Issues:
* There is no API to focus a specific element. Movement is relative only, so reaching element *n* means stepping to it and matching on its utterance.
* The Rotor cannot be driven — no rotor member exists on the service, and there is no touch injection with which to perform the two-finger rotate gesture. Built-in quick navigation by element type is reachable from the keyboard, but a custom `.accessibilityRotor()` is only reachable by the rotor gesture and so cannot be tested. See [Rotor.md](Rotor.md).
* Requires an iOS 27 **runtime**. The app's own deployment target can be lower; the UI test target is what needs `27.0`, or an `@available(iOS 27.0, *)` annotation on the test.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Apple Developer Documentation
- [XCUIDevice](https://developer.apple.com/documentation/xctest/xcuidevice)
- [XCUIElement/typeKey(_:modifierFlags:)](https://developer.apple.com/documentation/xctest/xcuielement/typekey(_:modifierflags:))
- [Performing accessibility audits for your app](https://developer.apple.com/documentation/xctest/performing-accessibility-audits-for-your-app)

----

Copyright 2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
