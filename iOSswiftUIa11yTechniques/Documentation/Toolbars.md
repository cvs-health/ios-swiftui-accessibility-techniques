# Toolbars
Toolbar image buttons need meaningful `Label` or `.accessibilityLabel` text that describes their purpose to VoiceOver users and shows a useful name to Voice Control users. 

`Label` text will display in the Large Content Viewer automatically but if using `.accessibilityLabel` you will need to manually add `.accessibilityShowsLargeContentViewer` to make the label text visible in the Large Content Viewer. 

An `.accessibilityHint` text can be added if necessary to describe what happens when a VoiceOver user activates the button.

## Applicable WCAG Success Criteria
- [1.4.4: Resize Text](https://www.w3.org/WAI/WCAG21/Understanding/resize-text)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[ToolbarView.swift](../iOSswiftUIa11yTechniques/ToolbarView.swift)

----

Copyright 2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

