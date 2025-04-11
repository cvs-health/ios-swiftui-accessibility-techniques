# Reading Order

The VoiceOver reading order should match the visual reading order presented to sighted users. 

If the visual layout of a page disrupts the expected VoiceOver reading order then use `.accessibilityElement(children: .contain)` to make VoiceOver read all elements in the group before moving to the next element.

Notes:

- By default the VoiceOver reading order moves from left to right and then top to bottom.
- Only add extra code to control the VoiceOver reading order if the layout is structured in a way that it disrupts the expected reading order.

## Applicable WCAG Success Criteria
- [1.3.2 Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)

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
