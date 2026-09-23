# Accessibility Custom Content
Use `.accessibilityCustomContent` to expose information that the visual design conveys without text, such as an element's position within a layout. VoiceOver exposes those details through the More Content rotor instead of speaking them as part of the accessible name.

With VoiceOver on, rotate 2 fingers on the screen to select the More Content rotor option, then swipe up or down with 1 finger to hear each detail of the focused element.

This is an accessibility usability enhancement, not a conformance requirement. Not using it fails no WCAG success criterion.

## Custom content adds, it never replaces

Do not override `.accessibilityLabel` to make room for custom content. Let the element keep the name it derives from its own visible text — a `Button` containing `Text("14C")` is already named "14C", and there is nothing to improve on. Custom content is for what the layout communicates that no text on screen states.

Two rules follow from that:

- **Never put information in custom content that is not already available to sighted users.** Detail that exists only for VoiceOver creates a divergent experience, drifts out of sync with the rest of the app, and reaches nobody using Voice Control, Switch Control, Full Keyboard Access, or screen magnification.
- **Never put essential information in custom content.** The More Content rotor is gated behind a VoiceOver verbosity setting that many users never change, so content there is easy to miss entirely. Essential information belongs in the accessible name, in `.accessibilityValue`, or in a trait.

Good candidates are dimensions the design encodes spatially or graphically, where a linear traversal loses what a sighted user takes in at a glance:

- A seat's window, middle, or aisle position, conveyed only by its column in a seat map.
- Which part of a cabin, calendar, or grid an element sits in, conveyed only by how far down the layout it appears.
- A value encoded by mark size in a chart, where the number appears nowhere as text.

## Importance

The `importance` parameter controls when VoiceOver speaks the detail:

- `.default` — output on demand only. Users hear it when they navigate to it in the More Content rotor. This is the default value.
- `.high` — output immediately, as part of the element's announcement.

Use `.high` for the one dimension users make their decision on — seat position, in the example below. Marking everything `.high` makes every element's announcement long, which defeats the purpose of putting the detail in custom content at all.

## Reusable content keys

`AccessibilityCustomContentKey` declares a label once and gives it a stable `id`:

```swift
private let positionKey = AccessibilityCustomContentKey("Position", id: "position")

// …

.accessibilityCustomContent(positionKey, seat.position, importance: .high)
```

The `id` lets VoiceOver recognize the same piece of content across elements, so it keeps a consistent position in the More Content rotor as users move through a grid or list. This matters most when the same few labels repeat across many elements, as they do in a seat map.

A key is also the only way to attach a label that is not a string literal. The overload that takes a `String` variable for both the label and the value is marked unavailable in SwiftUI — wrap both in `Text`, or use a key.

## Seat map example

Each seat is a `Button` containing only its seat number, so VoiceOver derives the name from the visible text and announces "14C, button". Window versus aisle, and front versus rear of the cabin, exist nowhere as text — they are conveyed entirely by the seat's place in the grid:

```swift
Button(action: { selectedSeat = seat.id }) {
    Text(seat.id)
        .frame(width: 44, height: 44)
        // …
}
.accessibilityCustomContent(positionKey, seat.position, importance: .high)
.accessibilityCustomContent(cabinAreaKey, seat.cabinArea)
.accessibilityAddTraits(isSelected ? [.isSelected] : [])
```

No `.accessibilityLabel` anywhere. Selection is essential state, so it uses `.isSelected` rather than custom content.

## Notes

- Do not repeat the element's label, value, or role in custom content. VoiceOver already announces those.
- Do not name gestures in custom content. Describe the data, not how to reach it.
- Information conveyed visually by color alone needs a non-color indicator for sighted users, which is a [1.4.1 Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color) requirement in its own right. Custom content does not address it.
- Available on iOS 15 and later.

## Applicable WCAG Success Criteria
- N/A


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
