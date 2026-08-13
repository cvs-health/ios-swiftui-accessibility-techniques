# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] - 2026-08-13

### iOSswiftUIa11yTechniquesUITests

#### Fixed

- `testA11yCheck` and `testInformative` now report all `performAccessibilityAudit` failures in a single run. Previously each test would throw and stop at the first issue; now all issues are collected via the `issueHandler` closure and reported individually with `XCTFail`.
- New `XCTestAccessibilityView` page added with intentional good/bad examples for each `performAccessibilityAudit` failure type: missing accessibility label (button + image), small hit area (20×20 button), and insufficient contrast (gray on white text). Paired `testXCTestAccessibility()` uses the collect-all-failures pattern to report every audit issue in a single run.

## [Unreleased] - 2026-07-29

### iOSswiftUIa11yTechniques

#### Fixed

- `TabsGoodView` now shows a unique navigation bar title per tab ("Home" or "Messages") that updates as the user switches tabs, satisfying WCAG 2.4.2. A `@State private var selectedTab` drives `TabView(selection:)` and the `.navigationTitle` is derived dynamically from the selected tab index.
- `MessagesTabView` `.navigationTitle("Messages")` removed — navigation title is now managed centrally by `TabsGoodView` based on the selected tab, so individual tab content views no longer need to set their own title.

### a11y-check

#### Added

- `--base-path <path>` flag strips the given directory prefix from all file paths in every output format (JSON, SARIF, HTML, plain text). Use `--base-path ${{ github.workspace }}` in GitHub Actions to show relative paths instead of full runner paths (e.g. `PackageSources/MyView.swift` instead of `/Users/ec2-user/actions-runner/…/PackageSources/MyView.swift`)
- GitHub Actions PR artifact now includes both `a11y-report.html` (human-readable) and `a11y-results.json` alongside each other — no more reading raw JSON to understand violations
- GitHub Actions PR comment now includes a collapsible section listing every violation with file path, line number, rule ID, WCAG criterion, impact level, and fix suggestion — no need to download the artifact to see all errors
- `--create-github-issues` flag: creates a GitHub issue for every accessibility finding using the `gh` CLI. Issues are assigned to **Copilot** by default (`--github-assign-copilot`, on by default) so GitHub Copilot can automatically open a fix PR for each one. Each issue includes the rule ID, severity, WCAG criteria, file path, line number, source snippet, suggested fix, and a "For Copilot" prompt section.
- `--github-repo <owner/repo>`: specify the target repository. Auto-detected from the git remote when omitted.
- `--github-assign-copilot` / `--no-github-assign-copilot`: assign issues to the `copilot` GitHub user for automated fix PRs (default: on).
- `--github-labels <labels>`: comma-separated labels to apply to created issues (default: `accessibility,a11y`).
- `--github-group-by <diagnostic|file|rule>`: control how findings are grouped into issues. `diagnostic` (default) creates one issue per finding; `file` groups all findings in a source file into a single issue; `rule` groups all occurrences of the same rule across files into a single issue.
- `--dry-run` now also previews GitHub issue creation when used with `--create-github-issues` — prints the issue titles that would be created without calling the GitHub API.
- When `--fix` and `--create-github-issues` are combined, auto-fixes are applied first and issues are only created for findings that couldn't be auto-fixed.

#### Fixed

- `missing-navigation-title` now also flags screen-level `View` structs (those whose `body` root is a `ScrollView` or `List`) that have no `.navigationTitle()` anywhere in their body. These are navigation-destination views that are pushed onto a parent `NavigationStack` defined in another file — the previous rule only caught `NavigationStack` containers directly, missing destination views like `PageTitleBad` that live in their own file.
- `image-missing-label` no longer flags images inside reusable components (cards, list rows, Pulse components, etc.) where an ancestor view correctly manages the component's accessibility as a single element via `.accessibilityElement(children: .ignore)`, `.accessibilityElement(children: .combine)`, or `.accessibilityHidden(true)`. Previously the rule produced false positives in these cases because static analysis can't trace accessibility contracts across files. Images in components that don't use any of these patterns are still flagged — so components that genuinely lack accessibility remain visible to the tool.
- `image-missing-label` no longer flags images inside components where the enclosing struct has a stored property of type `Image` (the image is injected from outside and the caller controls its label) or a stored property named `accessibilityLabel` (the component is explicitly designed to receive a label from its caller). Both conditions are detected by inspecting the enclosing struct's stored properties at the call site.
- `missing-navigation-title` auto-fix (`--fix`) now correctly inserts `.navigationTitle("Page Title")` on the first child view inside the `NavigationStack` closure instead of on the `NavigationStack` itself (which produced a no-op modifier). The HTML report "FIXED CODE" preview for this rule is also suppressed — rather than showing a syntactically invalid placement — until the user applies the actual fix. Suggestion text updated to "on the root view inside the NavigationStack" to clarify the correct placement.
- `tap-gesture-missing-button-trait` rule no longer flags `.onTapGesture` closures whose only statement is a keyboard-dismiss call (`hideKeyboard()`, `dismissKeyboard()`, `endEditing(...)`, `resignFirstResponder()`) — these are background dismiss gestures, not interactive UI controls, and do not need `.accessibilityAddTraits(.isButton)`
- HTML report "FIXED CODE" block for `fixed-font-size` now shows `.font(.body)` instead of the full suggestion description (`.font(.system(size:)) with .font(.body))`) — the parser now correctly extracts the replacement from "Replace X **with** Y" suggestions rather than taking everything from the first `.` to the last `)`
- HTML report "FIXED CODE" block for `toggle-missing-label` now shows both fix options: the preferred `Toggle("Label", isOn: $binding)` (visible label) and the alternative `.accessibilityLabel("Label")` (for when a separate `Text` label element is used); the dual-option pattern is handled generically for any suggestion formatted as `"Add Call(args) — description; or .modifier(...)"`
- HTML report FIXED CODE blocks no longer show modifiers placed inside a view's body. Previously, when the highlighted `>` line opened a multi-line trailing closure (e.g., `HStack {`, `VStack {`, `ScrollView {`, `Button {`), the fix modifier was displayed indented under the opening line, making it appear to be inside the view — but modifiers must go after the closing `}`. The `generateCorrectedSnippet` function now suppresses FIXED CODE when the highlighted line ends with `{` (but not an inline `{}`), since the correct "after `}`" position can't be shown in a static text snippet. The suggestion text already explains exactly what to add and where.
- `missing-navigation-title` `--fix` auto-fix for screen-level destination views (Pattern 2: `View` structs with `ScrollView`/`List` as body root) now correctly inserts `.navigationTitle()` on the first content view inside the `ScrollView`/`List` closure (e.g., on `VStack.padding()`), matching the correct SwiftUI placement. Previously it incorrectly attached the modifier to the `ScrollView` container itself. Suggestion text updated to clarify the correct placement.
- HTML report FIXED CODE blocks for container views (HStack, VStack, ZStack, ScrollView, Button with closure, etc.) now show an abbreviated form — the container opening line, `// …`, an implied closing `}`, and the fix modifier after it — so the correct "after `}`" placement is visually clear. Previously these showed the modifier appearing inside the view body.
- HTML report FIXED CODE now correctly strips role/heading words from accessibility label string literals when the suggestion says `Remove "WORD" from …`. For example, `image-label-contains-role` on `.accessibilityLabel("Heart icon")` now shows `.accessibilityLabel("Heart")`. `fake-heading-in-label` on `.accessibilityLabel("heading Profile Options")` now shows `.accessibilityLabel("Profile Options")` with `.accessibilityAddTraits(.isHeader)` added.
- HTML report FIXED CODE for container views (HStack, VStack, ZStack, ScrollView, Button with closure, etc.) now shows the actual child lines from the source snippet between the opening `{` and the implied closing `}`, making it clear what is inside the container and that the modifier goes after `}`. Previously the children were hidden behind a `// …` placeholder.
- HTML report FIXED CODE now applies word removal (`Remove "WORD" from …` suggestions) to non-highlighted context lines in the snippet, not only to the flagged line itself. This fixes `button-label-contains-role` where the `.accessibilityLabel("Edit button")` modifier is on a separate line from the flagged `Button {} label: {` view — the fixed label is now highlighted green in the FIXED CODE.
- HTML report FIXED CODE now supports view-name substitution for `Replace ViewA with ViewB` suggestions. `button-used-as-link` now shows `Link("Click here") {` replacing `Button("Click here") {` so the required change is visually clear.
- HTML report FIXED CODE snippet window is now expanded to 5 context lines after the flagged line when the flagged line opens a trailing closure (ends with `{`). This ensures container children (e.g., Image and Text inside an HStack) are visible in both the CURRENT CODE and FIXED CODE blocks. Non-container flagged lines now show 3 context lines after (up from 1) so gesture modifiers and nearby modifiers are visible.
- HTML report FIXED CODE for `line-limit-1` now shows `.lineLimit(3)` replacing `.lineLimit(1)`. Previously "Remove .lineLimit(1) or increase to .lineLimit(3) or higher" was parsed with `lastIndex(of: ")")` spanning the entire suggestion, producing garbled output. The "or increase to" pattern is now detected and the replacement modifier is extracted from the second half.
- `missing-navigation-title` Pattern 2 now performs a cross-file pre-pass before per-file analysis to detect View struct names that receive `.navigationTitle()` from a parent navigation container at the call site (rather than setting it in their own body). The pre-pass scans files containing `@ViewBuilder` functions and finds patterns like `getItemDetailView(for: technique).navigationTitle(technique.name)` — all View types constructed inside the `@ViewBuilder` helper are added to an "externally titled" exemption set, and Pattern 2 skips them. This eliminates the false positives for all 11 watchOS technique views (`InformativeImagesWatch`, `TabsWatch`, `SheetsWatch`, etc.) which correctly receive their title from `ContentViewWatch` via a `@ViewBuilder` dispatch function.
- HTML report FIXED CODE modifier extraction now uses balanced-parenthesis matching instead of `lastIndex(of: ")")`. This fixes suggestions whose description text contains extra `)` characters after the modifier (e.g. "Add .navigationTitle("Page Title") on the content view inside the body's ScrollView or List (e.g., on VStack)"). Previously `lastIndex` would pick up the `)` in "(e.g., on VStack)" and include the entire description as the modifier text.
- HTML report FIXED CODE for `missing-navigation-title` (Pattern 2: screen-level `View` with `ScrollView`/`List` root) now places `.navigationTitle("Page Title")` at the child-view indent level inside the container, before the container's closing `}`. Previously the modifier was placed after the `ScrollView`/`List` closing `}`, which is the wrong SwiftUI placement — the title must chain on the content view (e.g., `VStack`) inside the container.
- HTML report FIXED CODE for `hardcoded-color` (and any "Remove .modifier() description" suggestion) now deletes the flagged modifier line from the FIXED CODE block, so the code shown is what it looks like after removal. Previously the line appeared unchanged.
- `missing-navigation-title` diagnostic message now says "which **page** they're on" instead of "which **screen** they're on" to match SwiftUI/WCAG terminology
- SARIF output now includes the required `artifactChanges` property in each `fixes` entry, resolving validation errors when uploading to GitHub Code Scanning
- Documented that `upload-sarif` works automatically on public repositories; private repositories require GitHub Advanced Security (GHAS) to be enabled

## [26.9] - 2026-07-13

### a11y-check

#### Fixed

- `color-contrast-insufficient` rule now checks dark-mode and Increase Contrast asset variants — `.xcassets` color sets with `dark` or `high-contrast` appearance entries are resolved per theme and contrast is evaluated for each; the diagnostic message names the failing theme (e.g. "…in Dark Mode…"). Light-mode-only catalogs are unaffected.
- `color-contrast-insufficient` rule now pairs a text view's foreground color with the nearest enclosing container's (VStack, HStack, ZStack, ScrollView, List, etc.) `.background` when no same-chain background is present. Sibling view backgrounds are never paired. Ancestor-sourced diagnostics include a note "(background inherited from enclosing container)".
- `color-contrast-insufficient` rule now applies the WCAG 1.4.3 large-text threshold (3.0:1) to `.font(.system(size: N))` when `N ≥ 18`, or `N ≥ 14` with a bold/semibold/heavy/black weight. Previously only named styles (`.largeTitle`, `.title`, `.title2`, `.title3`) triggered the lower threshold.
- Fixed an internal `isInsideClosure` guard that was checking parent nodes in the wrong direction, causing all text views inside container closures to be silently skipped by the contrast rule regardless of whether a valid foreground/background pair existed. Replaced with `ModifierCollector.collectChainOnly` which is correct-by-construction.

#### Changed

- `AssetCatalogParser.discoverColors(in:)` now returns `ThemedColorMap` (`[String: ThemedColor]`) instead of a flat `[String: RGBA]`. `ThemedColor` carries `light`, `dark`, `highContrast`, and `darkHighContrast` variants with a `resolve(darkMode:contrastMode:)` helper. This is a **minor-version API change** — callers that assign to `RuleRegistry.assetColors` must update to `ThemedColorMap`. (WCAG 1.4.3)
- Added `bold`, `fontWeight`, and `italic` to `ModifierCollector.trackedModifiers`.

## [26.8] - 2026-06-10

### iOS App

#### Added

- Bad example native alert without focus management on Alerts technique page — uses `.alert()` but does not use `AccessibilityFocusState` to return focus to the trigger button when dismissed

### a11y-check

#### Added

- `button-group-missing-container-label` rule (warning, WCAG 1.3.1) — flags HStack/VStack/LazyVGrid/LazyHStack containers of 2+ Buttons that have a visible group label (preceding Text) but are missing `.accessibilityElement(children: .contain)` and/or `.accessibilityLabel()`, so VoiceOver users hear the group context when navigating to the buttons

## [26.7] - 2026-05-19

### Documentation

#### Added

- Orientation (WCAG 1.3.4) section in SKILL.md covering the `orientation-lock` rule with good/bad code examples
- Toggle, Slider, and Stepper code examples in Form Controls section of SKILL.md
- Code examples for Reading Order / Grouping (combine and ZStack patterns) in SKILL.md
- Tab Bars code examples (good/bad tab labels, badge accessibility) in SKILL.md
- Contrast code example showing insufficient `Color(red:green:blue:)` contrast in SKILL.md
- Long press and context menu hint examples in Accessibility Hint section of SKILL.md

#### Changed

- Clarified that accessibility hints are required for complex gesture elements (long press, context menu, swipe actions, drag) in SKILL.md
- Expanded ZStack guidance explaining source-order vs visual-order confusion and overuse of `.accessibilitySortPriority()` in SKILL.md
- Clarified that tabs without any label are invisible to VoiceOver in SKILL.md

### iOS App

#### Added

- Bad sort priority example on Accessibility Sort Priority technique page — NavigationLink opens a page with incorrect `.accessibilitySortPriority` values that make VoiceOver read a bottom tab bar first

### a11y-check

#### Added

- `sort-priority-overused` rule (warning, WCAG 1.3.2) — flags `.accessibilitySortPriority()` usage for review since it overrides VoiceOver's default reading order and is frequently misused

#### Fixed

- `image-missing-label` and `missing-accessibility-grouping` rules no longer flag views inside `label:` closures (e.g., `Menu { } label: { ... }`) — SwiftUI already groups label closure content as a single accessibility element

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
- Added SKILL.md AI coding skill for SwiftUI accessibility with all 35 a11y-check rules as coding guidelines

### a11y-check

#### Added

- `picker-style-missing-accessibility` rule (error, WCAG 4.1.2) — flags Pickers using `WheelPickerStyle` or `SegmentedPickerStyle` missing `.accessibilityLabel()` or `.accessibilityElement(children: .contain)`, with auto-fix support
- Segmented picker good and bad examples added to a11y-check technique page
- `pickerStyle` added to tracked modifiers in ModifierCollector

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






