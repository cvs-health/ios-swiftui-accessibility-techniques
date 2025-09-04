# Language
Parts of the app or page that are in a different language than the main language must be spoken to VoiceOver users in the correct speech synthesizer, i.e., Spanish text must be spoken in a Spanish synthesizer with the correct accent and pronunciations.

Use an `AttributedString` with `attributes: AttributeContainer().languageIdentifier()` on the different language text so VoiceOver speaks it correctly with a proper accent for that language.

## Applicable WCAG Success Criteria
- [3.1.1 Language of Page](https://www.w3.org/WAI/WCAG22/Understanding/language-of-page)
- [3.1.2 Language of Parts](https://www.w3.org/WAI/WCAG22/Understanding/language-of-parts)

## Swift Technique Source Code
[LanguageView.swift](../iOSswiftUIa11yTechniques/LanguageView.swift)

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

