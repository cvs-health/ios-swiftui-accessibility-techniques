# XCTest Accessibility Testing

Automated accessibility testing with XCTest helps catch common issues early. This project uses both `performAccessibilityAudit()` and manual assertions against accessibility properties.

## Key APIs

### `performAccessibilityAudit()` (iOS 17+)

Runs Apple's built-in accessibility audit on the current screen. Checks for contrast, hit area size, text clipping, missing labels, and trait issues.

```swift
try app.performAccessibilityAudit()
```

Filter out known false positives:

```swift
try app.performAccessibilityAudit { issue in
    issue.auditType == .contrast // ignore contrast false positive
}
```

### Manual Assertions

Test that elements exist, have labels, and have correct traits:

```swift
// Assert element exists
XCTAssertTrue(app.buttons["editButton"].exists)

// Assert label is not empty
XCTAssertFalse(app.buttons["editButton"].label.isEmpty)

// Assert two buttons don't have identical labels
XCTAssertNotEqual(app.buttons["edit1"].label, app.buttons["edit2"].label)

// Assert label doesn't contain redundant role word
XCTAssertFalse(app.buttons["edit1"].label.lowercased().contains("button"))

// Assert disabled state
XCTAssertFalse(app.buttons["loginButton"].isEnabled)
```

## What XCTest Can Check

- **Missing labels**: `XCTAssertFalse(element.label.isEmpty)`
- **Duplicate labels**: `XCTAssertNotEqual(element1.label, element2.label)`
- **Label contains role**: `XCTAssertFalse(element.label.contains("button"))`
- **Disabled state**: `XCTAssertFalse(element.isEnabled)`
- **Element existence**: `XCTAssertTrue(element.exists)`
- **Contrast**: via `performAccessibilityAudit()`
- **Hit area size**: via `performAccessibilityAudit()`
- **Text clipping**: via `performAccessibilityAudit()`

## What XCTest Cannot Check

- **Heading traits**: `accessibilityTraits` is not readable in XCUI tests
- **Selected state**: trait-based states are not directly testable
- **VoiceOver reading order**: requires manual VoiceOver testing
- **Decorative images**: hidden elements don't exist in the element tree, so you can only assert they are absent (`XCTAssertFalse(element.exists)`)
- **Missing page titles**: `performAccessibilityAudit()` does not flag missing `.navigationTitle()`

## Limitations and False Positives

`performAccessibilityAudit()` has known issues:

- **Contrast false positives**: Often flags text with sufficient contrast as failing
- **Text clipped false positives**: Flags page titles and properly truncated content
- **Hit area false positives**: Does not account for padding/spacing around elements
- **Only tests visible content**: Content below the fold requires `app.swipeUp()` before auditing
- **Heading traits**: Cannot verify `.isHeader` trait — audit passes with false negatives
- **Page titles**: Missing `.navigationTitle()` is not detected

## Testing Pattern

```swift
func testMyView() throws {
    let app = XCUIApplication()
    app.launch()

    // Navigate to the page
    app.searchFields["Search"].tap()
    app.typeText("My View")
    app.collectionViews.buttons["My View"].tap()

    // Assert elements exist with accessibility identifiers
    XCTAssertTrue(app.buttons["myButton"].exists)
    XCTAssertFalse(app.buttons["myButton"].label.isEmpty)

    // Run accessibility audit
    try app.performAccessibilityAudit()

    // Scroll and audit below the fold
    app.swipeUp()
    try app.performAccessibilityAudit()
}
```

## Apple Developer Documentation
- [performAccessibilityAudit(for:_:)](https://developer.apple.com/documentation/xctest/xcuiapplication/4190847-performaccessibilityaudit)
- [XCUIElement](https://developer.apple.com/documentation/xctest/xcuielement)

## Related Resources

- [WWDC 2023: Perform accessibility audits for your app](https://developer.apple.com/videos/play/wwdc2023/10035/)
- [Hacking with Swift: Xcode UI Testing Cheat Sheet](https://www.hackingwithswift.com/articles/148/xcode-ui-testing-cheat-sheet)
- [Xcode 15 Automated Accessibility Audits](https://www.polpiella.dev/xcode-15-automated-accessibility-audits)
- [Mobile A11y: XCUI Guide](https://mobilea11y.com/guides/xcui/)
- [Orange A11y Guidelines: WWDC 2023 Session Notes](https://a11y-guidelines.orange.com/en/mobile/ios/wwdc/nota11y/2023/2310035/)

## Test Source Code

[iOSswiftUIa11yTechniquesUITests.swift](../iOSswiftUIa11yTechniquesUITests/iOSswiftUIa11yTechniquesUITests.swift)

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
