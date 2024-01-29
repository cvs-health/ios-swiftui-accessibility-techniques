# Text Fields
Text fields require visible label text next to the field which must be set as the `.accessibilityLabel` of the `TextField`. 

VoiceOver users must hear the label text spoken when focused on the text field.

Don't use placeholder text which has insufficient contrast and disappears after the user enters a value. 

Notes:

* Use `.textFieldStyle(.roundedBorder)` to make the `TextField` visually identifiable. 
* Use `.border(.secondary)` to give the border a 3:1 contrast ratio in light and dark mode. 
* Use `.keyboardType` to specify the keyboard displayed on input. 
* Use `.textContentType` to enable form AutoFill for each `TextField`.

VoiceOver Bugs:
- VoiceOver operation is blocked when using `LabeledContent` with a `TextField` because VoiceOver users cannot double tap to activate the TextField and enter a value. Bug reports should be filed with Apple. 

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [3.3.2: Labels or Instructions](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions)
- [1.3.5: Identify Input Purpose](https://www.w3.org/WAI/WCAG22/Understanding/identify-input-purpose)

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
