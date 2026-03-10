# iOS SwiftUI Accessibility Techniques
iOS SwiftUI sample code demonstrating a variety of good and bad accessibility techniques. Learn how to apply WCAG to iOS SwiftUI apps. Good and Bad examples can be tested with VoiceOver and other iOS accessibility features.

[Download iOS app from the AppStore.](https://apps.apple.com/app/accessibility-techniques/id6474141089)

Read the blog post, [Announcing the iOS SwiftUI Accessibility Techniques Open Source Project](https://www.linkedin.com/pulse/announcing-ios-swiftui-accessibility-techniques-open-source-adam-ldahc/).

Review project source code to learn how to apply the accessibility techniques in working SwiftUI code examples.

## A11y Checker (a11y-check)

Static analysis for SwiftUI accessibility issues, aligned with WCAG 2.2. Run it on your Swift sources to find missing labels, incorrect traits, touch target size, and more.

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
Clone this repo, then from **this repo’s root** (not from your app):

```bash
git clone https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
cd ios-swiftui-accessibility-techniques
brew tap cvs-health/ios-swiftui-accessibility-techniques file://$PWD
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

Then from your app folder: `a11y-check .`

**Or build from source:**  
Requires **Swift 5.9+** and **macOS 13+** (Xcode or [Swift.org](https://swift.org) toolchain). From a terminal:

```bash
git clone https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
cd ios-swiftui-accessibility-techniques/A11yAgent
swift build
```

To run the checker on your app: from anywhere use the full path to the binary, with your app’s folder as the argument:

```bash
/path/to/ios-swiftui-accessibility-techniques/A11yAgent/.build/debug/a11y-check /path/to/YourApp
```

(Replace both paths with your actual paths.) If `swift build` fails, run `swift --version` (you need 5.9 or later); otherwise use the Homebrew method above.

See **[A11yAgent/README.md](A11yAgent/README.md)** for full usage, options, and CI integration.

**Use in Cursor (MCP):** An [MCP server](A11yAgent/mcp-server/README.md) is included so you can run a11y-check from Cursor chat (e.g. “check this project for accessibility”). Install a11y-check first, then add the MCP server to Cursor and point it at `A11yAgent/mcp-server`.

## Accessibility Techniques Documentation
- [x] = Completed
- [x] [Accessibility Actions](iOSswiftUIa11yTechniques/Documentation/AccessibilityActions.md)
- [x] [Accessibility Detection](iOSswiftUIa11yTechniques/Documentation/AccessibilityDetection.md)
- [x] [Accessibility Hidden](iOSswiftUIa11yTechniques/Documentation/AccessibilityHidden.md)
- [x] [Accessibility Input Labels](iOSswiftUIa11yTechniques/Documentation/AccessibilityInputLabels.md)
- [x] [Accessibility Notifications](iOSswiftUIa11yTechniques/Documentation/AccessibilityNotifications.md)
- [x] [Accessibility Representation](iOSswiftUIa11yTechniques/Documentation/AccessibilityRepresentation.md)
- [x] [Accessibility Responds To User Interaction](iOSswiftUIa11yTechniques/Documentation/AccessibilityRespondsToUserInteraction.md)
- [x] [Accordions](iOSswiftUIa11yTechniques/Documentation/Accordions.md)
- [x] [Adjustable Action](iOSswiftUIa11yTechniques/Documentation/AdjustableAction.md)
- [x] [Alerts](iOSswiftUIa11yTechniques/Documentation/Alerts.md)
- [x] [Assistive Access](iOSswiftUIa11yTechniques/Documentation/AssistiveAccess.md)
- [x] [Attributed Strings](iOSswiftUIa11yTechniques/Documentation/AttributedStrings.md)
- [x] [Buttons](iOSswiftUIa11yTechniques/Documentation/Buttons.md)
- [x] [Cards](iOSswiftUIa11yTechniques/Documentation/Cards.md)
- [x] [Charts](iOSswiftUIa11yTechniques/Documentation/Charts.md)
- [x] [Checkboxes](iOSswiftUIa11yTechniques/Documentation/Checkboxes.md)
- [x] [Combining Focus](iOSswiftUIa11yTechniques/Documentation/CombiningFocus.md)
- [x] [Confirmation Dialogs](iOSswiftUIa11yTechniques/Documentation/ConfirmationDialogs.md)
- [x] [Containers](iOSswiftUIa11yTechniques/Documentation/Containers.md)
- [x] [Dark Mode](iOSswiftUIa11yTechniques/Documentation/DarkMode.md)
- [x] [Data Tables](iOSswiftUIa11yTechniques/Documentation/DataTables.md)
- [x] [Date & Time Pickers](iOSswiftUIa11yTechniques/Documentation/DateTimePickers.md)
- [x] [Decorative Images](iOSswiftUIa11yTechniques/Documentation/DecorativeImages.md)
- [x] [Device Orientation](iOSswiftUIa11yTechniques/Documentation/DeviceOrientation.md)
- [x] [Dim Flashing Lights](iOSswiftUIa11yTechniques/Documentation/DimFlashingLights.md)
- [x] [Dynamic Type](iOSswiftUIa11yTechniques/Documentation/DynamicType.md)
- [x] [Error Validation](iOSswiftUIa11yTechniques/Documentation/ErrorValidation.md)
- [x] [Escape Action](iOSswiftUIa11yTechniques/Documentation/EscapeAction.md)
- [x] [Focus Management](iOSswiftUIa11yTechniques/Documentation/FocusManagement.md)
- [x] [Functional Images](iOSswiftUIa11yTechniques/Documentation/FunctionalImages.md)
- [x] [Grouping Controls](iOSswiftUIa11yTechniques/Documentation/GroupingControls.md)
- [x] [Headings](iOSswiftUIa11yTechniques/Documentation/Headings.md)
- [x] [Horizontal Scroll Views](iOSswiftUIa11yTechniques/Documentation/HorizontalScrollViews.md)
- [x] [Images](iOSswiftUIa11yTechniques/Documentation/Images.md)
- [x] [Increase Contrast](iOSswiftUIa11yTechniques/Documentation/IncreaseContrast.md)
- [x] [Informative Images](iOSswiftUIa11yTechniques/Documentation/InformativeImages.md)
- [x] [Input Instructions](iOSswiftUIa11yTechniques/Documentation/InputInstructions.md)
- [x] [Language](iOSswiftUIa11yTechniques/Documentation/Language.md)
- [x] [Large Content Viewer](iOSswiftUIa11yTechniques/Documentation/LargeContentViewer.md)
- [x] [Links](iOSswiftUIa11yTechniques/Documentation/Links.md)
- [x] [Lists](iOSswiftUIa11yTechniques/Documentation/Lists.md)
- [x] [Magic Tap](iOSswiftUIa11yTechniques/Documentation/MagicTap.md)
- [x] [Meaningful Accessible Names](iOSswiftUIa11yTechniques/Documentation/MeaningfulAccessibleNames.md)
- [x] [Menus](iOSswiftUIa11yTechniques/Documentation/Menus.md)
- [x] [Navigation](iOSswiftUIa11yTechniques/Documentation/Navigation.md)
- [x] [Page Titles](iOSswiftUIa11yTechniques/Documentation/PageTitles.md)
- [x] [Pickers](iOSswiftUIa11yTechniques/Documentation/Pickers.md)
- [x] [Popovers](iOSswiftUIa11yTechniques/Documentation/Popovers.md)
- [x] [Progress Indicators](iOSswiftUIa11yTechniques/Documentation/ProgressIndicators.md)
- [x] [Radio Buttons](iOSswiftUIa11yTechniques/Documentation/RadioButtons.md)
- [x] [Reading Order](iOSswiftUIa11yTechniques/Documentation/ReadingOrder.md)
- [x] [Reduce Motion](iOSswiftUIa11yTechniques/Documentation/ReduceMotion.md)
- [x] [Reduce Transparency](iOSswiftUIa11yTechniques/Documentation/ReduceTransparency.md)
- [x] Responsive Layouts
- [x] [Rotor](iOSswiftUIa11yTechniques/Documentation/Rotor.md)
- [x] [Scroll Views](iOSswiftUIa11yTechniques/Documentation/ScrollViews.md)
- [x] [Search Suggestions](iOSswiftUIa11yTechniques/Documentation/SearchSuggestions.md)
- [x] [Segmented Controls](iOSswiftUIa11yTechniques/Documentation/SegmentedControls.md)
- [x] [Sheets](iOSswiftUIa11yTechniques/Documentation/Sheets.md)
- [ ] Siri Shortcuts
- [x] [Sliders](iOSswiftUIa11yTechniques/Documentation/Sliders.md)
- [x] [Smart Invert](iOSswiftUIa11yTechniques/Documentation/SmartInvert.md)
- [x] [Steppers](iOSswiftUIa11yTechniques/Documentation/Steppers.md)
- [x] [SwiftLint](iOSswiftUIa11yTechniques/Documentation/SwiftLint.md)
- [x] [Tabs](iOSswiftUIa11yTechniques/Documentation/Tabs.md)
- [x] [Text Fields](iOSswiftUIa11yTechniques/Documentation/TextFields.md)
- [x] [Toggles](iOSswiftUIa11yTechniques/Documentation/Toggles.md)
- [x] [TipKit](iOSswiftUIa11yTechniques/Documentation/TipKit.md)
- [x] [Toolbars](iOSswiftUIa11yTechniques/Documentation/Toolbars.md)
- [x] [Touch Target Size](iOSswiftUIa11yTechniques/Documentation/TouchTargetSize.md)
- [x] [Videos](iOSswiftUIa11yTechniques/Documentation/Videos.md)
- [x] [VoiceOver Pronunciation](iOSswiftUIa11yTechniques/Documentation/VoiceOverPronunciation.md)


## Contributor Guide

1. Before contributing to this CVS Health sponsored project, you will need to sign the associated [Contributor License Agreement](https://forms.office.com/r/tvFjdsisT2).
2. See [contributing](CONTRIBUTING.md) page.

## License
iOS SwiftUI Accessibility Techniques is licensed under under the Apache License, Version 2.0.  See LICENSE file for more information.

Copyright 2023-2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
