# Accessibility Hint
Use `.accessibilityHint` to describe the result of performing an action on a control. Hints are optional — VoiceOver users can turn them off in Settings. Only provide a hint when the result is not obvious from the element's label.

Follow Apple's guidelines for writing hints:
- Describe the **result** of the action, not how to perform it.
- Use **third-person singular** verbs ("Adds this item to your favorites."), not imperative ("Add this item").
- Do **not** mention gesture names ("tap", "double tap", "swipe").
- Do **not** repeat the label or include the control type ("button", "link").
- Begin with a capitalized word and end with a period.

Notes:
- A Play button does not need a hint because the result is obvious from the label.
- A song title in a list may need a hint like "Plays the song." because the label does not imply what tapping does.
- Input fields can use hints to convey format requirements like "Required. 8 character minimum."

## Applicable WCAG Success Criteria
- [3.3.2 Labels or Instructions](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions)

## Swift Technique Source Code
[AccessibilityHintView.swift](../iOSswiftUIa11yTechniques/AccessibilityHintView.swift)

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
