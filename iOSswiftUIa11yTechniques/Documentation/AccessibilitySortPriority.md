# Accessibility Sort Priority
Use `.accessibilitySortPriority()` to control VoiceOver reading order when the default order is not meaningful. Higher numbers are read first, e.g., a priority of 99 is read before 1. The default sort priority is 0.

Use `.accessibilitySortPriority()` to ensure VoiceOver focuses on the most important element first when a new view or sheet appears.

**Use sort priority only when needed.** VoiceOver's default reading order (left-to-right, top-to-bottom) works correctly for most layouts. Only add `.accessibilitySortPriority()` when the visual layout genuinely doesn't match the logical reading order — for example, ZStack overlays where the top layer should be read first. Overusing sort priority makes VoiceOver order fragile: every new element needs a priority value, existing values may need re-numbering, and the result is harder to maintain and test than restructuring the view hierarchy.

Before using `.accessibilitySortPriority()`, consider these alternatives:
- Reorder views in the source code to match the intended reading order
- Use `.accessibilityElement(children: .combine)` to group related elements into one
- Use `.accessibilityElement(children: .contain)` to scope reading order within a container
- Use `.accessibilityHidden(true)` on decorative elements that don't need to be read

**Test on a real device.** The iOS Simulator does not respect `.accessibilitySortPriority()` values — VoiceOver in the Simulator reads elements in source order regardless of sort priority. You must test on a physical device to verify the reading order is correct.

## Never use negative sort priority values

**Do not set `.accessibilitySortPriority()` to a negative value.** Sort priority does more than just reorder swipe navigation — VoiceOver also consults it during **Explore by Touch** hit testing. When two accessibility elements overlap at a touch point, VoiceOver picks the one with the higher priority. The default priority is `0`, so any element with a negative priority — for example, `-1` — loses to any other overlapping element with the default priority.

This has serious consequences for floating UI that overlaps scroll content:

- A floating bottom tab bar with `.accessibilitySortPriority(-1)` will lose Explore by Touch hit tests to any scroll content sitting behind it (for example, a `ScrollView` that uses `.ignoresSafeArea(edges: .bottom)`).
- Users dragging a finger over the tab bar will hear scroll content instead of a tab button, even though swipe navigation still reaches each tab. The tab bar effectively becomes unreachable via Explore by Touch — a critical failure of WCAG 2.5.1 Pointer Gestures and 2.1.1 Keyboard.
- The failure is silent: unit tests, snapshot tests, and swipe-navigation testing all pass; only Explore by Touch testing on a real device catches it.

If you need to place a floating overlay on top of scroll content and keep it usable with VoiceOver:

- **Leave the overlay at the default priority (`0`).** Do not lower it below content.
- **If reading order is a concern, raise the overlay's priority instead of lowering it.** For example, set the tab bar to `.accessibilitySortPriority(1)` and leave content at `0`.
- **Do not let scroll content extend behind the overlay.** Constrain the `ScrollView` to end above the overlay rather than using `.ignoresSafeArea(edges: .bottom)`. If you must extend behind, ensure the overlay wins hit tests via priority, not loses.
- **Avoid large combined accessibility frames near the overlay.** `.accessibilityElement(children: .combine)` merges children into one frame that spans the full bounds of the container. A tall combined card behind a tab bar guarantees hit-test overlap.

You can see this failure mode reproduced in the *Explore by Touch Broken* prototype (`Prototypes/ExploreByTouchBrokenView.swift`), which mirrors the exact layout, sort priority, and combined-card pattern of a real production app.

## Applicable WCAG Success Criteria
- [1.3.2: Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)
- [2.1.1: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)
- [2.4.3: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)
- [2.5.1: Pointer Gestures](https://www.w3.org/WAI/WCAG22/Understanding/pointer-gestures)


## Apple Developer Documentation
- [View/accessibilitySortPriority(_:)](https://developer.apple.com/documentation/swiftui/view/accessibilitysortpriority(_:))

## Swift Technique Source Code
[AccessibilitySortPriority.swift](../iOSswiftUIa11yTechniques/AccessibilitySortPriority.swift)

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

