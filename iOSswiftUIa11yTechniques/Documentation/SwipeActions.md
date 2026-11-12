# Swipe Actions
`.swipeActions` hides functionality behind a horizontal drag across a row. A drag is a path-based gesture, so the same functionality has to be reachable without one. Provide a `Select` button, the way iOS Mail does: it turns on `EditMode`, rows become single-tap selection targets, and a visible action bar runs the same Delete, Flag, and Mark as Read actions on the selection.

- Use `@State private var editMode: EditMode = .inactive` with `.environment(\.editMode, $editMode)` on the `List`, and a `Select` button that sets it to `.active`. `EditButton()` does the same thing but is always titled "Edit", so write the button when the label needs to say "Select".
- Use `List(selection:)` with a `Set` of the row identifiers. In edit mode, each row becomes a single-tap selection target and iOS supplies the selected trait to VoiceOver automatically.
- Name the action bar buttons after what they will act on, e.g. `.accessibilityLabel("Delete 2 Selected Messages")`. The selection count is otherwise only drawn, as filled circles.
- Do not add `.accessibilityAction` to a row that already uses `.swipeActions`. SwiftUI publishes the swipe buttons as accessibility custom actions on the row, so VoiceOver (swipe up or down, then double tap), Switch Control, Full Keyboard Access (`Tab + z`), and Voice Control ("Show actions for…") all reach them already. Adding `.accessibilityAction` duplicates every action in those menus.
- The Actions menu is not the single-tap alternative. It is assistive-technology-only, and 2.5.1 is written for users who operate the screen with a single pointer and no assistive technology at all — a tremor, a hand splint, a head pointer, a switch-adapted mouse. That is the gap the `Select` button closes.
- Hand-rolled gestures are a different technique. A `DragGesture` or `LongPressGesture` publishes nothing, so it needs both `.accessibilityAction` and a visible single-tap path. See [Accessibility Actions](AccessibilityActions.md).
- A per-row overflow menu works as well as a `Select` button when the actions only ever apply to one row. The requirement is a visible control, not a specific pattern.

## Applicable WCAG Success Criteria
- [2.1.1 Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)
- [2.5.1 Pointer Gestures](https://www.w3.org/WAI/WCAG22/Understanding/pointer-gestures)
- [2.5.7 Dragging Movements](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements)

## Apple Developer Documentation
- [View/swipeActions(edge:allowsFullSwipe:content:)](https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:))
- [EditMode](https://developer.apple.com/documentation/swiftui/editmode)
- [List/init(selection:content:)](https://developer.apple.com/documentation/swiftui/list)

## Swift Technique Source Code
[SwipeActionsView.swift](../iOSswiftUIa11yTechniques/SwipeActionsView.swift)

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
