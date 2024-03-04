# Cards

Cards need a heading as the first focused element with VoiceOver. 

Card call to action button or link needs to be unique and specific when spoken to VoiceOver users and may require an `.accessibilityLabel`. 

Cards with many actions can be combined as one focusable element by wrapping the card in a `NavigationLink` or using `.accessibilityElement(children: .combine)` and any actions missing when combined can be included using `.accessibilityAction`.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)
- [2.4.6: Headings and Labels](https://www.w3.org/WAI/WCAG22/Understanding/headings-and-labels)

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
