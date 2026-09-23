# Accessibility Custom Content
Use `.accessibilityCustomContent` to attach extra details to an element as labelled key and value pairs, without adding them to its accessible name. VoiceOver exposes them under the **More Content** rotor.

Apple built the API for data-rich apps, where an element carries more information than its accessible name should hold. Their stated purpose, from the WWDC21 session "Tailor the VoiceOver experience in your data-rich apps", is to deliver that information in a concise form and only when someone wants it, rather than packing all of it into the label.

VoiceOver speaks `.default` importance details only when the user asks for them, and speaks `.high` importance details immediately as part of the element's announcement.

This is an accessibility usability enhancement, not a conformance requirement. Not using it fails no WCAG success criterion.

## Custom content adds, it never replaces

Do not override `.accessibilityLabel` to make room for custom content. Let the element keep the name it derives from its own visible text — a `Button` containing `Text("14C")` is already named "14C", and there is nothing to improve on. Custom content is for what the layout communicates that no text on screen states.

Two rules follow from that:

- **Never put information in custom content that is not already available to sighted users.** Detail that exists only for VoiceOver creates a divergent experience, drifts out of sync with the rest of the app, and reaches nobody using Voice Control, Switch Control, Full Keyboard Access, or screen magnification.
- **Never put essential information in custom content.** Content at `.default` importance is always retrievable, but nothing necessarily tells the user it is there to retrieve. Essential information belongs in the accessible name, in `.accessibilityValue`, or in a trait.

Good candidates are dimensions the design encodes spatially or graphically, where a linear traversal loses what a sighted user takes in at a glance:

- Whether a seat is a window seat, middle seat, or aisle seat, conveyed only by its column in a seat map.
- Which part of a cabin, calendar, or grid an element sits in, conveyed only by how far down the layout it appears.
- A value encoded by mark size in a chart, where the number appears nowhere as text.

### Discoverability

VoiceOver's **Verbosity > More Content** setting controls whether users get any signal that the focused element has custom content attached. The options are to speak a hint, play a sound, change pitch, or **Do Nothing**. Set to Do Nothing, there is no cue at all — the content is still reachable through the More Content rotor, but users only find it if they already think to check every element.

This is a discoverability limit, not an availability one, and it is the reason not to rely on `.default` importance for anything users need to notice. Content at `.high` importance is unaffected, because VoiceOver speaks it as part of the element's announcement regardless of this setting.

## Importance

The `importance` parameter controls when VoiceOver speaks the detail:

- `.default` — output on demand only. Users hear it when they navigate to it in the More Content rotor. This is the default value.
- `.high` — output immediately, as part of the element's announcement.

Use `.high` for the one dimension users make their decision on — seat position, in the example below. Marking everything `.high` makes every element's announcement long, which defeats the purpose of putting the detail in custom content at all.

`.high` is also the only importance that is immune to the Verbosity > More Content setting described above, so it is the right choice for a detail users need to notice without going looking for it.

Marking a detail `.high` does not remove it from the rotor. Per Apple's WWDC21 session, `.high` content is announced on focus *and* remains available in the More Content rotor, so users can return to it individually — which is what distinguishes it from folding the same information into `.accessibilityValue`.

VoiceOver speaks `.high` content immediately after the accessible name, ahead of the element's role and state. See [What VoiceOver announces](#what-voiceover-announces) for a verified example.

## Reusable content keys

`AccessibilityCustomContentKey` declares a label once and gives it a stable `id`:

```swift
private let positionKey = AccessibilityCustomContentKey("Position", id: "position")

// …

.accessibilityCustomContent(positionKey, seat.position, importance: .high)
```

The `id` lets VoiceOver recognize the same piece of content across elements, so it keeps a consistent position in the More Content rotor as users move through a grid or list. This matters most when the same few labels repeat across many elements, as they do in a seat map.

A key is also the only way to attach a label that is not a string literal. The overload that takes a `String` variable for both the label and the value is marked unavailable in SwiftUI — wrap both in `Text`, or use a key.

Give the key an **empty label** when the value already describes itself. `AccessibilityCustomContentKey("", id: "position")` with the value "Window seat" is announced as just "Window seat", where a label of `"Position"` would have produced the redundant "Position, Window seat". Keep a label when the value cannot stand alone, as "Front" cannot without "Cabin area" in front of it.

## Seat map example

Each seat is a `Toggle` whose label is just the seat number, so VoiceOver derives the name from the visible text. Whether it is a window seat, middle seat, or aisle seat, and which part of the cabin it sits in, exist nowhere as text — they are conveyed entirely by the seat's place in the grid:

```swift
Toggle(isOn: binding(for: seat)) {
    Text(seat.id)
}
.toggleStyle(SeatToggleStyle(selectedBackground: darkGreen))
.accessibilityCustomContent(positionKey, seat.position, importance: .high)   // "Window seat"
.accessibilityCustomContent(cabinAreaKey, seat.cabinArea)                    // "Front"
```

No `.accessibilityLabel` anywhere.

### What VoiceOver announces

Focusing an unselected window seat speaks:

> "12A, Window seat, Switch button, off, Double tap to toggle setting"

"12A" is the accessible name, taken from the visible label. "Window seat" is the `.high` custom content. Everything after that comes from the control itself, not from this API.

Two things to note. **`.high` content is spoken after the name but before the role**, so it reads almost as part of the name — keep it short for that reason. And **cabin area is not announced at all**, because it sits at `.default` importance in the More Content rotor until the user asks for it.

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
