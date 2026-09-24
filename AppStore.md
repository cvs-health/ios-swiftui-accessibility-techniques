# App Store Listing

Copy-paste source for the App Store Connect fields for **Accessibility Techniques** ([App Store listing](https://apps.apple.com/app/accessibility-techniques/id6474141089)).

App Store fields do not render Markdown. The blocks below are plain text — paste them exactly as they appear.

## App Name

```text
Accessibility Techniques
```

## Description

```text
Learn how to build accessible iOS apps by seeing the same component done right and done wrong, side by side.

Accessibility Techniques is a working reference of 89 SwiftUI techniques. Every one ships a good and a bad example you can test yourself with VoiceOver turned on, so you hear the difference a proper accessibility label makes and what breaks when focus is not managed. Each technique maps to the WCAG 2.2 success criteria it satisfies.

What's inside
• 89 techniques in a searchable, alphabetical index
• Good and bad examples side by side, each with a Details note explaining exactly why it passes or fails
• Coverage of VoiceOver, Voice Control, Dynamic Type, Dark Mode, Reduce Motion, Increase Contrast, Smart Invert, and more
• Written documentation for every technique, linked to the relevant WCAG criteria and Apple's developer docs
• A companion watchOS app

Who it's for
Developers, designers, and QA who need to settle a question quickly, verify a real VoiceOver announcement before shipping, or show a teammate why a pattern fails.

Open source
The full SwiftUI source is on GitHub, so you can read how each example is built and copy what you need. The project also includes a11y-check, a free static analysis tool that scans your own Swift code for accessibility issues — 44 rules across 23 WCAG 2.2 criteria.

https://github.com/cvs-health/ios-swiftui-accessibility-techniques

Issues, suggestions, and contributions welcome.
```

## What's New

Release notes live with the release they describe, in [CHANGELOG.md](CHANGELOG.md) under that version's **App Store Release Notes** heading, so each release has a single source of truth. The current release is `[iOS 26.7]`.

## Keeping this accurate

Two numbers in the description have to be maintained by hand:

| Claim | Source of truth | Current |
| --- | --- | --- |
| techniques | entries in `iOSswiftUIa11yTechniques/iOSswiftUIa11yTechniques/Techniques.swift` | 89 |
| a11y-check rules and criteria | `a11y-check` rule registry, also quoted in [README.md](README.md) | 44 rules, 23 criteria |

Check both before submitting. The previous listing claimed 76 techniques for several releases after the count had moved on.

## Wording choices

- **Title Case headings, not ALL CAPS.** Some screen reader verbosity settings spell short all-caps strings out letter by letter, which reads badly on an accessibility app's own listing.
- **"WCAG 2.2", not bare "WCAG"**, matching what the techniques actually map to.
- **The opening line carries the pitch.** Only the first two or three lines show before the "more" link, so they describe what makes the app useful rather than what format it takes.

## Fields not currently set

The listing has no **subtitle** (30 characters) or **promotional text** (170 characters). Both are optional, and promotional text can be changed without submitting a new build.

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
