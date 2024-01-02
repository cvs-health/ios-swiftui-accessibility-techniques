# Focus Management
VoiceOver focus must move to custom dialogs or views when displayed and back to the trigger button when the custom dialog or view is closed.

Focus Management is required when displaying custom dialogs or views. Use `.accessibilityFocused` to move VoiceOver focus when opening and closing custom dialogs or views. 

Use `AccessibilityFocusState` to send focus back to the trigger button that opened the custom dialog or view when it is closed.

Notes:

- Use `.accessibilityAddTraits(.isModal)` to trap VoiceOver focus inside a custom modal dialog.
    
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
