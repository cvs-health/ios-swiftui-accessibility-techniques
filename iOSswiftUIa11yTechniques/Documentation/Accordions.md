# Accordions
Accordion controls expand and collapse to show and hide content. VoiceOver users must hear the "Expanded" and "Collapsed" state of accordions.

Use `DisclosureGroup` to create an accessible accordion with expanded and collapsed states for VoiceOver. 

Use `DisclosureGroupStyle` to create a custom accordion style using the native `DisclosureGroup`. 

Known Issues:

* Don't use an `.accessibilityLabel` on a `DisclosureGroup` because it will override all text inside the expanded accordion and only the `.accessibilityLabel` will be spoken to VoiceOver. Instead use `.accessibilityHint` if you want to add unique text to repeating `DisclosureGroup` accordions.

## Applicable WCAG Success Criteria
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

----

Copyright 2023-2024 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
