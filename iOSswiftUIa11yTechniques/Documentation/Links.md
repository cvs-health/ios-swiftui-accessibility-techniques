# Links
Links need unique and specific label text or `.accessibilityLabel` that describes their purpose to VoiceOver users. 

Links must be underlined (or have other visual distinction) when placed inline with static text. Use `.underline()` to underline inline links.

Choose an `AccentColor` with sufficient contrast for light and dark appearance in the assets catalog `Assets.xcassets` file.

Notes:

* The default color contrast ratio of links is not sufficient for WCAG. Modify the link text color to have at least a 4.5:1 contrast ratio, e.g., using `AccentColor` or using `.tint(Color(red: 0.0, green: 0.0, blue: 1.0))` to make the links dark blue with sufficient contrast.
* By default links in SwiftUI include a Button trait which must be removed using `.accessibilityRemoveTraits(.isButton)` or else VoiceOver will speak \"Button, Link\".

Platform Defects:

- `AttributedString` inline links and Markdown inline links are not keyboard focusable or operable when using Full Keyboard Access and do not work with Voice Control's Show Numbers or Show Names tooltips. This is a bug in Apple's native link controls and bug reports should be filed with Apple. The only way to ensure links are operable with full keyboard access would be to avoid using inline links until Apple fixes the bug.
- Markdown links cannot be underlined or made bold to have a different text style than their surrounding inline text.

## Applicable WCAG Success Criteria
- [1.4.1: Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color)
- [2.4.4: Link Purpose (In Context)](https://www.w3.org/WAI/WCAG22/Understanding/link-purpose-in-context)
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
