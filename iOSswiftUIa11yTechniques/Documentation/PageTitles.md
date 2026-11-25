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

Because the label still exists, setting the properties on it **directly** does take effect — but only reliably when the titled screen is the `NavigationStack` root. **On a pushed screen it does not work, and there is currently no working workaround here.** Measured on an iOS 27.0 simulator, probing the bar on a pushed screen:

| When | `UILabel`s in the bar | `adjustsFontSizeToFitWidth` |
|---|---|---|
| the pushed view appears | **0** — the title label does not exist yet | — |
| +0.1s / +0.5s / +2.0s | 1 | `false` |

So any hook that runs when the pushed view appears is too early, and nothing re-triggers it once the label is created. Attaching an observer to the navigation bar so the work re-runs on each bar layout did not fix it either.

**Status: unresolved on iOS 27.** If a long title must stay readable, the options that do work are an in-page `Text` heading (which wraps to as many lines as it needs and can carry `.accessibilityAddTraits(.isHeader)`) or shorter title copy. Both are also better for legibility than shrinking: a title scaled far enough to fit a ~49-character string renders very small and interacts badly with large Dynamic Type settings.

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
