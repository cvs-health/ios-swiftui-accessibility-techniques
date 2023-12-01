# Toggles
Toggles are used to switch between two options (also called switch controls). VoiceOver users must hear the \"On\" and \"Off\" state of toggles.

Use `Toggle` to create native toggle controls with an \"On\" and \"Off\" state. 

Use `Toggle(\"Label Text\")` to give the toggle a visible label and accessibility label. 

Notes:
- If there is no unique `Toggle(\"Label Text\")` then the toggle must have a unique and specific `.accessibilityLabel`. 
- Set the correct `.accessibilityValue` if the toggle has visible value text other than On and Off.
- In XCUITesting use `.switches` to select a `Toggle` as `.toggles` does not work.

## Applicable WCAG Success Criteria
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

----

Copyright 2023 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
