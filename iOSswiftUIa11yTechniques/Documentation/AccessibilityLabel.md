# Accessibility Label
Use `.accessibilityLabel` to provide a concise, meaningful name for UI elements that VoiceOver speaks to users. Every accessible element must have a label that describes what it is.

Labels should be brief (ideally a single word like "Delete", "Play", or "Search"), begin with a capitalized word, and not end with a period. Never include the control type in the label (e.g., "button", "image", "link") because VoiceOver already announces the trait.

Notes:
- Use `.accessibilityLabel` when the visible text or icon does not clearly describe the element.
- Include the visible label text at the beginning of the `.accessibilityLabel` so Voice Control users can still activate it.
- For images, describe what the image shows, not the file name or technical details.

## Applicable WCAG Success Criteria
- [1.1.1 Non-text Content](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content)
- [4.1.2 Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[AccessibilityLabelView2.swift](../iOSswiftUIa11yTechniques/AccessibilityLabelView2.swift)

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
