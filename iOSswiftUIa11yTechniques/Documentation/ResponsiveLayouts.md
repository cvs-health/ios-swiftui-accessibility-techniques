# Responsive Layouts
Use size classes to create layouts that respond to the user's screen size and device orientation to present a more usable view. Make sure that text is readable in both landscape and portrait orientations without truncation or requiring horizontal scrolling.

Use `horizontalSizeClass` and `verticalSizeClass` environment values to switch between `HStack` and `VStack` layouts depending on available space. Avoid forcing content into a fixed horizontal layout that causes truncation or illegible text on smaller screens.

## Applicable WCAG Success Criteria
- [1.3.4: Orientation](https://www.w3.org/WAI/WCAG22/Understanding/orientation)
- [1.4.4: Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text)
- [1.4.10: Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow)


## Apple Developer Documentation
- [ViewThatFits](https://developer.apple.com/documentation/swiftui/viewthatfits)
- [GeometryReader](https://developer.apple.com/documentation/swiftui/geometryreader)

## Swift Technique Source Code
[ResponsiveLayoutsView.swift](../iOSswiftUIa11yTechniques/ResponsiveLayoutsView.swift)

----

Copyright 2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

