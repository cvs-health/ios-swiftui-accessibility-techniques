# Drag & Drop
Drag and drop interfaces allow users to reorder items by dragging them to a new position. To make drag and drop accessible, provide a single-tap alternative so users who cannot perform drag gestures can still reorder items. Tap a row to select it, then use visible "Move Up" and "Move Down" buttons to change the item's position.

Use `.accessibilityAction(named: "Move Up")` and `.accessibilityAction(named: "Move Down")` to add custom actions to each item. VoiceOver users can swipe up or down to access these actions. Switch Control and Full Keyboard Access users can open the Actions menu with `Tab + z`. Voice Control users can say "Show actions for" and the name or number of the element.

Use `.accessibilityHint` to communicate to VoiceOver users that items are reorderable, e.g., `.accessibilityHint("Reorderable. Use actions to move.")`.

## Applicable WCAG Success Criteria
- [2.1.1 Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)
- [2.5.7 Dragging Movements](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements)

## Swift Technique Source Code
[DragDropView.swift](../iOSswiftUIa11yTechniques/DragDropView.swift)

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
