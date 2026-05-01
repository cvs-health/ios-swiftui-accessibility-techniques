# Contrast
Text must have a contrast ratio of at least 4.5:1 against its background. Large text (18pt+ or 14pt+ bold) requires at least 3:1. Non-text UI components like borders, icons, and controls require at least 3:1 contrast against adjacent colors.

Use semantic SwiftUI colors like `.primary` and `.secondary` which automatically adapt to light and dark mode. Avoid hardcoded colors like `Color.black` or `Color.white` which do not adjust to the current color scheme and may become invisible in the opposite mode.

Notes:
- `.foregroundColor(.primary)` provides maximum contrast in both light and dark mode.
- `.foregroundColor(.secondary)` meets 4.5:1 for normal text and 3:1 for large text in most configurations.
- `.buttonStyle(.borderedProminent)` creates a filled button with sufficient contrast.
- `.textFieldStyle(.roundedBorder)` provides a visible border meeting 3:1 non-text contrast.
- Hardcoded gray values like `Color(red: 0.7, green: 0.7, blue: 0.7)` typically fail contrast requirements on white backgrounds.

## Applicable WCAG Success Criteria
- [1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)
- [1.4.11 Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast)

## Swift Technique Source Code
[ContrastView.swift](../iOSswiftUIa11yTechniques/ContrastView.swift)

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
