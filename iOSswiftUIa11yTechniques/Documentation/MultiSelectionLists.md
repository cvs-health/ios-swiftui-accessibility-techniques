# Multi-Selection Lists
Multi-selection lists allow users to select multiple items from a list. Use `.accessibilityAddTraits(.isSelected)` on selected items so VoiceOver announces the selected state.

Use `.accessibilityRemoveTraits(.isButton)` on the row `Button` so VoiceOver does not speak the redundant "Button" trait when each row is already clearly tappable.

Use `.accessibilityValue(isSelected ? "Selected" : "Not Selected")` to provide clear state information to VoiceOver users.

Provide a visible checkmark and highlighted background to indicate the selected state visually.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[MultiSelectionListView.swift](../iOSswiftUIa11yTechniques/MultiSelectionListView.swift)

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
