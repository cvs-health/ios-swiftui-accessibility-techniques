# Accessibility Value
Use `.accessibilityValue` to convey the current value or state of a control to VoiceOver users. The value describes the current state (e.g., "3 out of 5", "Step 2 of 4", "enabled"), not the label or action.

Use `.accessibilityValue` for custom controls that have a changeable state or value that SwiftUI does not automatically communicate to VoiceOver. Native controls like `Slider`, `Toggle`, and `Stepper` provide their own values automatically.

Notes:
- Update the value dynamically as the state changes so VoiceOver always reflects the current state.
- For adjustable controls, combine `.accessibilityValue` with `.accessibilityAdjustableAction` to allow VoiceOver users to change the value by swiping up and down.

## Applicable WCAG Success Criteria
- [4.1.2 Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)


## Apple Developer Documentation
- [View/accessibilityValue(_:)](https://developer.apple.com/documentation/swiftui/view/accessibilityvalue(_:))

## Swift Technique Source Code
[AccessibilityValueView.swift](../iOSswiftUIa11yTechniques/AccessibilityValueView.swift)

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
