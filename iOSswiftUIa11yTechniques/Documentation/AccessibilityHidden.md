# Accessibility Hidden
Use `.accessibilityHidden(true)` to hide decorative content or repetitive text from VoiceOver, Voice Control, Full Keyboard Access, and Switch Control users. 

Don't use `.accessibilityHidden(true)` on any informative content or UI controls. 

Don't use `.accessibilityHidden(true)` on any parent view containers that hold informative or functional content because all child elements will be hidden.

Don't use `.accessibilityHidden(true)` on visible label text. Moving a field's label onto the control with `.accessibilityLabel` and hiding the visible copy, so that VoiceOver speaks it only once, removes text from the accessibility tree that is still on screen. Swiping through the form skips over it, Voice Control users cannot speak it to reach the field, braille users reading the screen line by line lose it, and nothing is left if the control's label is later changed or removed.

Hearing a label twice is not a failure. The web behaves the same way, where a `<label for>` names its input and also remains readable as text, and `aria-describedby` is spoken on focus as well as being visible. Nothing is hidden to avoid it. Associate the label with the control and accept the repetition.

```swift
// Good — the label is readable and also names the field
VStack(alignment: .leading) {
    Text("Email address")
    TextField("", text: $email)
        .accessibilityLabel("Email address")
}

// Bad — the visible label is removed from the accessibility tree
VStack(alignment: .leading) {
    Text("Email address")
        .accessibilityHidden(true)
    TextField("", text: $email)
        .accessibilityLabel("Email address")
}
```

Three cases where hiding text is correct: it is decorative or very short, such as a badge number or a glyph, and the element around it already says what it means; it is `.strikethrough()`, where reading "$12.99" aloud would claim to be the current price with nothing to convey the strikethrough; or it is a `.placeholder` overlay duplicating a name the field already carries.

## Applicable WCAG Success Criteria
- [1.3.1 Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [1.3.2 Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)


## Apple Developer Documentation
- [View/accessibilityHidden(_:)](https://developer.apple.com/documentation/swiftui/view/accessibilityhidden(_:))

## Swift Technique Source Code
[AccessibilityHidden.swift](../iOSswiftUIa11yTechniques/AccessibilityHidden.swift)

----

Copyright 2024-2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

