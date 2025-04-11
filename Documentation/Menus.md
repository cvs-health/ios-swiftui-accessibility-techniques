# Menus

VoiceOver focus must move to the menu when opened. 

Use `Menu` to code a native SwiftUI menu that receives VoiceOver focus when opened. 

SwiftUI native `Menu` does not return focus back to the trigger button when closed. 

Platform Defects:

- It is not possible to return focus using `AccessibilityFocusState` as you can with a `.sheet()` or `.popover()`. This can be considered a defect in the native `Menu` component and bugs should be filed with Apple.
- `Menu` with `Section` `header` text and `.destructive` `Button` text have insufficient contrast. 
- `Menu` `Section` `header` text is missing a heading trait.
    
## Applicable WCAG Success Criteria
- [2.4.3 Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)

----

Copyright 2024 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
