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

## Applicable WCAG Success Criteria
- [1.3.2: Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)
- [2.4.3: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)


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

