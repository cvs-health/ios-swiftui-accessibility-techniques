---
name: iOS SwiftUI Accessibility
description: Enforces WCAG 2.2 accessible coding patterns when writing SwiftUI — labels, traits, Dynamic Type, contrast, touch targets, focus management, and more. Based on the ios-swiftui-accessibility-techniques project with 35 static analysis rules across 19 WCAG criteria.
---

# iOS SwiftUI Accessibility Coding Rules

Follow these rules when writing or reviewing SwiftUI code. Each rule maps to a WCAG 2.2 success criterion.

## Images (WCAG 1.1.1)

- Every `Image(systemName:)` and `Image("name")` must have `.accessibilityLabel("description")` describing what the image conveys.
- For decorative images that add no information, use `Image(decorative:)` or add `.accessibilityHidden(true)`.
- Never include words like "image", "icon", "graphic", or "button" in an `.accessibilityLabel` — VoiceOver already announces the element's trait.
- Describe what the image shows, not the file name or technical details.

```swift
// Good
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite")

// Good — decorative
Image(decorative: "background-pattern")

// Bad — no label
Image(systemName: "trash")

// Bad — includes role
Image(systemName: "heart.fill")
    .accessibilityLabel("Heart icon")
```

## Buttons (WCAG 4.1.2)

- Icon-only `Button` views must have `.accessibilityLabel("action")` describing what the button does.
- Never include "button" in the `.accessibilityLabel` — VoiceOver announces the button trait automatically, so users hear "Delete button, button".
- Prefer `Button` over `.onTapGesture`. If you must use `.onTapGesture`, add `.accessibilityAddTraits(.isButton)` so VoiceOver announces it as a button.
- Visually disabled buttons (using `.opacity()` or `.tint(.gray)`) must also use `.disabled(true)` so assistive technology knows the button is disabled.

```swift
// Good
Button(action: { deleteItem() }) {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete")

// Bad — label includes role
Button(action: {}) {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete button")

// Bad — looks disabled but isn't semantically
Button("Submit", action: {})
    .opacity(0.5)
// Fix:
Button("Submit", action: {})
    .disabled(true)
```

## Accessibility Label (WCAG 4.1.2, 2.5.3)

- Every interactive control must have a meaningful accessible name — either from visible text content or `.accessibilityLabel`.
- Labels should be concise (ideally 1–3 words), begin capitalized, and not end with a period.
- The `.accessibilityLabel` must start with the visible label text so Voice Control users can activate the element by saying what they see (Label in Name — WCAG 2.5.3).
- Never include the control type in the label ("button", "tab", "link", "image").

```swift
// Good — specific label includes visible text first
Button("Add to cart") {}
    .accessibilityLabel("Add to cart, Wireless Headphones")

// Bad — accessible name doesn't contain visible text
Button("Add to cart") {}
    .accessibilityLabel("Purchase Wireless Headphones")
```

## Accessibility Value (WCAG 4.1.2)

- Use `.accessibilityValue` on custom controls to convey their current state or value (e.g., "3 out of 5", "Step 2 of 4", "enabled"/"disabled").
- Pair adjustable custom controls with `.accessibilityAdjustableAction` so VoiceOver users can swipe up/down to change the value.
- Use `.accessibilityValue` on tab bar items to convey badge notification counts (e.g., "3 notifications").

```swift
// Good — custom star rating
HStack {
    ForEach(1...5, id: \.self) { star in
        Image(systemName: star <= rating ? "star.fill" : "star")
    }
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Rating")
.accessibilityValue("\(rating) out of 5")
.accessibilityAdjustableAction { direction in
    switch direction {
    case .increment: rating = min(5, rating + 1)
    case .decrement: rating = max(1, rating - 1)
    @unknown default: break
    }
}
```

## Accessibility Hint (WCAG 3.3.2)

- Hints are optional — VoiceOver users can turn them off. Only add a hint when the result of activating an element is not obvious from the label alone.
- Use third-person singular verb describing the result: "Adds this item to your favorites." NOT "Add this item to your favorites."
- Never mention gestures ("tap", "double tap", "swipe") — VoiceOver already tells users how to interact.
- Never repeat the label text or include the control type ("button", "link").
- Begin capitalized, end with a period.

```swift
// Good
Button(action: { toggleFavorite() }) {
    Image(systemName: "heart")
}
.accessibilityLabel("Favorite")
.accessibilityHint("Adds this item to your favorites.")

// Bad — mentions gesture and control type
.accessibilityHint("Double tap to add this item to your favorites.")

// Bad — repeats label
.accessibilityHint("Favorite")
```

## Headings (WCAG 1.3.1)

- Add `.accessibilityAddTraits(.isHeader)` to all heading-styled text (`.title`, `.headline`, `.subheadline`, etc.) so VoiceOver users can navigate by headings using the Rotor.
- Never fake a heading by putting "heading" in the `.accessibilityLabel` — it won't appear in the Rotor.
- Use `.accessibilityHeading(.h1)` through `.h6` together with `.accessibilityAddTraits(.isHeader)` to set heading levels. Don't skip levels.

```swift
// Good
Text("Settings")
    .font(.title)
    .accessibilityAddTraits(.isHeader)

// Bad — fake heading
Text("Settings")
    .font(.title)
    .accessibilityLabel("Settings heading")
```

## Traits (WCAG 4.1.2)

- Use the correct accessibility trait so assistive technology announces the element's role:
  - `.isButton` — interactive elements that perform an action
  - `.isLink` — elements that navigate to a URL or another view
  - `.isHeader` — section headings
  - `.isSelected` — selected items in a list or tab
  - `.isImage` — informative images
- Prefer `Button` and `Link` views (which set traits automatically) over manual `.onTapGesture` + `.accessibilityAddTraits`.

## Dynamic Type (WCAG 1.4.4)

- Use text styles (`.title`, `.body`, `.caption`, `.headline`, etc.) instead of `.font(.system(size: N))` so text scales with the user's preferred size.
- Never use `.lineLimit(1)` — it truncates text at larger sizes.
- Wrap text content in a `ScrollView` so it remains accessible when enlarged.
- Cap already-large styles (`.largeTitle`, `.title`) with `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)` to prevent excessive growth while still meeting the 200% resize requirement. Never cap body text or small text.
- Use `axis: .vertical` on `TextField` so entered text wraps instead of truncating.

```swift
// Good
Text("Welcome")
    .font(.largeTitle)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

// Bad — fixed size, won't scale
Text("Welcome")
    .font(.system(size: 34))
```

## Color and Contrast (WCAG 1.4.3, 1.4.11)

- Use semantic colors (`Color.primary`, `Color.secondary`) or Asset Catalog colors that adapt to light/dark mode. Never hardcode `.black`, `.white`, or `Color(red:green:blue:)` for foreground/background pairs.
- Text contrast ratio must be at least 4.5:1 for normal text and 3:1 for large text (18pt+ or 14pt+ bold).
- Non-text elements (icons, borders, focus indicators) must have at least 3:1 contrast ratio.
- Support the Increase Contrast accessibility setting.

```swift
// Good — adapts to dark mode
Text("Hello")
    .foregroundColor(.primary)

// Bad — won't adapt to dark mode
Text("Hello")
    .foregroundColor(.black)
```

## Touch Target Size (WCAG 2.5.8)

- Touch targets must be at least 24x24pt (WCAG 2.2 Level AA minimum). Use `.frame(minWidth: 24, minHeight: 24)` on icon-only buttons.
- Apple recommends 44x44pt for comfortable tapping. Inline targets within a line of text are exempt.

```swift
// Good
Button(action: {}) {
    Image(systemName: "xmark")
        .frame(minWidth: 44, minHeight: 44)
}
```

## Form Controls (WCAG 1.3.5, 3.3.2, 4.1.2)

- `TextField`, `SecureField`, `Slider`, `Stepper`, `Picker`, and `Toggle` all need visible labels. Use the built-in label parameter or add `.accessibilityLabel`.
- Never use `.labelsHidden()` without providing an `.accessibilityLabel`.
- Pickers with `WheelPickerStyle` or `SegmentedPickerStyle` require both `.accessibilityLabel("Label")` and `.accessibilityElement(children: .contain)` or VoiceOver will not speak the picker's label.
- Add `.textContentType(.emailAddress)`, `.textContentType(.password)`, etc. to text fields so autofill works correctly.

```swift
// Good — visible label above the text field
Text("Email")
TextField("Email", text: $email)
    .textContentType(.emailAddress)

// Good — segmented picker with both required modifiers
Picker("Size", selection: $size) {
    Text("S").tag("S")
    Text("M").tag("M")
    Text("L").tag("L")
}
.pickerStyle(.segmented)
.accessibilityElement(children: .contain)
.accessibilityLabel("Size")

// Bad — hidden label, no accessibility label
TextField("", text: $email)
    .labelsHidden()
```

## Navigation and Page Titles (WCAG 2.4.2, 2.4.3)

- Every view inside a `NavigationStack` must have `.navigationTitle("Page Title")` so VoiceOver announces the page when it appears.
- After dismissing a `.sheet()`, `.fullScreenCover()`, `.alert()`, or `.popover()`, return VoiceOver focus to the trigger element using `@AccessibilityFocusState`.

```swift
@AccessibilityFocusState private var isTriggerFocused: Bool

Button("Show Details") { showSheet = true }
    .accessibilityFocused($isTriggerFocused)
    .sheet(isPresented: $showSheet, onDismiss: {
        isTriggerFocused = true
    }) {
        DetailView()
    }
```

## Gestures (WCAG 2.1.1, 2.5.1)

- Custom gestures (`.onLongPressGesture`, `DragGesture`, `RotationGesture`, `MagnificationGesture`) must have:
  1. An `.accessibilityAction` alternative for VoiceOver users
  2. A visible single-tap `Button` alternative for touch users who cannot perform the gesture

```swift
// Good — drag gesture with button alternatives
ForEach(items) { item in
    Text(item.name)
        .onDrag { NSItemProvider(object: item.name as NSString) }
}
// Plus: Move Up / Move Down buttons or .accessibilityAction for reordering
```

## Animation and Motion (WCAG 2.3.1)

- Always check `@Environment(\.accessibilityReduceMotion)` or `UIAccessibility.isReduceMotionEnabled` before using `.animation()` or `withAnimation`. Remove or simplify animations when reduce motion is enabled.

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .spring()) {
    isExpanded.toggle()
}
```

## Links (WCAG 2.4.4, 4.1.2)

- Use `Link("text", destination: url)` instead of a `Button` that calls `openURL`. This gives the element the correct link trait.
- Never use generic link text like "Click here", "Read more", "Learn more", or "Tap here". The link text must describe its destination.

```swift
// Good
Link("CVS Health Privacy Policy", destination: privacyURL)

// Bad — button used as link
Button("Click here") { openURL(privacyURL) }
```

## Grouping (WCAG 1.3.1, 1.3.2)

- Use `.accessibilityElement(children: .combine)` on an `HStack` or `VStack` containing an `Image` and `Text` that represent a single concept, so VoiceOver reads them as one element.
- In a `ZStack` with multiple interactive elements, use `.accessibilitySortPriority()` or `.accessibilityElement` to control VoiceOver reading order.

## Sheets and Modals (WCAG 2.4.3)

- Always include a `ScrollView` inside `.sheet()` and `.fullScreenCover()` so content remains accessible at large Dynamic Type sizes.
- Manage focus return on dismiss to avoid losing VoiceOver focus.

## Tab Bars (WCAG 4.1.2)

- Every tab in a `TabView` must have a `.tabItem { Label("name", systemImage: "icon") }`.
- When using `.badge(count)`, also add `.accessibilityValue("\(count) notifications")` because `.badge()` is not automatically read by VoiceOver.

## Accessibility Hidden (WCAG 4.1.2)

- Never apply `.accessibilityHidden(true)` on a container that has interactive children (`Button`, `Toggle`, `TextField`, etc.) — this hides them from VoiceOver completely.
- Only use `.accessibilityHidden(true)` on purely decorative elements.

## Timing (WCAG 2.2.1)

- Content that auto-dismisses (using `Task.sleep` or `asyncAfter` with a dismiss) must give the user control to extend or pause the timer.

## Accessibility Notifications

- Use `UIAccessibility.post(notification: .announcement, argument: "message")` to announce dynamic content changes to VoiceOver users (e.g., search result counts, form validation errors).
- Use `.screenChanged` when the entire screen changes and `.layoutChanged` when part of the screen changes.

---

Source: [ios-swiftui-accessibility-techniques](https://github.com/cvs-health/ios-swiftui-accessibility-techniques) by CVS Health — 85+ technique examples, 35 static analysis rules, 19 WCAG 2.2 criteria.
