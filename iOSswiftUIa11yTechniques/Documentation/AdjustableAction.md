# Adjustable Action

Use `.accessibilityAdjustableAction` to enable VoiceOver users to adjust an incrementable control like a custom star rating widget. 

With `.accessibilityAdjustableAction` VoiceOver users can swipe up or down to increment and decrement the adjustable control's value.

Notes:

- `.accessibilityElement()`, `.accessibilityLabel`, and `.accessibilityValue` are also needed to make a custom control accessible.
- Native SwiftUI controls like `Slider` have their Adjustable Action included by default for VoiceOver users and don't need extra code.

## Applicable WCAG Success Criteria
- [4.1.2 Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value)

## Swift Technique Source Code
[AdjustableActionView.swift](../iOSswiftUIa11yTechniques/AdjustableActionView.swift)

----

Copyright 2023-2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

