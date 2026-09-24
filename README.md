# iOS SwiftUI Accessibility Techniques
iOS and watchOS SwiftUI sample code demonstrating a variety of good and bad accessibility techniques. Learn how to apply WCAG 2.2 to iOS SwiftUI apps. Good and bad examples can be tested with VoiceOver and other iOS accessibility features.

This repo also includes **[a11y-check](#a11y-checker-a11y-check)**, a static analysis tool that scans your Swift/SwiftUI source code for accessibility issues — 44 rules across 23 WCAG 2.2 criteria, with scoring, auto-fix, and CI integration.

[Download the iOS app from the App Store.](https://apps.apple.com/app/accessibility-techniques/id6474141089)

Read the blog post, [Announcing the iOS SwiftUI Accessibility Techniques Open Source Project](https://www.linkedin.com/pulse/announcing-ios-swiftui-accessibility-techniques-open-source-adam-ldahc/).

Review project source code to learn how to apply the accessibility techniques in working SwiftUI code examples. A companion **watchOS app** is also included in the `a11yTechniques Watch App/` directory.

### Building this project

To see **a11y-check** accessibility warnings and errors inline in Xcode when you build, install the tool first:

```bash
brew tap cvs-health/ios-swiftui-accessibility-techniques https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

Without this step the project still builds and runs, but the a11y-check build phase is silently skipped.

To verify it installed correctly, run `a11y-check --version`. To update later, run `brew uninstall a11y-check && brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check`.

## A11y Checker (a11y-check)

Static analysis for SwiftUI accessibility issues, mapped to WCAG 2.2 success criteria. **44 rules** across **23 WCAG criteria** with a **0–100 scoring system**. Run it on your Swift sources to find missing labels, incorrect traits, touch target size, and more. Supports auto-fix (`--fix`), SARIF output for GitHub code scanning, trend tracking, and per-view scoring.

### Check your own iOS app

1. **Install** the tool once (choose one method below).
2. **Run it:** Open Terminal, go to your app’s project folder (the folder that contains your Swift files), and run:

   ```bash
   cd /path/to/YourApp
   a11y-check .
   ```

   The `.` means “this folder” — a11y-check will scan all `.swift` files here and in subfolders and print a list of issues (missing labels, small touch targets, etc.) with file and line.  
   **Tip:** Use `a11y-check . --only error` to show only errors, or `a11y-check --list-rules` to see all rules.

---

**Install via Homebrew (easiest on any Mac):**

```bash
brew tap cvs-health/ios-swiftui-accessibility-techniques https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

Then from your app folder: `a11y-check .`

To verify it installed: `a11y-check --version`  
To update later: `brew uninstall a11y-check && brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check`

**Or build from source:**  
Requires **Swift 5.9+** and **macOS 13+** (Xcode or [Swift.org](https://swift.org) toolchain). From a terminal:

```bash
git clone https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
cd ios-swiftui-accessibility-techniques/a11y-check
swift build
```

To run the checker on your app: from anywhere use the full path to the binary, with your app’s folder as the argument:

```bash
/path/to/ios-swiftui-accessibility-techniques/a11y-check/.build/debug/a11y-check /path/to/YourApp
```

(Replace both paths with your actual paths.) If `swift build` fails, run `swift --version` (you need 5.9 or later); otherwise use the Homebrew method above.

See **[a11y-check/README.md](a11y-check/README.md)** for full usage, options, and CI integration.

**Use with AI editors (MCP):** An [MCP server](a11y-check/mcp-server/README.md) is included so you can run a11y-check from any MCP-compatible editor like Windsurf or Cursor (e.g. "check this project for accessibility"). Install a11y-check first, then add the MCP server config pointing at `a11y-check/mcp-server`.

**AI coding skill:** A [SKILL.md](SKILL.md) file is included that teaches AI coding assistants (Claude Code, CVS Code, Cursor, etc.) how to write accessible SwiftUI code. Copy it to your `~/.claude/skills/` directory or your editor's skills folder and it will automatically enforce WCAG 2.2 accessible coding patterns — labels, traits, Dynamic Type, contrast, touch targets, focus management, and more.

## Accessibility Techniques Documentation

### A
- [A11y-check](iOSswiftUIa11yTechniques/Documentation/A11yCheck.md)
- [Accessibility Actions](iOSswiftUIa11yTechniques/Documentation/AccessibilityActions.md)
- [Accessibility Custom Content](iOSswiftUIa11yTechniques/Documentation/AccessibilityCustomContent.md)
- [Accessibility Detection](iOSswiftUIa11yTechniques/Documentation/AccessibilityDetection.md)
- [Accessibility Hidden](iOSswiftUIa11yTechniques/Documentation/AccessibilityHidden.md)
- [Accessibility Hint](iOSswiftUIa11yTechniques/Documentation/AccessibilityHint.md)
- [Accessibility Identifier](iOSswiftUIa11yTechniques/Documentation/AccessibilityIdentifier.md)
- [Accessibility Input Labels](iOSswiftUIa11yTechniques/Documentation/AccessibilityInputLabels.md)
- [Accessibility Label](iOSswiftUIa11yTechniques/Documentation/AccessibilityLabel.md)
- [Accessibility Notifications](iOSswiftUIa11yTechniques/Documentation/AccessibilityNotifications.md)
- [Accessibility Representation](iOSswiftUIa11yTechniques/Documentation/AccessibilityRepresentation.md)
- [Accessibility Responds To User Interaction](iOSswiftUIa11yTechniques/Documentation/AccessibilityRespondsToUserInteraction.md)
- [Accessibility Sort Priority](iOSswiftUIa11yTechniques/Documentation/AccessibilitySortPriority.md)
- [Accessibility Traits](iOSswiftUIa11yTechniques/Documentation/AccessibilityTraits.md)
- [Accessibility Value](iOSswiftUIa11yTechniques/Documentation/AccessibilityValue.md)
- [Accordions](iOSswiftUIa11yTechniques/Documentation/Accordions.md)
- [Adjustable Action](iOSswiftUIa11yTechniques/Documentation/AdjustableAction.md)
- [Alerts](iOSswiftUIa11yTechniques/Documentation/Alerts.md)
- [Assistive Access](iOSswiftUIa11yTechniques/Documentation/AssistiveAccess.md)
- [Attributed Strings](iOSswiftUIa11yTechniques/Documentation/AttributedStrings.md)

### B
- [Buttons](iOSswiftUIa11yTechniques/Documentation/Buttons.md)

### C
- [Cards](iOSswiftUIa11yTechniques/Documentation/Cards.md)
- [Carousels](iOSswiftUIa11yTechniques/Documentation/Carousels.md)
- [Charts](iOSswiftUIa11yTechniques/Documentation/Charts.md)
- [Checkboxes](iOSswiftUIa11yTechniques/Documentation/Checkboxes.md)
- [Combining Focus](iOSswiftUIa11yTechniques/Documentation/CombiningFocus.md)
- [Confirmation Dialogs](iOSswiftUIa11yTechniques/Documentation/ConfirmationDialogs.md)
- [Containers](iOSswiftUIa11yTechniques/Documentation/Containers.md)
- [Contrast](iOSswiftUIa11yTechniques/Documentation/Contrast.md)

### D
- [Dark Mode](iOSswiftUIa11yTechniques/Documentation/DarkMode.md)
- [Data Tables](iOSswiftUIa11yTechniques/Documentation/DataTables.md)
- [Date & Time Pickers](iOSswiftUIa11yTechniques/Documentation/DateTimePickers.md)
- [Decorative Images](iOSswiftUIa11yTechniques/Documentation/DecorativeImages.md)
- [Device Orientation](iOSswiftUIa11yTechniques/Documentation/DeviceOrientation.md)
- [Dim Flashing Lights](iOSswiftUIa11yTechniques/Documentation/DimFlashingLights.md)
- [Drag & Drop](iOSswiftUIa11yTechniques/Documentation/DragDrop.md)
- [Dynamic Type](iOSswiftUIa11yTechniques/Documentation/DynamicType.md)

### E
- [Error Validation](iOSswiftUIa11yTechniques/Documentation/ErrorValidation.md)
- [Escape Action](iOSswiftUIa11yTechniques/Documentation/EscapeAction.md)

### F
- [Focus Management](iOSswiftUIa11yTechniques/Documentation/FocusManagement.md)
- [Functional Images](iOSswiftUIa11yTechniques/Documentation/FunctionalImages.md)

### G
- [Grouping Controls](iOSswiftUIa11yTechniques/Documentation/GroupingControls.md)

### H
- [Headings](iOSswiftUIa11yTechniques/Documentation/Headings.md)
- [Horizontal Scroll Views](iOSswiftUIa11yTechniques/Documentation/HorizontalScrollViews.md)

### I
- [Images](iOSswiftUIa11yTechniques/Documentation/Images.md)
- [Increase Contrast](iOSswiftUIa11yTechniques/Documentation/IncreaseContrast.md)
- [Informative Images](iOSswiftUIa11yTechniques/Documentation/InformativeImages.md)
- [Input Instructions](iOSswiftUIa11yTechniques/Documentation/InputInstructions.md)

### L
- [Language](iOSswiftUIa11yTechniques/Documentation/Language.md)
- [Large Content Viewer](iOSswiftUIa11yTechniques/Documentation/LargeContentViewer.md)
- [Links](iOSswiftUIa11yTechniques/Documentation/Links.md)
- [Lists](iOSswiftUIa11yTechniques/Documentation/Lists.md)

### M
- [Magic Tap](iOSswiftUIa11yTechniques/Documentation/MagicTap.md)
- [Maps](iOSswiftUIa11yTechniques/Documentation/Maps.md)
- [Meaningful Accessible Names](iOSswiftUIa11yTechniques/Documentation/MeaningfulAccessibleNames.md)
- [Menus](iOSswiftUIa11yTechniques/Documentation/Menus.md)
- [Multi-Selection Lists](iOSswiftUIa11yTechniques/Documentation/MultiSelectionLists.md)

### N
- [Navigation](iOSswiftUIa11yTechniques/Documentation/Navigation.md)

### P
- [Page Titles](iOSswiftUIa11yTechniques/Documentation/PageTitles.md)
- [Pickers](iOSswiftUIa11yTechniques/Documentation/Pickers.md)
- [Popovers](iOSswiftUIa11yTechniques/Documentation/Popovers.md)
- [Progress Indicators](iOSswiftUIa11yTechniques/Documentation/ProgressIndicators.md)

### R
- [Radio Buttons](iOSswiftUIa11yTechniques/Documentation/RadioButtons.md)
- [Reading Order](iOSswiftUIa11yTechniques/Documentation/ReadingOrder.md)
- [Reduce Motion](iOSswiftUIa11yTechniques/Documentation/ReduceMotion.md)
- [Reduce Transparency](iOSswiftUIa11yTechniques/Documentation/ReduceTransparency.md)
- [Redundant Entry](iOSswiftUIa11yTechniques/Documentation/RedundantEntry.md)
- [Responsive Layouts](iOSswiftUIa11yTechniques/Documentation/ResponsiveLayouts.md)
- [Rotor](iOSswiftUIa11yTechniques/Documentation/Rotor.md)

### S
- [Scroll Views](iOSswiftUIa11yTechniques/Documentation/ScrollViews.md)
- [Search Suggestions](iOSswiftUIa11yTechniques/Documentation/SearchSuggestions.md)
- [Segmented Controls](iOSswiftUIa11yTechniques/Documentation/SegmentedControls.md)
- [Sheets](iOSswiftUIa11yTechniques/Documentation/Sheets.md)
- [Sliders](iOSswiftUIa11yTechniques/Documentation/Sliders.md)
- [Smart Invert](iOSswiftUIa11yTechniques/Documentation/SmartInvert.md)
- [Steppers](iOSswiftUIa11yTechniques/Documentation/Steppers.md)
- [SwiftLint](iOSswiftUIa11yTechniques/Documentation/SwiftLint.md)

### T
- [Tabs](iOSswiftUIa11yTechniques/Documentation/Tabs.md)
- [Text Fields](iOSswiftUIa11yTechniques/Documentation/TextFields.md)
- [TipKit](iOSswiftUIa11yTechniques/Documentation/TipKit.md)
- [Toggles](iOSswiftUIa11yTechniques/Documentation/Toggles.md)
- [Toolbars](iOSswiftUIa11yTechniques/Documentation/Toolbars.md)
- [Touch Target Size](iOSswiftUIa11yTechniques/Documentation/TouchTargetSize.md)

### V
- [Videos](iOSswiftUIa11yTechniques/Documentation/Videos.md)
- [VoiceOver Pronunciation](iOSswiftUIa11yTechniques/Documentation/VoiceOverPronunciation.md)

### W
- [Web View Dynamic Type](iOSswiftUIa11yTechniques/Documentation/WebViewDynamicType.md)

### X
- [XCTest Accessibility Testing](iOSswiftUIa11yTechniques/Documentation/XCTestAccessibility.md)


## Contributor Guide

1. Before contributing to this CVS Health sponsored project, you will need to sign the associated [Contributor License Agreement](https://forms.office.com/r/tvFjdsisT2).
2. See [contributing](CONTRIBUTING.md) page.

## License
iOS SwiftUI Accessibility Techniques is licensed under under the Apache License, Version 2.0.  See LICENSE file for more information.

Copyright 2023-2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
