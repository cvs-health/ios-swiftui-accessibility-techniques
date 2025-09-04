# Decorative Images
Decorative images convey no information or meaning and must be hidden from VoiceOver users with the `decorative:` parameter or `.accessibilityHidden(true)`.

Decorative images should have no `.accessibilityLabel`. They only need to be hidden from VoiceOver focus. 

Notes:

* Decorative images created from files in your project can use the `decorative:` parameter but `systemName:` SF Symbols icon images need to use `.accessibilityHidden(true)`.

## Applicable WCAG Success Criteria
- [1.1.1: Non-text Content](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content)

## Swift Technique Source Code
[DecorativeView.swift](../iOSswiftUIa11yTechniques/DecorativeView.swift)

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

