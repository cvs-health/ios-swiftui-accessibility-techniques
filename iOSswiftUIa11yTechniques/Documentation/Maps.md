# Maps
Maps require single tap alternatives to the pinch gestures used to zoom and the pan gestures used to move the map view. Provide accessible button controls for zooming in, zooming out, and panning in all directions so that users of assistive technologies can operate the map without complex gestures.

Use `.accessibilityLabel()` on each map control button to describe its function. Group related controls using `.accessibilityElement(children: .contain)` with a descriptive `.accessibilityLabel()` on the container.

## Applicable WCAG Success Criteria
- [2.1.1: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)
- [2.5.1: Pointer Gestures](https://www.w3.org/WAI/WCAG22/Understanding/pointer-gestures)

## Swift Technique Source Code
[MapView.swift](../iOSswiftUIa11yTechniques/MapView.swift)

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

