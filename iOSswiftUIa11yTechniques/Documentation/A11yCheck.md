# a11y-check
`a11y-check` is a static analysis tool that scans SwiftUI source code for accessibility issues. It includes 31 rules across 17 WCAG 2.2 success criteria, with a 0–100 scoring system.

Run `a11y-check .` in your project folder to scan all Swift files for missing labels, incorrect traits, small touch targets, hardcoded colors, and more.

Rules cover images, headings, buttons, traits, toggles, links, touch targets, dynamic type, page titles, accessibility hidden, color contrast, form controls, focus management, animation, input purpose, gestures, grouping, timing, and label in name.

See the full [A11yAgent README](../../A11yAgent/README.md) for installation, CLI options, CI integration, and MCP server setup.

## Applicable WCAG Success Criteria
- [1.1.1: Non-text Content](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content)
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [1.3.2: Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)
- [1.3.5: Identify Input Purpose](https://www.w3.org/WAI/WCAG22/Understanding/identify-input-purpose)
- [1.4.3: Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)
- [1.4.4: Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text)
- [2.1.1: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)
- [2.2.1: Timing Adjustable](https://www.w3.org/WAI/WCAG22/Understanding/timing-adjustable)
- [2.3.1: Three Flashes or Below Threshold](https://www.w3.org/WAI/WCAG22/Understanding/three-flashes-or-below-threshold)
- [2.4.2: Page Titled](https://www.w3.org/WAI/WCAG22/Understanding/page-titled)
- [2.4.3: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)
- [2.4.4: Link Purpose (In Context)](https://www.w3.org/WAI/WCAG22/Understanding/link-purpose-in-context)
- [2.4.6: Headings and Labels](https://www.w3.org/WAI/WCAG22/Understanding/headings-and-labels)
- [2.5.1: Pointer Gestures](https://www.w3.org/WAI/WCAG22/Understanding/pointer-gestures)
- [2.5.3: Label in Name](https://www.w3.org/WAI/WCAG22/Understanding/label-in-name)
- [2.5.8: Target Size (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum)
- [3.3.2: Labels or Instructions](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value)

## Swift Technique Source Code
[A11yCheckView.swift](../iOSswiftUIa11yTechniques/A11yCheckView.swift)

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
