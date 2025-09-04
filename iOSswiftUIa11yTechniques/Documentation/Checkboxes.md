# Checkboxes
Code checkboxes as `Toggle` elements with a custom `.toggleStyle`. 

Use `Toggle("Label Text")` to create label text. 

Use `.accessibilityValue(isChecked ? "Checked" : "Unchecked")` to create custom value text for VoiceOver. 

Checkbox groups need an accessibility label for the group which matches the visible group label text. 

Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel("Group Label")` on the checkbox group container so that VoiceOver users hear the group label spoken when first moving focus to a checkbox in the group.

Notes:
- SwiftUI has no native checkbox control or accessibility trait for VoiceOver. 
- In XCUITesting use `.switches` to select a `Toggle` as `.toggles` does not work.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[CheckboxesView.swift](../iOSswiftUIa11yTechniques/CheckboxesView.swift)

----

Copyright 2024-2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

