# Tabs
Tabs show and hide content inside tab panels. VoiceOver users must hear the selected tab state. 

Use `TabView` to create native tab controls with selected state. Give each `TabView` a unique and meaningful `.accessibilityLabel`.

Notes:

* When using `.tabViewStyle(.page)` to create a `TabView` with page indicator dots make sure to add `.indexViewStyle(.page(backgroundDisplayMode: .always))` to display the page indicator dots with a background othwerwise they will be invisible in light mode.

## Applicable WCAG Success Criteria
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

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
