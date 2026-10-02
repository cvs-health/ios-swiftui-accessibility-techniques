# Show Borders
Show Borders adds a system-drawn border to controls iOS recognizes as buttons. A basic SwiftUI `Button` with a text label renders as plain tinted text with no border or fill, so iOS supplies a border when the setting is enabled.

The setting is at **Settings > Accessibility > Display & Text Size**. It was labelled **Button Shapes** in iOS 26.0 and earlier and renamed to **Show Borders** by iOS 26.3. Only the label changed. The preference key is still `BUTTON_SHAPES` and the SwiftUI API still uses the original button shapes naming.

- Use `@Environment(\.accessibilityShowButtonShapes)` to check if the user has enabled Show Borders and then draw your own border.
- Avoid a fixed width or height on the button. A hardcoded `.frame(width:height:)` with `.lineLimit(1)` leaves no room for the border, so the label truncates when the setting is enabled. Use `minWidth` and `minHeight` so the button grows to fit.
- Scale any fixed dimensions with `@ScaledMetric` so the label still fits at larger Dynamic Type sizes.

## Applicable WCAG Success Criteria
- [1.4.4 Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text)

## Apple Developer Documentation
- [EnvironmentValues/accessibilityShowButtonShapes](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityshowbuttonshapes)

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
