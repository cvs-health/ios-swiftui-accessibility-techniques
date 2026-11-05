# Scroll Views

Bugs:

- Scroll views are not scrollable with Full Keyboard Access unless there is a focusable control like a `Button` or `DisclosureGroup` inside or after the scroll view. The `ScrollView` can also be made `.focusable()`, or a focusable element can be placed inside the scroll view to allow Full Keyboard Access.
  - WARNING: if you make the `ScrollView` `.focusable()` then DON'T put another focusable element like a `Button` inside the focusable `ScrollView` because nothing inside the scroll view will be focusable at that point. 
  - `.accessibilityRespondsToUserInteraction(true)` on the first element inside the `ScrollView` makes that element focusable and allows Full Keyboard Access to scroll the view, without needing a `Button`. Use this when the scroll view contains only static content and adding a `Button` would be inappropriate. Put the modifier on the first element inside the scroll view, NOT on the `ScrollView` itself — on the `ScrollView` it behaves like `.focusable()` and makes the whole scroll view a single focus stop.

## Applicable WCAG Success Criteria
- [2.1.1: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)


## Apple Developer Documentation
- [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview)
- [View/accessibilityRespondsToUserInteraction(_:)](https://developer.apple.com/documentation/swiftui/view/accessibilityrespondstouserinteraction(_:))
- [View/focusable(_:)](https://developer.apple.com/documentation/swiftui/view/focusable(_:))

## Swift Technique Source Code
[ScrollViews.swift](../iOSswiftUIa11yTechniques/ScrollViews.swift)

----

Copyright 2024-2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

