# Button Shapes
Button Shapes adds a system-drawn shape to controls iOS recognizes as buttons, so users who cannot infer interactivity from color or position can still tell what is tappable.

When a button has no visible affordance of its own, that injected shape is the only thing the user gets, and it often reads as an oversized low-contrast grey block that fights the app's design.

Give every button its own visible shape with sufficient contrast so the system has nothing left to add. Do not suppress the system shape outright — it is an accommodation some users depend on, and removing it without substituting your own affordance reintroduces the problem it exists to solve.

- Use `@Environment(\.accessibilityShowButtonShapes)` to check if the user has enabled Button Shapes and then strengthen your own border or underline. Keep padding fixed in both states so enabling the setting never shifts the layout.
- Never identify a button by color alone. A border, a fill, or an underline that is always present keeps the button distinguishable whether or not the setting is on.
- Any border or underline carrying the affordance needs at least 3:1 contrast against the adjacent background.
- `accessibilityShowButtonShapes` is a read-only environment key, so the enabled state cannot be pinned with `.environment()` in a SwiftUI `Preview`. Toggle the setting in iOS Settings to test both states.
- In UIKit, read `UIAccessibility.buttonShapesEnabled` and observe `UIAccessibility.buttonShapesEnabledStatusDidChangeNotification`. With `UIButton.Configuration`, assign an explicit `background` inside `configurationUpdateHandler` so the resolver does not supply a grey fill of its own.

## Applicable WCAG Success Criteria
- [1.4.1 Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color)
- [1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)
- [1.4.11 Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast)


## Apple Developer Documentation
- [EnvironmentValues/accessibilityShowButtonShapes](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityshowbuttonshapes)
- [UIAccessibility/buttonShapesEnabled](https://developer.apple.com/documentation/uikit/uiaccessibility/buttonshapesenabled)
- [UIAccessibility/buttonShapesEnabledStatusDidChangeNotification](https://developer.apple.com/documentation/uikit/uiaccessibility/buttonshapesenabledstatusdidchangenotification)

## Swift Technique Source Code
[ButtonShapesView.swift](../iOSswiftUIa11yTechniques/ButtonShapesView.swift)

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
