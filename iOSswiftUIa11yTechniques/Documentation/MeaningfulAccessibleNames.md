# Meaningful Accessible Names

Accessible names of UI controls must be meaningful when spoken to VoiceOver users. 

Use unique and specific label text to create meaningful accessible names for VoiceOver users. 

Use a unique and specific `.accessibilityLabel` if the visible label text does not meaningfully describe its specific function. 

Notes:
- If modifying the accessible name of a control, make sure to add the visible label text at the beginning of the `.accessibilityLabel`.

## Applicable WCAG Success Criteria
- [2.5.3 Label in Name](https://www.w3.org/WAI/WCAG22/Understanding/label-in-name)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[MeaningfulAccessibleNamesView.swift](../iOSswiftUIa11yTechniques/MeaningfulAccessibleNamesView.swift)

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

