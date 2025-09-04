# Radio Buttons
There is no native radio button control for SwiftUI in iOS. 

Use another native control like a `Picker` which allows only one selection or mimic radio group behavior on the web with VoiceOver.

For example, create a custom radio button group out of `Button` elements and manually add and remove accessibility traits and values:
- Use `.accessibilityRemoveTraits(.isButton)` to remove the button trait.
- Use `.accessibilityAddTraits(isSelected.rawValue == title ? .isSelected : [])` to add a selected trait when checked.
- Use `.accessibilityRemoveTraits(isSelected.rawValue != title ? .isSelected : [])` to remove the selected trait when unchecked.
- Use `.accessibilityValue(isSelected.rawValue == title ? Text("Radio button, checked") : Text("Radio button, unchecked"))` to add a fake radio button trait and a checked and unchecked state.
- Additionally use `.accessibilityElement(children: .contain)` and `.accessibilityLabel("Choose Color")` to give the radio group a label for VoiceOver.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[RadioButtonsView.swift](../iOSswiftUIa11yTechniques/RadioButtonsView.swift)

----

Copyright 2024 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

