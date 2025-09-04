# Reduce Transparency
Make sure that text and non-text content has sufficient contrast in the default presentation of your app. 

You can also enhance the contrast of the UI if the user enables Reduce Transparency in their Accessibility Settings. 

- Use `@Environment(\.accessibilityReduceTransparency)` to check if the user has enabled Reduce Transparency and then reduce the transparency of design elements with low opacity to enhance contrast of the UI.

## Applicable WCAG Success Criteria
- [1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)
- [1.4.6 Contrast (Enhanced)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-enhanced)
- [1.4.11 Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast)

## Swift Technique Source Code
[ReduceTransparencyView.swift](../iOSswiftUIa11yTechniques/ReduceTransparencyView.swift)

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

