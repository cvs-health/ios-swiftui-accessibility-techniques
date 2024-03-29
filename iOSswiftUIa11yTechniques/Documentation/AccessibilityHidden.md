# Accessibility Hidden
Use `.accessibilityHidden(true)` to hide decorative content or repetitive text from VoiceOver, Voice Control, Full Keyboard Access, and Switch Control users. 

Don't use `.accessibilityHidden(true)` on any informative content or UI controls. 

Don't use `.accessibilityHidden(true)` on any parent view containers that hold informative or functional content because all child elements will be hidden.

## Applicable WCAG Success Criteria
- [1.3.2 Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

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
