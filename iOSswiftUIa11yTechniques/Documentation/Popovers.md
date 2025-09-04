# Popovers

VoiceOver focus must move to the popover when displayed and back to the trigger button when the popover is closed. 

Popover title text must be coded as a Heading for VoiceOver users. 

Use `.popover()` to code a native SwiftUI popover that receives VoiceOver focus when opened. 

Use `AccessibilityFocusState` to send focus back to the trigger button that opened the popover when the popover is closed.

Place the popover's content inside a `ScrollView` or else the text will truncate when enlarged.      

Bugs:

- Popovers will not automatically send focus back to the trigger button and this could be considered an accessibility defect in Apple's native `.popover()` component in which case bugs should be filed with Apple.
    
## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)
- [2.4.3 Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)

## Swift Technique Source Code
[PopoversView.swift](../iOSswiftUIa11yTechniques/PopoversView.swift)

----

Copyright 2024-2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

