# Headings
Heading and subheading text must be given the header trait using `.accessibilityAddTraits(.isHeader)` which allows VoiceOver users to quickly navigate between headings using the Rotor.

Additionally if you want to provide a level for the heading use `.accessibilityHeading(.h1)` or `(.h2-h6)` with the `.accessibilityAddTraits(.isHeader)`. 

When using heading levels make sure the headings do not skip a level, e.g., don't skip from a Heading Level 1 to a Heading Level 3.

Notes:

* Never use `.accessibilityLabel` to append an accessibility property like "Heading" to make a fake heading. It may sound almost correct in VoiceOver, but it will not work to navigate to the heading with the Rotor.
* Adding a heading level using `.accessibilityHeading(.h1)`, `.accessibilityHeading(.h2)`, etc. will not work unless `.accessibilityAddTraits(.isHeader)` is also added then the level will be spoken to VoiceOver.

Known Issues:
* You can't make the Page Title heading have a heading level. For example using `.navigationTitle("Headings").accessibilityAddTraits(.isHeader).accessibilityHeading(.h1)` will not make the page title a Heading Level 1.

Platform Defects:
- [AX: SwiftUI .accessibilityHeading(.h1-6,.unspecified) do not speak as Heading or Heading with Level to VoiceOver](https://feedbackassistant.apple.com/feedback/13723717)


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
