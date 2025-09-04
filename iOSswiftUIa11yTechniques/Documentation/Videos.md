# Videos
Videos need Closed Captions for deaf users and Audio Descriptions for blind users. 
Provide a closed caption track on the video and an audio description track that users can select. Or provide a captioned video and a separate audio-described video. 

Apple's native video player controls are not accessible to VoiceOver, Full Keyboard Access, and other accessibility users because they are hidden by default and a user must tap the video to show the controls. 

- Create a custom play button so that accessibility users can focus on the button and use it to play the video. 
- Use `.accessibilityElement(children: .contain)` to create a group container for the video and for the custom play controls. 
- Add `.accessibilityLabel("Name of Video")` and VoiceOver users will hear the video name if using direct touch. 
- Add `.accessibilityHint("Plays video and shows controls")` so VoiceOver users hear how to play the video. 

Swipe exploration with VoiceOver will not work so the custom play button is required. 

Full Keyboard Access users have no method to show the native player controls, only the custom play button is keyboard accessible.

Platform Defects:
- Feedback Assistant: [FB15583041 - Video Player Controls Not Keyboard or VoiceOver Operable Once Hidden](https://feedbackassistant.apple.com/feedback/15583041)


## Applicable WCAG Success Criteria
- [1.1.1: Non-text Content](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content)
- [2.1.1: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)

## Swift Technique Source Code
[VideosView.swift](../iOSswiftUIa11yTechniques/VideosView.swift)

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

