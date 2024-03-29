# Date & Time Pickers
Date Pickers are used to select dates and times. VoiceOver users need to hear the visible label text spoken when focused on the date picker. 

Date Pickers without the `.graphical` or `.wheel` style need an `.accessibilityLabel` set to match their visible label text. 

Date Pickers with the `.graphical` or `.wheel` style need visible `DatePicker("Label")` text for each date picker so it is spoken to VoiceOver as the accessibility label.

Limitations:

- The visible `DatePicker` label text will not automatically become the accessibility label for VoiceOver and will need a `.accessibilityLabel` manually applied.
  - `DatePicker` with `.graphical` or `.wheel` style does not need the extra `.accessibilityLabel` manually applied or else both the visible label and the accessibility will be spoken.
  
 Platform Defects:
- Wheel style Pickers do not have sufficient text contrast for their non-selected options.
- Date Pickers do not have sufficient contrast for their (S, M, T, W, T, F, S) column header text.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
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
