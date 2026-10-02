# Show Borders
Show Borders adds a system-drawn shape to controls iOS recognizes as buttons, so users who cannot infer interactivity from color or position can still tell what is tappable.

This setting is found at **Settings > Accessibility > Display & Text Size**. It was labelled **Button Shapes** in iOS 26.0 and earlier and was renamed to **Show Borders** by iOS 26.3. Only the label changed: the preference key is still `BUTTON_SHAPES`, and the SwiftUI and UIKit APIs still use the original button shapes naming.

A basic SwiftUI `Button` with a text label renders as plain tinted text — no border, no fill. Nothing but its color and position says it is tappable, which is the whole reason this setting exists. When a button has no visible affordance of its own, the shape iOS injects is the only thing the user gets, and it often reads as an oversized low-contrast grey block that fights the app's design.

Draw your own border instead, and leave the button room to grow when you do. Do not suppress the system shape outright — it is an accommodation some users depend on, and removing it without substituting your own affordance reintroduces the problem it exists to solve.

- Use `@Environment(\.accessibilityShowButtonShapes)` to check if the user has enabled Show Borders, then stroke your own border. A plain text button has none by default, so this is the modifier that gives it one.
- **Let the button size itself from its label.** This is the one that bites. A hardcoded `.frame(width:height:)` combined with `.lineLimit(1)` leaves the border nowhere to go, so the padding it needs is taken out of the label and the text truncates to an ellipsis the moment the user enables Show Borders. Size with `minWidth` and `minHeight` so the button grows to fit instead. Turning on an accessibility setting should never cost the user the button's name.
- The border needs at least 3:1 contrast against the background it sits on to satisfy 1.4.11. `Color.accentColor` on the default background clears this.
- **A text-only button is identified by color and position alone, which is what 1.4.1 Use of Color cautions against.** Honouring Show Borders is the minimum, not a clean bill of health: it only helps users who have found the setting. A button carrying a critical action is better off with a fill, border, or underline that is always present.
- If you factor the border into a custom `ButtonStyle`, read the environment inside a nested `View` in `makeBody` rather than on the style itself. A `ButtonStyle` is not a `View` and does not reliably receive environment updates.
- `accessibilityShowButtonShapes` is a read-only environment key, so the enabled state cannot be pinned with `.environment()` in a SwiftUI `Preview`. Toggle the setting in iOS Settings to test both states.
- In UIKit, read `UIAccessibility.buttonShapesEnabled` and observe `UIAccessibility.buttonShapesEnabledStatusDidChangeNotification`. With `UIButton.Configuration`, assign an explicit `background` inside `configurationUpdateHandler` so the resolver does not supply a grey fill of its own.

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
