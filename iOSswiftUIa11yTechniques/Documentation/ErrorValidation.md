# Error Validation

Error validation is used to convey error messages for missing or incorrectly entered data. VoiceOver users must hear an error message spoken when submitting a form with invalid data and when focused on invalid inputs.

* Use [`AccessibilityFocusState`](https://developer.apple.com/documentation/swiftui/accessibilityfocusstate) to move VoiceOver focus to the first invalid input or error text when submitting a form with invalid data. 
* Use an `.accessibilityHint` matching the visible error message text for each invalid input.
  * Or use an `.accessibilityValue` matching the input value plus the visible error message text for each invalid input.
* Visually indicate required fields e.g. with an \* and explain the meaning of the \*.

Notes:

* Make sure error messages are meaningful and specific. 
* Don't rely on color as the only method of indicating errors. 
* If you do use `.accessibilityValue` to include the error message then don't forget to add the visible value text back into the `.accessibilityValue` or it will be overriden and VoiceOver will never speak the visible input value text.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [3.3.1: Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification)
- [3.3.3: Error Suggestion](https://www.w3.org/WAI/WCAG22/Understanding/error-suggestion)

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
