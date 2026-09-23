# Accessibility Custom Content
Use `.accessibilityCustomContent` to expose supplementary details that are not shown as text on screen, without adding them to the element's accessible name. VoiceOver exposes those details through the More Content rotor instead of speaking them as part of the name.

With VoiceOver on, rotate 2 fingers on the screen to select the More Content rotor option, then swipe up or down with 1 finger to hear each detail of the focused element.

## Custom content never replaces the accessible name

This is the rule that matters most, and the one that is easiest to get wrong.

Every piece of text that is visible on screen must still be in the accessible name. Moving visible text out of the name and into custom content breaks two things:

- **VoiceOver stops speaking it on focus.** Custom content at `.default` importance is announced only when the user navigates to it in the More Content rotor. Most users never open that rotor, so the text is effectively gone.
- **Speech input users cannot target what they see.** WCAG [2.5.3 Label in Name](https://www.w3.org/WAI/WCAG22/Understanding/label-in-name.html) requires the accessible name of a control to contain its visible text label. A Voice Control user who says "tap Ready for pickup" gets no match if that text was moved into custom content.

The pattern to avoid:

```swift
// BAD — .ignore discards every visible Text, and the label keeps only the first line.
Button(action: refill) {
    VStack(alignment: .leading) {
        Text("Atorvastatin 20 mg").font(.headline)
        Text("Ready for pickup")
        Text("Refills remaining: 2")
    }
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Atorvastatin 20 mg")
.accessibilityCustomContent("Status", "Ready for pickup")
.accessibilityCustomContent("Refills remaining", "2")
```

The fix is to let the name keep the visible text and reserve custom content for details the card does not print:

```swift
// GOOD — the Button builds its name from its visible text.
// Refills and prescriber are on the detail screen, not on this card.
Button(action: refill) {
    VStack(alignment: .leading) {
        Text("Atorvastatin 20 mg").font(.headline)
        Text("Ready for pickup")
    }
}
.accessibilityCustomContent("Refills remaining", "2")
.accessibilityCustomContent("Prescriber", "Dr. Chen")
```

For a container that is not already a single element, use `.accessibilityElement(children: .combine)` so the visible text is gathered into the name, then attach custom content on top of it. Use `.ignore` only when you are replacing the children with a label that contains the same visible text.

A long accessible name is not a reason to reach for custom content. If a card displays six lines of text, its name has to contain those six lines. VoiceOver users control announcement length with their own verbosity and speech rate settings.

## Importance

The `importance` parameter controls when VoiceOver speaks the detail:

- `.default` — output on demand only. Users hear it when they navigate to it in the More Content rotor. This is the default value.
- `.high` — output immediately, as part of the element's announcement.

Reserve `.high` for the rare supplementary detail worth interrupting for. Marking everything `.high` recreates the long announcement custom content is meant to avoid.

`.high` is **not** a fix for a name that is missing visible text. If the detail is visible on screen, or is essential to understanding the element, it belongs in the name or in `.accessibilityValue`, at which point it does not need to be custom content at all.

## Reusable content keys

`AccessibilityCustomContentKey` declares a label once and gives it a stable `id`:

```swift
private let pharmacyKey = AccessibilityCustomContentKey("Pharmacy", id: "pharmacy")

// …

.accessibilityCustomContent(pharmacyKey, prescription.pharmacy)
```

The `id` lets VoiceOver recognize the same piece of content across elements, so it keeps a consistent position in the More Content rotor as users move through a list.

A key is also the only way to attach a label that is not a string literal. The overload that takes a `String` variable for both the label and the value is marked unavailable in SwiftUI — wrap both in `Text`, or use a key.

## Notes

- Custom content is surfaced by VoiceOver. Voice Control and Full Keyboard Access users do not receive it, so never put essential information there and nowhere else.
- Information conveyed visually by color or shape alone needs visible text, not custom content. A red dot plus a custom content "Status" detail still fails [1.4.1 Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html) for sighted users.
- Do not repeat the element's label, value, or role in custom content. VoiceOver already announces those.
- Do not name gestures in custom content. Describe the data, not how to reach it.
- Giving VoiceOver users a shortcut to detail that sighted users reach by opening the element is a legitimate enhancement. Hiding something from everyone except VoiceOver users is not.
- Available on iOS 15 and later.

## Applicable WCAG Success Criteria
- [1.3.1 Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)
- [2.5.3 Label in Name](https://www.w3.org/WAI/WCAG22/Understanding/label-in-name.html)
- [4.1.2 Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

Used correctly, custom content is an enhancement beyond WCAG. The criteria above are the ones that misuse fails: moving visible text out of the accessible name (2.5.3), putting an element's name or state only in custom content instead of in `.accessibilityLabel` or `.accessibilityValue` (4.1.2), and conveying information that exists nowhere else in the interface (1.3.1).


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
