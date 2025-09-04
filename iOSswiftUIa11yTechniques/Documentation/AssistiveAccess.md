# Assistive Access
Assistive Access simplifies the iOS experience for users with cognitive disabilities. 

Use `UISupportsFullScreenInAssistiveAccess` for the app to appear as full screen in Assistive Access. 

Add the "Supports full screen in Assistive Access" Boolean property with the value `YES` to your `Info.plist` which is: `<key>UISupportsFullScreenInAssistiveAccess</key>` `<true/>` if editing the `Info.plist` source code. 

Do not used fixed screen sizes in the app.

Notes:
- To learn more about supporting Assistive Access in your app, visit the [`UISupportsFullScreenInAssistiveAccess`](https://developer.apple.com/documentation/bundleresources/information_property_list/uisupportsfullscreeninassistiveaccess) Apple Developer Documentation page.

## Applicable WCAG Success Criteria
- N/A

## Swift Technique Source Code
[AssistiveAccessView.swift](../iOSswiftUIa11yTechniques/AssistiveAccessView.swift)

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

