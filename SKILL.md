---
name: iOS SwiftUI Accessibility
description: Enforces WCAG 2.2 accessible coding patterns when writing SwiftUI — labels, traits, Dynamic Type, contrast, touch targets, focus management, orientation, and more. Based on the ios-swiftui-accessibility-techniques project with 46 static analysis rules across 24 WCAG criteria.
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

- Hints are optional for standard buttons and taps — VoiceOver users can turn them off. Only add a hint when the result of activating an element is not obvious from the label alone.
- **Hints are required** for elements with non-obvious interactions: `.onLongPressGesture`, `.onDrag`, `.onDrop`, `.contextMenu`, `.swipeActions`, `DragGesture`, and `LongPressGesture`. Without a hint, VoiceOver users won't know these interactions exist.
- Use third-person singular verb describing the result: "Adds this item to your favorites." NOT "Add this item to your favorites."
- Never describe the gesture method ("tap", "double tap", "swipe") — VoiceOver already tells users how to interact. Describe what happens, not how to do it.
- Never repeat the label text or include the control type ("button", "link").
- Begin capitalized, end with a period.

```swift
// Good
Button(action: { toggleFavorite() }) {
    Image(systemName: "heart")
}
.accessibilityLabel("Favorite")
.accessibilityHint("Adds this item to your favorites.")

// Bad — describes the gesture method
.accessibilityHint("Double tap to add this item to your favorites.")

// Bad — repeats label
.accessibilityHint("Favorite")

// Good — hint required for long press
Text(item.name)
    .onLongPressGesture { showActions() }
    .accessibilityHint("Shows available actions.")

// Good — hint required for context menu
Button(item.name) { selectItem() }
    .contextMenu { /* menu items */ }
    .accessibilityHint("Shows additional options.")
```

## Headings (WCAG 1.3.1)

- Add `.accessibilityAddTraits(.isHeader)` to all heading-styled text (`.title`, `.headline`, `.subheadline`, etc.) so VoiceOver users can navigate by headings using the Rotor.
- **This applies to your design system's heading tokens too**, not just Apple's styles — `.headingXXL`, `.themeHeadingXL`, `.dsHeading2`. In most real apps that is where nearly all headings live, and they are the ones most often missed.
- Pick the token for what the text *is*, not how large you want it. Rendering a paragraph, a price, or a field label at `.headline` or `.headingL` is a misuse: Apple's text styles are named semantically and `.body`, `.callout` and `.footnote` exist for secondary text. A value shown large is still a value, not a heading.
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

// Good — a design-system heading token still needs the trait
PSText("Order summary", font: .headingL)
    .accessibilityAddTraits(.isHeader)

// Bad — a value styled large is not a heading; it needs a label/value, not .isHeader
PSText(item.price, font: .headingL)

// Bad — body copy at a heading token. Fix the token, do not add the trait.
PSText(longDescription, font: .headingS)
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

// Bad — insufficient contrast (gray text on white background)
Text("Subtitle")
    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
    .background(Color.white)

// Good — sufficient contrast
Text("Subtitle")
    .foregroundColor(.secondary)
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

- `TextField`, `SecureField`, `Slider`, `Stepper`, `Picker`, and `Toggle` all need a visible label that persists. **Where that label comes from differs by control, and getting this wrong is the most common form mistake:**
  - **`Toggle`, `Picker`, `Slider`, `Stepper`** — the built-in label parameter *is* a visible persistent label. Use it; no `.accessibilityLabel` needed.
  - **`TextField`, `SecureField`** — the built-in parameter is **placeholder text, not a label.** It needs a separate visible `Text` beside the field, set as the field's `.accessibilityLabel`.
- **A placeholder is never a label.** `TextField("Email", text: $email)` renders its title as placeholder text, and **once the user types a value VoiceOver never speaks it again** — a populated field announces only its value. "120, text field" does not say whether it is systolic or diastolic. This fails 3.3.2 *and* 4.1.2, not just 3.3.2.
- That makes placeholder-only labelling worse than it looks in testing: it **passes** a VoiceOver pass over an empty form and only fails after data entry. If your check is "open the screen and swipe through", you will not catch it. Fill the form in first.
- Never use `.labelsHidden()` without providing an `.accessibilityLabel`.
- Pickers with `WheelPickerStyle` or `SegmentedPickerStyle` require both `.accessibilityLabel("Label")` and `.accessibilityElement(children: .contain)` or VoiceOver will not speak the picker's label.
- Add `.textContentType(.emailAddress)`, `.textContentType(.password)`, etc. to text fields so autofill works correctly.

```swift
// Good — visible label above the text field, and set as the accessible name
Text("Email")
TextField("Email", text: $email)
    .accessibilityLabel("Email")
    .textContentType(.emailAddress)

// Bad — placeholder only. Reads as "Email, text field" while empty,
// then as just "jo@example.com, text field" once filled in.
TextField("Email", text: $email)

// Good — Toggle with built-in label
Toggle("Enable notifications", isOn: $notificationsEnabled)

// Bad — Toggle without a label
Toggle(isOn: $notificationsEnabled) {
    Image(systemName: "bell")
}
// Fix: add .accessibilityLabel("Enable notifications")

// Good — Slider with label
Slider(value: $volume, in: 0...100) {
    Text("Volume")
}

// Bad — Slider without any label
Slider(value: $volume, in: 0...100)
// Fix: add .accessibilityLabel("Volume")

// Good — Stepper with label
Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)

// Bad — Stepper without a label
Stepper(value: $quantity, in: 1...10) {
    Image(systemName: "cart")
}
// Fix: add .accessibilityLabel("Quantity")

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

## Reading Order / Grouping (WCAG 1.3.1, 1.3.2)

- Use `.accessibilityElement(children: .combine)` on an `HStack` or `VStack` containing an `Image` and `Text` that represent a single concept, so VoiceOver reads them as one element.
- Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel("group label")` on containers of related Buttons (radio-style choices, rating buttons, control groups) so VoiceOver announces the group context when the user navigates into the group. This is analogous to a `<fieldset>` with a `<legend>` in HTML.
- Never use `.accessibilityLabel` on a group container *without* `.accessibilityElement(children: .contain)` — it overrides the visible label text of every control inside the group and causes a Label in Name failure (WCAG 2.5.3).
- In a `ZStack`, VoiceOver reads elements in source order (bottom to top visually), which often doesn't match the visual reading order. If overlaid elements are interactive, use `.accessibilitySortPriority()` or `.accessibilityElement` to control VoiceOver reading order — or restructure the view hierarchy so the source order matches the visual order.
- Only use `.accessibilitySortPriority()` when the visual layout genuinely doesn't match VoiceOver's default left-to-right, top-to-bottom order (e.g., ZStack overlays). Prefer restructuring the view hierarchy or using `.accessibilityElement(children: .combine)` first — sort priority overrides are fragile and easy to get wrong. Overusing `.accessibilitySortPriority()` across many elements makes the reading order hard to maintain.

```swift
// Good — combine image and text into one element
HStack {
    Image(systemName: "star.fill")
    Text("Favorites")
}
.accessibilityElement(children: .combine)

// Bad — ZStack with confusing reading order
ZStack {
    Image("background")
    VStack {
        Text("Title")
        Button("Action") { doSomething() }
    }
}
// VoiceOver reads Image first, then Title, then Button — but Image is behind everything.
// Fix: hide the background image and let the foreground content speak.

// Good — group of related buttons with a container label
VStack {
    Text("Delivery method")
    Button("Standard") { method = .standard }
    Button("Express") { method = .express }
}
.accessibilityElement(children: .contain)
.accessibilityLabel("Delivery method")

// Bad — container label without children: .contain
VStack {
    Button("Standard") { method = .standard }
    Button("Express") { method = .express }
}
.accessibilityLabel("Delivery method")
// Both buttons now report "Delivery method" instead of their visible text — a Label in Name failure.
```

## Sheets and Modals (WCAG 2.4.3)

- Always include a `ScrollView` inside `.sheet()` and `.fullScreenCover()` so content remains accessible at large Dynamic Type sizes.
- Manage focus return on dismiss to avoid losing VoiceOver focus.

## Tab Bars (WCAG 4.1.2, 2.4.2)

- Every tab in a `TabView` must have a `.tabItem { Label("name", systemImage: "icon") }`. A tab without any label is invisible to VoiceOver — users won't know what the tab is for.
- When using `.badge(count)`, also add `.accessibilityValue("\(count) notifications")` because `.badge()` is not automatically read by VoiceOver.

```swift
// Good
TabView {
    HomeView()
        .tabItem { Label("Home", systemImage: "house") }
    SettingsView()
        .tabItem { Label("Settings", systemImage: "gear") }
        .badge(3)
        .accessibilityValue("3 notifications")
}

// Bad — tab has no label
TabView {
    HomeView()
        .tabItem { Image(systemName: "house") }
}
```

## Accessibility Hidden (WCAG 4.1.2, 1.3.1)

- Never apply `.accessibilityHidden(true)` on a container that has interactive children (`Button`, `Toggle`, `TextField`, etc.) — this hides them from VoiceOver completely.
- Only use `.accessibilityHidden(true)` on purely decorative elements.
- **Never apply `.accessibilityHidden(true)` to visible label text.** Moving a field's label onto the control with `.accessibilityLabel` and hiding the visible copy, so VoiceOver stops saying it twice, fails 1.3.1 Info and Relationships: the text is still on screen but gone from the accessibility tree, so swiping past the form skips it, Voice Control users cannot speak it to reach the field, and nothing is left if the control's label is later changed.

  Hearing a label twice is **not** a failure. The web behaves the same way — `<label for>` names the input and stays readable as text, `aria-describedby` is spoken on focus as well as being visible — and hides nothing to avoid it. Associate the two and accept the repetition.

  ```swift
  // Good — label is readable and names the field
  VStack(alignment: .leading) {
      Text("Email address")
      TextField("", text: $email)
          .accessibilityLabel("Email address")
  }

  // Bad — the visible label is deleted from the accessibility tree
  VStack(alignment: .leading) {
      Text("Email address")
          .accessibilityHidden(true)
      TextField("", text: $email)
          .accessibilityLabel("Email address")
  }
  ```

  Three cases where hiding text *is* right: it is decorative or very short (a badge count, a glyph) and the surrounding element already says what it means; it is `.strikethrough()`, where reading "$12.99" aloud would claim to be the current price; or it is a `.placeholder { ... }` overlay duplicating a name the field already carries.

## Timing (WCAG 2.2.1)

- Content that auto-dismisses (using `Task.sleep` or `asyncAfter` with a dismiss) must give the user control to extend or pause the timer.

## Orientation (WCAG 1.3.4)

- Never lock the app to a single orientation (portrait-only or landscape-only). Users with mounted devices (e.g., wheelchair mounts) may not be able to rotate their device.
- Do not override `supportedInterfaceOrientations` to return only `.portrait` or only `.landscape`.
- Do not call `requestGeometryUpdate` to force a single orientation.

```swift
// Bad — locks to portrait only
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .portrait
}

// Good — supports all orientations
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .allButUpsideDown
}
```

## Accessibility Notifications

- Use `UIAccessibility.post(notification: .announcement, argument: "message")` to announce dynamic content changes to VoiceOver users (e.g., search result counts, form validation errors).
- Use `.screenChanged` when the entire screen changes and `.layoutChanged` when part of the screen changes.

---

Source: [ios-swiftui-accessibility-techniques](https://github.com/cvs-health/ios-swiftui-accessibility-techniques) by CVS Health — 85+ technique examples, 41 static analysis rules, 24 WCAG 2.2 criteria.
