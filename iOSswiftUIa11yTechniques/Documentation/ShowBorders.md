# Show Borders
Show Borders adds a system-drawn border to controls iOS recognizes as buttons. A basic SwiftUI `Button` with a text label renders as plain tinted text with no border or fill, so iOS supplies a border when the setting is enabled.

The setting is at **Settings > Accessibility > Display & Text Size**. It was labelled **Button Shapes** in iOS 26.0 and earlier and renamed to **Show Borders** by iOS 26.3. Only the label changed. The preference key is still `BUTTON_SHAPES` and the SwiftUI and UIKit APIs still use the original button shapes naming.

- Use `@Environment(\.accessibilityShowButtonShapes)` to check if the user has enabled Show Borders and then draw your own border.
- Avoid a fixed width or height on the button. A hardcoded `.frame(width:height:)` with `.lineLimit(1)` leaves no room for the border, so the label truncates when the setting is enabled. Use `minWidth` and `minHeight` so the button grows to fit.
- Scale any fixed dimensions with `@ScaledMetric` so the label still fits at larger Dynamic Type sizes.
- Give the border at least 3:1 contrast against the background behind it to meet WCAG 1.4.11. `Color.accentColor` on the default background meets this.
- Tinted label text alone does not fail WCAG 1.4.1. The criterion applies where color is the only visual means of conveying something, and a standalone button is also distinguished by its position and its label. The relevant failure is F73, a control placed inline in a block of text that is not visually evident without color vision; add a permanent underline, fill, or border in that case.
- Label text needs 4.5:1 against its background for WCAG 1.4.3 whether or not the setting is on. iOS `systemBlue` measures 4.0:1 on white and does not meet it. This project's `AccentColor` is a deeper blue that does.
- Do not remove the system border without drawing your own. Users who enable Show Borders depend on it.
- `accessibilityShowButtonShapes` is read-only, so the enabled state cannot be set with `.environment()` in a `Preview`. Toggle the setting in iOS Settings to test both states.
- In a custom `ButtonStyle`, read the environment inside a nested `View` in `makeBody`. A `ButtonStyle` is not a `View` and does not receive environment updates reliably.
- In UIKit, read `UIAccessibility.buttonShapesEnabled` and observe `UIAccessibility.buttonShapesEnabledStatusDidChangeNotification`. With `UIButton.Configuration`, set an explicit `background` in `configurationUpdateHandler` to override the resolved fill.

## Applicable WCAG Success Criteria
- [1.4.1 Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color)
- [1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)
- [1.4.4 Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text)
- [1.4.11 Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast)


## Apple Developer Documentation
- [EnvironmentValues/accessibilityShowButtonShapes](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityshowbuttonshapes)
- [UIAccessibility/buttonShapesEnabled](https://developer.apple.com/documentation/uikit/uiaccessibility/buttonshapesenabled)
- [UIAccessibility/buttonShapesEnabledStatusDidChangeNotification](https://developer.apple.com/documentation/uikit/uiaccessibility/buttonshapesenabledstatusdidchangenotification)

## Swift Technique Source Code
[ShowBordersView.swift](../iOSswiftUIa11yTechniques/ShowBordersView.swift)

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
