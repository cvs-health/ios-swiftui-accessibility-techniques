# Combining Focus

Use `.accessibilityElement(children: .combine)` to combine child views into a parent view focused by VoiceOver as a single element. 

When combining child elements their accessibility properties may not all transfer into the combined view as expected. 

If a child `Button` is combined into a parent element the button's accessibility label will not transfer unless the `.isButton` trait is removed. 

If important traits are removed in the child elements make sure to add them back to the combined accessibility element.

## Applicable WCAG Success Criteria
- [1.3.2 Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)

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
