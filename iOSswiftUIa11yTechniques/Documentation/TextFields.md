# Text Fields
Text fields require visible label text next to the field which must be set as the `.accessibilityLabel` of the `TextField`.

Or provide visible labels using `LabeledContent` and then an `.accessibilityLabel` is not required. Don't use `.labeledContentStyle(.vertical)` or else VoiceOver won't be able to double tap to activate the `TextField`.

VoiceOver users must hear the label text spoken when focused on the text field.

Don't use placeholder text which has insufficient contrast and disappears after the user enters a value. 

Don't supply placeholder text with the `prompt:` parameter in place of a visible label. A `prompt:` only draws placeholder text, it is not an accessible name, so `TextField("", text: $fname, prompt: Text("First Name"))` is an unnamed field — VoiceOver speaks only its value and trait, such as "Test, Text field, Double tap to edit."

Filling in the label argument does not fix it, because a `TextField`'s label argument is not exposed as its accessible name either. `TextField("First Name", text: $fname, prompt: Text("First Name"))` is still an unnamed field. Only `.accessibilityLabel` or `LabeledContent` names a `TextField`.

### Placeholder contrast is fixable, but only on a `prompt:`

The system placeholder color fails [1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum): measured on iOS 27 it is `rgb(197,197,199)` on white for **1.72:1** in light mode and `rgb(70,70,73)` on black for **2.23:1** in dark mode.

A `prompt:` takes a `Text`, so `.foregroundColor` on that `Text` is honored and the contrast can be fixed. The label argument cannot be fixed this way — it is a `String`, with nothing to attach a modifier to.

| Written as | Light | Dark |
| --- | --- | --- |
| `prompt: Text("First Name")` | 1.72:1 | 2.23:1 |
| `.foregroundColor(.primary)` | **21:1** | **21:1** |
| `.foregroundColor(Color(UIColor.label))` | **21:1** | **21:1** |
| `.foregroundColor(Color(UIColor.secondaryLabel))` | 3.44:1 | 6.36:1 |
| `.foregroundColor(.black)` | 21:1 | **invisible** |
| `.foregroundStyle(.primary)` | 1.72:1 | 2.23:1 |

Use an adaptive color. A hardcoded `.black` is 21:1 in light mode and draws black-on-black in dark mode, where the placeholder vanishes completely. `Color(UIColor.secondaryLabel)` still reads as placeholder grey but only reaches 3.44:1 in light mode, so it fails 1.4.3 there.

Two modifiers that do not work: `.foregroundStyle(.primary)` on the prompt is ignored, and `.foregroundStyle` on the `TextField` itself colors the entered text but not the placeholder. `.foregroundStyle(Color.black)` on the prompt `Text` does work, so it is the hierarchical `.primary` style that is dropped rather than `.foregroundStyle` itself. `.bold()` on the prompt changes the weight but not the color.

Fixing the contrast does not make a `prompt:` acceptable as a label. The field is still unnamed and the placeholder still disappears on data entry; only one of the three defects is repaired.

Notes:

* Use `.textFieldStyle(.roundedBorder)` to make the `TextField` visually identifiable. 
* Use `.border(.secondary)` to give the border a 3:1 contrast ratio in light and dark mode. 
* Use `.keyboardType` to specify the keyboard displayed on input. 
* Use `.textContentType` to enable form AutoFill for each `TextField`.

VoiceOver Bugs:
- VoiceOver operation is blocked when using `LabeledContent` with a `TextField` and `.labeledContentStyle(.vertical)` because VoiceOver users cannot double tap to activate the TextField and enter a value. Bug reports should be filed with Apple. 

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [3.3.2: Labels or Instructions](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions)
- [1.3.5: Identify Input Purpose](https://www.w3.org/WAI/WCAG22/Understanding/identify-input-purpose)
- [1.4.3: Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)


## Apple Developer Documentation
- [TextField](https://developer.apple.com/documentation/swiftui/textfield)
- [SecureField](https://developer.apple.com/documentation/swiftui/securefield)

## Swift Technique Source Code
[TextFieldsView.swift](../iOSswiftUIa11yTechniques/TextFieldsView.swift)

----

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
