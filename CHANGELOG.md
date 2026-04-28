# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Language of Page technique with good and bad examples using `.environment` locale
- Switch Control action icon bad example
- Accessibility action label icons
- `dynamicTypeSize` range capping technique with good and bad examples
- Bad example for uncapped `largeTitle` heading with card layout
- `fullScreenCover` examples added to Sheets technique
- 5 missing technique documentation pages
- `a11y-check` CLI tool for static accessibility analysis of SwiftUI source code
- WCAG 2.2 accessibility scoring in `a11y-check`
- Form control, button, and link rules for `a11y-check`
- Touch target size rule with padding and spacing awareness
- Label in Name rule (WCAG 2.5.3) for `a11y-check`
- Impact dimension (critical, serious, moderate, minor) for `a11y-check` rules
- HTML accessibility report generation
- SARIF output format for `a11y-check`
- Auto-fix capability for `a11y-check`
- Trend tracking and per-view scoring
- Xcode build plugin for `a11y-check`
- Baseline support for `a11y-check`
- Watch mode and report diff for `a11y-check`
- Badge generator for accessibility score
- Homebrew formula for `a11y-check`
- GitHub Actions workflow for `a11y-check`
- MCP server setup for Windsurf, Claude Desktop, and VS Code/Copilot
- `--lines` flag for `a11y-check` output

### Changed

- Language of Page uses `.environment` locale instead of per-element `languageIdentifier`
- Dynamic Type capped heading examples consolidated with improved details
- Rule severities updated: WCAG failures elevated to error, `heading-trait-missing` changed to needs review
- Info-level diagnostics shown as Needs Review in HTML report
- Simplified `a11y-check` score output: removed POUR breakdown, shows failed WCAG criteria
- Main README rewritten with improved intro, `a11y-check` stats, MCP wording
- Updated READMEs for 31 rules and 17 WCAG criteria
- Accessibility snapshots workflow updated to macOS 15
- Copyright years updated to 2026

### Fixed

- Build error from non-existent `accessibilityLanguage` replaced with `languageIdentifier`
- Touch target false positives removed; 44pt recommendation removed
- `address2` field incorrectly inferring `streetAddressLine1` instead of `Line2`
- WCAG links corrected to use Understanding pages
- `textContentType` inference from field context
- Link underlines and color contrast in HTML report
- Xcode project cleaned up: removed deleted file references, suppressed SwiftLint warning
- Popover typo in Sheets documentation

## [26.2] - 2026-02-12

### Added

- Dynamic `AccessibilityFocusState` examples
- Choice button group error validation technique
- Accessibility snapshot testing configuration

### Changed

- Accessibility traits documentation updated
- Copyright years updated to 2026

## [26.1] - 2026-01-07

### Added

- Headings and labels technique
- Dim flashing lights technique with documentation
- SwiftLint build phase integration
- SwiftLint GitHub Actions workflow with accessibility-specific custom rules
- Pull request template with accessibility checklist
- Custom `.swiftlint.yml` rules for accessibility checks

### Fixed

- Fixed height bad example corrected

## [26.0] - 2025-09-04

### Added

- Containers technique
- Toolbars technique and documentation
- TipKit integration
- Radio buttons documentation updates
- Documentation links across multiple technique pages

### Changed

- Adjustable action example fixed for Voice Control
- Pickers view updated
- ScrollView added for Dynamic Type support

### Fixed

- Bad sheet missing ScrollView
- Video hint correction

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
