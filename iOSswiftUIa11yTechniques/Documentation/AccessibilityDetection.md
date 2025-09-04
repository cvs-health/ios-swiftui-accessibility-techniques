# Accessibility Detection
Detecting accessibility features running on a user's device is not recommended because it may lead to creating unequal experiences between all users. 

However, sometimes it may be necessary to detect if an assistive technology is running, for example, if you need to provide a specific message to VoiceOver users only.
                
For example you could use `UIAccessibility.isVoiceOverRunning` to check if VoiceOver is running when the page loads and then show an alert reminding the VoiceOver user not to disable VoiceOver Hints. 

Notes:
- All of the iOS assistive technologies can be detected, i.e., using `UIAccessibility.is{AccessibilityFeature}Running` and replacing `{AccessibilityFeature}` with the name of the assistive technology you're detecting.

## Applicable WCAG Success Criteria
- N/A

## Swift Technique Source Code
[ATdetectionView.swift](../iOSswiftUIa11yTechniques/AccessibilityDetectionView.swift)

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

