# Pickers
Pickers need visible label text and an accessibility label. Pickers with the default or `MenuPickerStyle` need `Picker("Label")` text which is spoken to VoiceOver as the accessibility label. 

Pickers with the `WheelPickerStyle` or `SegmentedPickerStyle` need an `.accessibilityLabel` set to match their visible label text and need `.accessibilityElement(children: .contain)` or else the accessibility label will not be spoken to VoiceOver. 

Don't use `.accessibilityLabel` on `Picker` with the default or `MenuPickerStyle` or else VoiceOver will not speak the visible picker value text when the picker is closed. 

Use `AccessibilityFocusState` to send VoiceOver focus back to the picker when the value has been changed.
- `Picker` has no `onDismiss` method like a `Sheet` that could be used to return focus when the picker is closed.

Platform Defects:
- Wheel style Pickers do not have sufficient text contrast for their non-selected options.
- Wheel style Pickers do not support Large Content Viewer.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [2.4.3 Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)
- [3.3.2: Labels or Instructions](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)


----

Copyright 2023 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
