# Accessibility Notifications
Accessibility Notifications are used to speak announcements to VoiceOver users without moving their focus. VoiceOver users must hear dynamic status messages spoken when they appear on the page.

Post an `AccessibilityNotification.Announcement` when you want to speak an announcement to VoiceOver.

Notes:

- Use a delay to make sure VoiceOver correctly speaks the announcement message, e.g. `DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)` 

## Applicable WCAG Success Criteria
- [4.1.3: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages)

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
