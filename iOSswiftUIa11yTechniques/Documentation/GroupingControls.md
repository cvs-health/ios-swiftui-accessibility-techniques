# Grouping Controls

VoiceOver users need to hear the group label text spoken when they first focus on a control in a group of related controls. 

Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel("Group Label")` on the group container.

Warning:

- Using `.accessibilityLabel` on the group container without also using `.accessibilityElement(children: .contain)` will incorrectly override the visible label text of the controls inside the group and lead to a Label in Name failure.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [2.5.3: Label in Name](https://www.w3.org/WAI/WCAG22/Understanding/label-in-name)

## Swift Technique Source Code
[GroupingControlsView.swift](../iOSswiftUIa11yTechniques/GroupingControlsView.swift)

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

