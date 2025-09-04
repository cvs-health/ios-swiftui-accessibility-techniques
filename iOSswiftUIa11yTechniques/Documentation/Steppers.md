# Steppers
Steppers are used to increase or decrease incremental values. VoiceOver users need to hear the visible label text spoken as the accessibility label when they focus on the stepper. 

Use internal `Stepper` `Text(\"Label\")` to create a visible label that becomes the accessibility label for VoiceOver users.

Notes:

- Manually applying a `.accessibilityLabel` is not necessary for a `Stepper` because the internal label text becomes the accessibility label for VoiceOver.

Platform Defects:
- Steppers do not support Large Content Viewer.



## Applicable WCAG Success Criteria
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[SteppersView.swift](../iOSswiftUIa11yTechniques/SteppersView.swift)

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
