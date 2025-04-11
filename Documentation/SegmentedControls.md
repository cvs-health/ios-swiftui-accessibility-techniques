# Segmented Controls
VoiceOver users need to hear the group label text spoken when they first focus on a segment in the segmented control. 

Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel("Group Label")` on the `Picker{}` to specify a segmented control group accessibility label for VoiceOver.

Limitations:

- Using `.accessibilityLabel` on the `Picker{}` will only work with VoiceOver if `.accessibilityElement(children: .contain)` is also used.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)

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
