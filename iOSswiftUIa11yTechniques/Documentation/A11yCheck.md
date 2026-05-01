# A11y-check
`a11y-check` is a static analysis tool that scans SwiftUI source code for accessibility issues. It includes 31 rules across 17 WCAG 2.2 success criteria, with a 0–100 scoring system.

Run `a11y-check .` in your project folder to scan all Swift files for missing labels, incorrect traits, small touch targets, hardcoded colors, and more.

See the full [A11yAgent README](../../A11yAgent/README.md) for installation, CLI options, CI integration, and MCP server setup.

## Rules

### Images
- **`image-missing-label`** (error, WCAG 1.1.1) — `Image(systemName:)` or `Image("name")` missing `.accessibilityLabel()` and not using `Image(decorative:)` or `.accessibilityHidden(true)`.
- **`image-label-contains-role`** (warning, WCAG 1.1.1) — `.accessibilityLabel()` on an Image contains words like "image", "icon", "picture", or "photo". VoiceOver already announces the image role.

### Headings
- **`heading-trait-missing`** (warning, WCAG 2.4.6) — `Text` with a heading font style (`.title`, `.headline`, etc.) missing `.accessibilityAddTraits(.isHeader)`.
- **`fake-heading-in-label`** (error, WCAG 1.3.1) — `.accessibilityLabel()` contains the word "heading" to fake the announcement instead of using `.accessibilityAddTraits(.isHeader)`.

### Buttons
- **`button-label-contains-role`** (error, WCAG 4.1.2) — `Button` whose label contains the word "button". VoiceOver already announces the button role.
- **`icon-button-missing-label`** (error, WCAG 4.1.2) — `Button` containing only an `Image` with no `.accessibilityLabel()`.
- **`visually-disabled-not-semantic`** (error, WCAG 4.1.2) — `Button` with `.opacity()` or `.tint(.gray)` but no `.disabled(true)`. Appears disabled visually but assistive tech does not know it.

### Traits
- **`tap-gesture-missing-button-trait`** (error, WCAG 4.1.2) — View with `.onTapGesture` missing `.accessibilityAddTraits(.isButton)`. VoiceOver won't announce it as interactive.

### Toggles
- **`toggle-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Toggle` with an empty label or `.labelsHidden()` and no `.accessibilityLabel()`.

### Links
- **`button-used-as-link`** (error, WCAG 4.1.2) — `Button` whose action contains URL navigation (`openURL`, `UIApplication.shared.open`, etc.). Use `Link` instead.
- **`generic-link-text`** (error, WCAG 2.4.4) — `Link` with text like "Click here", "Read more", "Learn more", or "Tap here".

### Touch Targets
- **`small-touch-target`** (error, WCAG 2.5.8) — `Button` or `Image` with `.frame(width:height:)` where both dimensions are below 24pt.

### Dynamic Type
- **`fixed-font-size`** (error, WCAG 1.4.4) — `.font(.system(size: N))` uses a fixed size that does not scale with Dynamic Type.
- **`line-limit-1`** (error, WCAG 1.4.4) — `.lineLimit(1)` truncates text at larger Dynamic Type sizes.

### Page Titles
- **`missing-navigation-title`** (error, WCAG 2.4.2) — `NavigationStack` or `NavigationView` with no `.navigationTitle()` in its view hierarchy.

### Accessibility Hidden
- **`hidden-parent-with-controls`** (error, WCAG 4.1.2) — `.accessibilityHidden(true)` on a container view that has interactive children (`Button`, `Toggle`, `TextField`, etc.).

### Color Contrast
- **`color-contrast-insufficient`** (error, WCAG 1.4.3) — Computed contrast ratio below 4.5:1 for normal text or 3.0:1 for large text when both foreground and background colors are resolvable.
- **`hardcoded-color`** (info, WCAG 1.4.3) — `.foregroundColor(.black)`, `.foregroundColor(.white)`, or inline `Color(red:...)` that may not adapt to Dark Mode.

### Form Controls
- **`textfield-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `TextField` or `SecureField` with an empty placeholder or relying only on placeholder text as the accessible name.
- **`slider-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Slider` with no label and no `.accessibilityLabel()`.
- **`stepper-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Stepper` with an empty label and no `.accessibilityLabel()`.
- **`picker-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Picker` with an empty label and no `.accessibilityLabel()`.

### Focus
- **`sheet-focus-return`** (error, WCAG 2.4.3, 2.1.2) — `.sheet()`, `.fullScreenCover()`, `.alert()`, or `.popover()` with no focus state management on dismiss. VoiceOver focus is lost after dismissal.

### Animation
- **`animation-missing-reduce-motion`** (error, WCAG 2.3.1) — `.animation()` or `withAnimation` in a file that does not check `accessibilityReduceMotion` or `UIAccessibility.isReduceMotionEnabled`.
- **`tabview-missing-label`** (error, WCAG 4.1.2, 2.4.2) — Views inside a `TabView` that lack a `.tabItem` modifier.

### Input Purpose
- **`input-missing-purpose`** (error, WCAG 1.3.5) — `TextField` or `SecureField` without `.textContentType()`. Infers the expected content type from variable name, label, or placeholder.

### Gestures
- **`gesture-missing-alternative`** (error, WCAG 2.1.1, 2.5.1) — `.onLongPressGesture` or `.gesture(DragGesture() / RotationGesture() / etc.)` without an `.accessibilityAction()` alternative.

### Grouping
- **`missing-accessibility-grouping`** (info, WCAG 1.3.1) — `HStack` or `VStack` containing both `Image` and `Text` without `.accessibilityElement(children: .combine)`.
- **`zstack-order-confusing`** (info, WCAG 1.3.2) — `ZStack` with multiple interactive elements and no `accessibilitySortPriority` or `accessibilityElement` to control VoiceOver reading order.

### Timing
- **`auto-dismiss-no-control`** (error, WCAG 2.2.1) — `.task` or `.onAppear` containing `Task.sleep` or `asyncAfter` with a dismiss, without giving the user control to extend or pause.

### Label in Name
- **`label-in-name`** (error, WCAG 2.5.3) — `.accessibilityLabel()` does not contain the visible text. Speech input users who say what they see cannot activate the control.

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
