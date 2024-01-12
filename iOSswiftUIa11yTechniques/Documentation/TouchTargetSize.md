# Touch Target Size

WCAG 2.2 requires a minimum touch target size (or spacing) of at least 24 by 24. 

Inline targets (within a line of text) are exempt from the minimum target size requirements. 

Use `.frame(minWidth: 24, minHeight: 24)` on icon button `Image` elements to ensure the 24 by 24 target minimum is met.

Notes:

- Xcode Accessibility Inspector and `.performAccessibilityAudit()` test for 44 by 44 minimum size which is a WCAG 2.1 Level AAA success criterion.
    
## Applicable WCAG Success Criteria
- [2.5.8 Target Size (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum)

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
