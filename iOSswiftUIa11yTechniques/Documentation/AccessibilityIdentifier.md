# Accessibility Identifier
Use `.accessibilityIdentifier()` to specify a unique string identifier for UI Testing purposes. Accessibility Identifiers are not spoken to VoiceOver users and should not be used as a substitute for `.accessibilityLabel()`.

Don't use `.accessibilityIdentifier()` to try to label elements for assistive technology users. Use `.accessibilityLabel()` instead to provide a descriptive label that VoiceOver will speak.

## Applicable WCAG Success Criteria
N/A - This is a UI Testing technique, not an accessibility requirement.

## Swift Technique Source Code
[AccessibilityIdentifier.swift](../iOSswiftUIa11yTechniques/AccessibilityIdentifier.swift)

----

Copyright 2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

