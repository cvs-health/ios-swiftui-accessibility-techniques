# Dynamic Type
Use Dynamic Type text styles so that text automatically scales to larger sizes when the user adjusts their iOS text size settings. iOS users must be able to increase the text size of the application without loss of content.

Use a `.font()` style like `.largeTitle`, `.caption`, `.headline`, `.subheadline`, etc. Or use text with no size defined and it will dynamically scale. 

Avoid using `.lineLimit()` which will cause text truncation.

Avoid using fixed sized text which does not scale.

Put `Text` inside a `ScrollView` so that it does not truncate when the size is increased.

Avoid using `HStack` with multiple links at large text sizes. 

Notes:

- Use `axis: .vertical` to enable `TextField` value text to expand vertically rather than truncate.

## Applicable WCAG Success Criteria
- [1.4.4: Resize Text](https://www.w3.org/WAI/WCAG21/Understanding/resize-text)

## Swift Technique Source Code
[DynamicTypeView.swift](../iOSswiftUIa11yTechniques/DynamicTypeView.swift)

----

Copyright 2023-2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

