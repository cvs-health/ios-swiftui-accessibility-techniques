# Headings
Heading and subheading text must be given the header trait using `.accessibilityAddTraits(.isHeader)` which allows VoiceOver users to quickly navigate between headings using the Rotor.

Notes:

* Never use `.accessibilityLabel` to append an accessibility property like "Heading" to make a fake heading. It may sound almost correct in VoiceOver, but it will not work to navigate to the heading with the Rotor.
* Native iOS apps do not have working heading levels yet. Apple has added new SwiftUI code to specify a heading level using `.accessibilityHeading(.h1)`, `.accessibilityHeading(.h2)`, etc. and there is a `.unspecified` value for a heading without a level, however, this new `.accessibilityHeading` property has no effect on VoiceOver and the heading levels are not spoken. Currently only `.accessibilityAddTraits(.isHeader)` works to create a heading with no level for VoiceOver users.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)

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
