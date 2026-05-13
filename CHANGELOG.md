# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [26.6] - 2026-05-01

### iOS App

#### Added

- Accessibility Label technique page with good and bad examples
- Accessibility Value technique page with good and bad examples for custom controls
- Accessibility Hint technique page with good and bad examples following Apple's hint guidelines
- Custom choice buttons good and bad examples added to Radio Buttons technique

### Documentation

- Accessibility Label documentation page with WCAG 1.1.1 and 4.1.2 references
- Accessibility Value documentation page with WCAG 4.1.2 reference
- Accessibility Hint documentation page with WCAG 3.3.2 reference
- Added Apple Developer Documentation links to all 83 technique documentation pages
- Added A-Z section headings to README technique index
- Added SKILL.md AI coding skill for SwiftUI accessibility with all 31 a11y-check rules as coding guidelines

## [26.5] - 2026-05-01

### iOS App

#### Added

- a11y-check technique page with good and bad examples for all 31 static analysis rules
- Contrast technique page with good and bad examples for text contrast (WCAG 1.4.3) and non-text contrast (WCAG 1.4.11)
- Alphabetical section headings on technique index for VoiceOver rotor navigation (issue #14)
- Badge accessibility examples for custom tab bars (good and bad) in Tabs technique
- Drag & Drop technique with accessible reorder controls (tap-to-select, Move Up/Down buttons, accessibility actions)
- Multi-Selection Lists technique with good and bad examples using `.accessibilityAddTraits(.isSelected)` and `.accessibilityValue`

#### Changed

- Converted all PreviewProvider structs to #Preview macro
- `image-label-contains-role` rule no longer flags "photo" and "picture" (valid descriptive terms)
- `gesture-missing-alternative` rule now requires visible single-tap Button alternative for touch users
- `tabview-missing-label` moved from Animation to its own Tab Bars category

### Documentation

- Contrast documentation page with WCAG 1.4.3 and 1.4.11 references
- XCTest Accessibility Testing documentation page with `performAccessibilityAudit()` and manual assertions guide
- a11y-check documentation page with all 17 WCAG success criteria references
- Drag & Drop documentation page with WCAG 2.1.1 and 2.5.7 references
- Multi-Selection Lists documentation page with WCAG 1.3.1 and 4.1.2 references

## [26.3] - 2026-04-29

### iOS App

#### Added

- Language of Page technique with good and bad examples using `.environment` locale
- Switch Control action icon bad example
- Accessibility action label icons
- `dynamicTypeSize` range capping technique with good and bad examples
- Bad example for uncapped `largeTitle` heading with card layout
- `fullScreenCover` examples added to Sheets technique

#### Changed

- Language of Page uses `.environment` locale instead of per-element `languageIdentifier`
- Dynamic Type capped heading examples consolidated with improved details

#### Fixed

- Build error from non-existent `accessibilityLanguage` replaced with `languageIdentifier`
- Xcode project cleaned up: removed deleted file references, suppressed SwiftLint warning
- Popover typo in Sheets documentation

### a11y-check

#### Added

- `a11y-check` CLI tool for static accessibility analysis of SwiftUI source code
- WCAG 2.2 accessibility scoring
- Form control, button, and link rules
- Touch target size rule with padding and spacing awareness
- Impact dimension (critical, serious, moderate, minor) for rules
- HTML accessibility report generation
- SARIF output format
- Auto-fix capability
- Trend tracking and per-view scoring
- Xcode build plugin
- Baseline support
- Watch mode and report diff
- Badge generator for accessibility score
- Homebrew formula
- GitHub Actions workflow
- `--lines` flag for output

#### Changed

- Rule severities updated: WCAG failures elevated to error, `heading-trait-missing` changed to needs review
- Info-level diagnostics shown as Needs Review in HTML report
- Simplified score output: removed POUR breakdown, shows failed WCAG criteria

#### Fixed

- Touch target false positives removed; 44pt recommendation removed
- `address2` field incorrectly inferring `streetAddressLine1` instead of `Line2`
- WCAG links corrected to use Understanding pages
- `textContentType` inference from field context
- Link underlines and color contrast in HTML report

### a11y-check

#### Added

- Label in Name rule (WCAG 2.5.3)

### Documentation

- 5 missing technique documentation pages added
- Main README rewritten with improved intro, `a11y-check` stats, MCP wording
- Updated READMEs for 31 rules and 17 WCAG criteria
- MCP server setup for Windsurf, Claude Desktop, and VS Code/Copilot
- Copyright years updated to 2026

### CI/Infrastructure

- Accessibility snapshots workflow updated to macOS 15

## [26.2] - 2026-02-12

### iOS App

#### Added

- Dynamic `AccessibilityFocusState` examples
- Choice button group error validation technique

#### Changed

- Accessibility traits documentation updated
- Copyright years updated to 2026

### CI/Infrastructure

- Accessibility snapshot testing configuration added

## [26.1] - 2026-01-07

### iOS App

#### Added

- Headings and labels technique
- Dim flashing lights technique with documentation

#### Fixed

- Fixed height bad example corrected

### CI/Infrastructure

- SwiftLint build phase integration
- SwiftLint GitHub Actions workflow with accessibility-specific custom rules
- Pull request template with accessibility checklist
- Custom `.swiftlint.yml` rules for accessibility checks

## [26.0] - 2025-09-04

### iOS App

#### Added

- Containers technique
- Toolbars technique and documentation
- TipKit integration

#### Changed

- Adjustable action example fixed for Voice Control
- Pickers view updated
- ScrollView added for Dynamic Type support

#### Fixed

- Bad sheet missing ScrollView
- Video hint correction

### Documentation

- Radio buttons documentation updates
- Documentation links across multiple technique pages

---

For changes prior to version 26.0, see the [git log](https://github.com/cvs-health/ios-swiftui-accessibility-techniques/commits/main).

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
