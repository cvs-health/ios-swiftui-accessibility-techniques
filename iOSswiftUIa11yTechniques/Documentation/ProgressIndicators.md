# Progress Indicators
Progress indicators are used to show page loading status or the progress of a task. 
- VoiceOver users must hear an accessibility label that matches the visible progress indicator label text. 
- The correct progress indicator value must be spoken to VoiceOver. 
- When a progress spinner is displayed its label text must be spoken to VoiceOver.

Create progress indicators with visible `ProgressView(\"Label\")` label text which then becomes the accessibility label for VoiceOver. 
 
Notes:

- Post an `AccessibilityNotification.Announcement` speaking the loading indicator text to VoiceOver when displaying page loading indicators.

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
