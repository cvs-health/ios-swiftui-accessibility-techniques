# Buttons
Buttons need unique and specific label text or `.accessibilityLabel` that describes their function to VoiceOver users. 

Button states must be conveyed to VoiceOver users. Use `.disabled(true)` to set a disabled button.

Notes:

* When there are multiple buttons on a page with the same label modify each button's `.accessibilityLabel` so they are unique and specific when spoken to VoiceOver. 
* If overriding a button's `.accessibilityLabel` make sure to include the visible button text at the beginning of the `.accessibilityLabel`, e.g., `.accessibilityLabel("Edit Username")` for a button labeled "Edit".
* Don't include the word "Button" in an `.accessibilityLabel` or else VoiceOver will speak "Button, Button".

## Applicable WCAG Success Criteria
- [2.4.6: Headings and Labels](https://www.w3.org/WAI/WCAG22/Understanding/headings-and-labels)
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
