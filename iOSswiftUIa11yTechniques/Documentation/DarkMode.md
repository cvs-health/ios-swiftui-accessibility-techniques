# Dark Mode
Dark Mode improves readability for users with visual impairments and for users when reading at night or in low light conditions.

Make sure that text and non-text content has sufficient contrast in both light and dark mode. 

Use `@Environment(\.colorScheme)` to check if the user is in dark or light mode and then adjust the colors to meet contrast requirements for both modes.

Notes:
- Choose an `AccentColor` with sufficient contrast for light and dark appearance in the assets catalog `Assets.xcassets` file.

## Applicable WCAG Success Criteria
- [1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)

## Swift Technique Source Code
[DarkModeView.swift](../iOSswiftUIa11yTechniques/DarkModeView.swift)

----

Copyright 2024-2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

