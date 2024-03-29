# Alerts
VoiceOver focus must move to the alert when displayed and back to the trigger button when the alert is closed.

Use `.alert()` to code a native SwiftUI alert that receives VoiceOver focus when opened. 

Use `AccessibilityFocusState` to send focus back to the trigger button that opened the alert when the alert is closed.

Platform Defects:
- Alert button text does not have sufficient contrast ratios.
- Alerts will not automatically send focus back to the trigger button and this could be considered an accessibility defect in Apple's native `.alert()` component in which case bugs should be filed with Apple.
- Native SwiftUI Alerts will not have their heading text spoken as a Heading to VoiceOver users and this could be considered an accessibility defect in Apple's native `.alert()` component in which case bugs should be filed with Apple.

    
## Applicable WCAG Success Criteria
- [2.4.3 Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)

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
