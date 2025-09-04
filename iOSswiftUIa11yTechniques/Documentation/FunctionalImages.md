# Functional Images
Functional images are used as operable controls like buttons or links and need an `.accessibilityLabel` that describes their function to VoiceOver users.

The `.accessibilityLabel` of a functional image should not describe what an image looks like, intead, it should describe its function. 

Notes:

* Functional images should not include the word "Image" or "Icon" in the `.accessibilityLabel` as that does not describe the function of the control.

## Applicable WCAG Success Criteria
- [1.1.1: Non-text Content](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[FunctionalView.swift](../iOSswiftUIa11yTechniques/FunctionalView.swift)

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

