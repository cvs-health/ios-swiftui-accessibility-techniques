# Page Titles
Page titles must describe the purpose of the page and be unique for each page in the app. 

Use `.navigationTitle` to create a title for each page. 

VoiceOver will speak the page title as a Heading. 

## Long titles truncate, and iOS 27 changed how to stop it

A `.navigationTitle` is laid out on a single line and truncates with an ellipsis when it does not fit. Two things are worth knowing before trying to fix that:

- **Large titles do not wrap.** They truncate like inline ones, and because the font is bigger they fit *fewer* characters. Measured on an iOS 27.0 simulator with a 49-character title: `.inline` showed about 40 characters, `.large` showed about 21. Changing `navigationBarTitleDisplayMode` is not a fix.
- **The truncation is visual only.** VoiceOver reads the whole title regardless, so this affects sighted users rather than screen reader users.

The fix is to let the title shrink to fit. Through iOS 26 a single `UIAppearance` line in the app's `init()` was enough:

```swift
UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
```

**On iOS 27 that line is ignored.** The navigation bar's title is still an ordinary `UILabel` — a runtime walk of the view hierarchy finds the same single label under `NavigationBarLargeTitleView` on both 26.5 and 27.0, with identical sibling view classes — but iOS 27 no longer applies `UIAppearance` values to it. From the same code, the label reads back `adjustsFontSizeToFitWidth == true` on 26.5 and `false` on 27.0.

Because the label still exists, setting the properties on it directly still works. `.navigationTitleFitsWidth()` in [PageTitlesView.swift](../iOSswiftUIa11yTechniques/PageTitlesView.swift) walks up to the enclosing `UINavigationBar` and configures the title label, re-applying on `layoutSubviews` so it survives pushes and rotation:

```swift
ScrollView {
    // …
}
.navigationTitle("Additional Information About This Service or Data")
.navigationTitleFitsWidth()
```

Three details that were measured rather than assumed:

- **`minimumScaleFactor` has to be low enough for the string.** With the property set directly but a floor of `0.5`, a 49-character title still truncated at about 36 characters. `0.3` fits it, which is why that is the default.
- **Do not set `lineBreakMode = .byClipping`.** It removes the ellipsis, so a title that still overflows at the minimum scale is cut off mid-word instead — worse than truncating.
- **Shrinking is a mitigation, not a free win.** At `0.3` the title renders at 30% of its normal size, which is hard to read and interacts badly with large Dynamic Type settings. A shorter title, or a heading inside the page content, is better where the copy allows one. Reach for shrink-to-fit when the title text is fixed and cannot be shortened.

Because it reads a private view hierarchy, this can break again on a future OS the same way the `UIAppearance` approach did. The implementation is a no-op when no navigation bar is found.

## Applicable WCAG Success Criteria
- [2.4.2: Page Titled](https://www.w3.org/WAI/WCAG22/Understanding/page-titled)
- [1.4.4: Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text) — relevant to how far a title is allowed to shrink


## Apple Developer Documentation
- [View/navigationTitle(_:)](https://developer.apple.com/documentation/swiftui/view/navigationtitle(_:)-avgj)
- [UILabel/adjustsFontSizeToFitWidth](https://developer.apple.com/documentation/uikit/uilabel/adjustsfontsizetofitwidth)
- [UILabel/minimumScaleFactor](https://developer.apple.com/documentation/uikit/uilabel/minimumscalefactor)

## Swift Technique Source Code
[PageTitlesView.swift](../iOSswiftUIa11yTechniques/PageTitlesView.swift)

----

Copyright 2023-2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
