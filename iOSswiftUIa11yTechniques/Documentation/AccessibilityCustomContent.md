# Accessibility Custom Content
Use `.accessibilityCustomContent` to attach supplementary details to an element without lengthening its accessible name. VoiceOver exposes those details through the More Content rotor instead of speaking them as part of the label.

With VoiceOver on, rotate 2 fingers on the screen to select the More Content rotor option, then swipe up or down with 1 finger to hear each detail of the focused element.

Custom content is the fix for data dense cards. Instead of a run-on `.accessibilityLabel` that VoiceOver reads in full every time focus lands on the card, keep the name and status in `.accessibilityLabel` and `.accessibilityValue` and move the supporting details to `.accessibilityCustomContent`.

## Importance

The `importance` parameter controls when VoiceOver speaks the detail:

- `.default` — output on demand only. Users hear it when they navigate to it in the More Content rotor. This is the default value.
- `.high` — output immediately, as part of the element's announcement.

Reserve `.high` for the small number of details that change what the element means, such as "Delayed 45 minutes" on a flight card. Marking everything `.high` recreates the run-on announcement you were trying to avoid.

## Reusable content keys

`AccessibilityCustomContentKey` declares a label once and gives it a stable `id`:

```swift
private let refillsKey = AccessibilityCustomContentKey("Refills remaining", id: "refills")

// …

.accessibilityCustomContent(refillsKey, "\(prescription.refills)")
```

The `id` lets VoiceOver recognize the same piece of content across elements, so it keeps a consistent position in the More Content rotor as users move through a list.

A key is also the only way to attach a label that is not a string literal. The overload that takes a `String` variable for both the label and the value is marked unavailable in SwiftUI — wrap both in `Text`, or use a key.

## Notes

- Custom content supplements information that is already available on screen. It is not a substitute for a visible text label.
- Custom content is surfaced by VoiceOver. Voice Control and Full Keyboard Access users do not receive it, so never put essential information there and nowhere else.
- Do not repeat the element's label, value, or role in custom content. VoiceOver already announces those.
- Do not name gestures in custom content. Describe the data, not how to reach it.
- Available on iOS 15 and later.

## Applicable WCAG Success Criteria
- [1.3.1 Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)
- [4.1.2 Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

Used correctly, custom content is an enhancement beyond WCAG. The criteria above are the ones that misuse fails: putting an element's name or state only in custom content instead of in `.accessibilityLabel` or `.accessibilityValue`, or conveying information that exists nowhere else in the interface.


## Apple Developer Documentation
- [View/accessibilityCustomContent(_:_:importance:)](https://developer.apple.com/documentation/swiftui/view/accessibilitycustomcontent(_:_:importance:))
- [AccessibilityCustomContentKey](https://developer.apple.com/documentation/swiftui/accessibilitycustomcontentkey)
- [AXCustomContent.Importance](https://developer.apple.com/documentation/accessibility/axcustomcontent/importance)

## Swift Technique Source Code
[AccessibilityCustomContentView.swift](../iOSswiftUIa11yTechniques/AccessibilityCustomContentView.swift)

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
