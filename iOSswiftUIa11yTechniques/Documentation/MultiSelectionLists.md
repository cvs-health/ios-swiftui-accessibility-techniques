# Multi-Selection Lists
Multi-selection lists allow users to select multiple items from a list. Native `List` views automatically provide the selected trait to VoiceOver.

When building custom list views with `ForEach`, use `.accessibilityAddTraits(.isSelected)` on selected items so VoiceOver announces the selected state.

Use `.accessibilityValue("Not Selected")` only when unselected, since there is no "not selected" trait.

Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel("Group Label")` on the list container so VoiceOver users hear the group label when first moving focus into the list.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)


## Apple Developer Documentation
- [List](https://developer.apple.com/documentation/swiftui/list)
- [View/accessibilityAddTraits(_:)](https://developer.apple.com/documentation/swiftui/view/accessibilityaddtraits(_:))

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
