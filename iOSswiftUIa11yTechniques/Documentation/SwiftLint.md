# SwiftLint
SwiftLint can be used to lint your code for accessibility issues by turning on the two opt-in accessibility rules, `accessibility_label_for_image` and `accessibility_trait_for_button`. You can enable these rules by editing your project's `.swiftlint.yml` file to include them in the `opt_in_rules` list. 
See the post [iOS Automation Accessibility testing at Reddit](https://www.reddit.com/r/RedditEng/comments/1lzrsg9/ios_automation_accessibility_testing_at_reddit/) to learn more.

## Applicable WCAG Success Criteria
- [1.1.1: Non-text Content](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[SwiftLintView.swift](../iOSswiftUIa11yTechniques/SwiftLintView.swift)

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

