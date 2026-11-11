# A11y-check
`a11y-check` is a static analysis tool that scans SwiftUI source code for accessibility issues. It includes 46 rules across 24 WCAG 2.2 success criteria, with a 0–100 scoring system.

Run `a11y-check .` in your project folder to scan all Swift files for missing labels, incorrect traits, small touch targets, hardcoded colors, and more.

See the full [a11y-check README](../../a11y-check/README.md) for installation, CLI options, CI integration, and MCP server setup.

## Rules

### Images
- **`image-missing-label`** (error, WCAG 1.1.1) — `Image(systemName:)` or `Image("name")` missing `.accessibilityLabel()` and not using `Image(decorative:)` or `.accessibilityHidden(true)`. Skipped when something else already owns the name: an enclosing `Button` or `Link` that carries the label, an ancestor with `.accessibilityElement(children: .ignore)` / `.combine` or `.accessibilityHidden(true)`, a design-system token that supplies its own label, and an `Image` the component only produces for a caller to place (a stored `Image` property, or an `Image` returned rather than rendered) — labelling that one would not compile.
- **`image-label-contains-role`** (warning, WCAG 1.1.1) — `.accessibilityLabel()` on an Image contains words like "image", "icon", or "graphic". VoiceOver already announces the image role. Words like "photo" and "picture" are valid descriptive terms and are not flagged.

### Headings
- **`heading-trait-missing`** (warning, WCAG 2.4.6) — `Text` with a heading font style missing `.accessibilityAddTraits(.isHeader)`. Covers the built-in styles (`.title`, `.headline`, etc.) and design-system heading tokens matched by name fragment — `heading`, `header`, `title`, `headline`, `display` — so `.themeHeadingXL`, `.appTitleLarge`, and a custom titling modifier all count. The font is resolved through its declaration rather than read off the variable name, and fonts passed as initialiser arguments are followed. `display` is deliberately included: it names both a type-scale tier that is often not a heading and a typeface (`SF Pro Display`), so a system whose display tier is genuinely not a heading should deny those tokens in config rather than have every project lose the fragment:
  ```yaml
  heading_font_deny: [displayXS, displayS, displayM, displayL]
  ```
- **`fake-heading-in-label`** (error, WCAG 1.3.1) — `.accessibilityLabel()` contains the word "heading" to fake the announcement instead of using `.accessibilityAddTraits(.isHeader)`.

### Buttons
- **`button-label-contains-role`** (error on an authored label, **warning** on visible copy, WCAG 4.1.2) — a `Button` with the word "button" in its name. VoiceOver already announces the button role. The two cases differ in what the fix is: an authored `.accessibilityLabel()` containing "button" is an **error** and autofixable, because dropping the word is a safe local edit. A **visible title** containing "button" is a **warning** — WCAG 2.5.3 Label in Name requires the accessible name to contain the visible text, so the word cannot just be dropped from the name; the fix is the on-screen copy, which is a content decision. Name and role are still programmatically determinable, so that case is a quality issue rather than a conformance failure.
- **`icon-button-missing-label`** (error, WCAG 4.1.2) — `Button` containing only an `Image` with no `.accessibilityLabel()`.
- **`duplicate-button-label`** (error, WCAG 2.4.6) — repeated `Button`s sharing the same visible label, each needing a unique `.accessibilityLabel()` so VoiceOver users can tell them apart. Fails WCAG 2.4.6b Descriptive Labels — "Edit, Edit, Edit" in a list of rows says nothing about which row. Control flow is read, so buttons on mutually exclusive branches of an `if`/`switch` are not reported as duplicates of each other.
- **`button-group-missing-container-label`** (warning, WCAG 1.3.1) — a container of related `Button`s with a visible group label, but no `.accessibilityElement(children: .contain)` and `.accessibilityLabel()`. Without them the group's heading is just loose text and VoiceOver users hear the buttons with no context for what they belong to.
- **`visually-disabled-not-semantic`** (error, WCAG 4.1.2) — `Button` with `.opacity()` or `.tint(.gray)` but no `.disabled(true)`. Appears disabled visually but assistive tech does not know it.

### Accessibility Value
- **`value-contains-role`** (error, WCAG 4.1.2 — **warning** when the role word is "checkbox") — Any view whose `.accessibilityValue()` string contains a role word like "button", "tab", "link", "toggle", "switch", "slider", "picker", or "menu". Values must describe state, not role — VoiceOver announces the role automatically from accessibility traits.
  - **`checkbox` is a warning, not an error.** iOS has no native checkbox trait, so embedding "checkbox" in the label or value is a defensible workaround for teams who feel that VoiceOver's "Switch button" announcement doesn't match the visible checkbox UI. WCAG 4.1.2 is already satisfied by the Toggle's Switch trait, so this is best-practice guidance rather than a hard failure. The recommended pattern is `Toggle` + `.toggleStyle(CheckboxToggleStyle())` + `.accessibilityValue(isChecked ? "Checked" : "Unchecked")` — see [Checkboxes.md](Checkboxes.md) for the reference implementation.

### Traits
- **`tap-gesture-missing-button-trait`** (error, WCAG 4.1.2) — View with `.onTapGesture` missing `.accessibilityAddTraits(.isButton)`. VoiceOver won't announce it as interactive. A trait on an **enclosing container** counts, since an accessibility modifier on a container reaches the element it produces — whether `.accessibilityElement(children: .combine)` collapses the subtree into one element or the trait propagates to children. The walk up stops at `.sheet`, `.fullScreenCover`, `.popover`, `.alert`, `.confirmationDialog`, and `.contextMenu`, because a trait on the presenting view says nothing about a tap inside the screen it presents.

### Toggles
- **`toggle-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Toggle` with an empty label or `.labelsHidden()` and no `.accessibilityLabel()`.

### Links
- **`button-used-as-link`** (error, WCAG 4.1.2) — `Button` whose action unconditionally opens a URL (`openURL`, `UIApplication.shared.open`, `SFSafariViewController`). Use `Link` instead — VoiceOver announces Links differently than Buttons. Only reported where the swap is actually possible, so three shapes are exempt: **constructing** a URL without opening it (a button that builds a `URL(string:)` and hands it to a callback opens nothing), a **conditional** open on one branch of an `if`/`switch` (`Link(destination:)` takes one static destination, so there is no Link that does this), and a button inside an `.alert` **`actions:`** closure — Apple documents that the system ignores any non-button view there, so a `Link` would be silently dropped and the alert would lose its action.
- **`generic-link-text`** (error, WCAG 2.4.4) — `Link` with text like "Click here", "Read more", "Learn more", or "Tap here".

### Touch Targets
- **`small-touch-target`** (error, WCAG 2.5.8) — an interactive view constrained below the 24×24pt minimum. Only flags when **both** dimensions are explicitly constrained under 24pt, and `.padding()` on the element counts toward the size. Measures the view's **own** frame: a 14pt icon inside a `Button` framed at 24pt is not a 14pt touch target, since the thing being tapped is the compliant button, so only frames positioned after the view's entire call count and the last of those wins. Images need a tap gesture to count — a decorative icon is not a touch target. The diagnostic says the target is *smaller than* the minimum rather than asserting a failure: WCAG 2.5.8 carries five exceptions and source settles none of them, most importantly **Spacing**, under which an undersized target conforms if no other target falls inside a 24pt circle centred on it. That depends on sibling positions at runtime, which stack spacing, Dynamic Type, and device width all move. The finding names what would have to be true for it to pass and gives the suppression directive for when it does.

### Dynamic Type
- **`fixed-font-size`** (error, WCAG 1.4.4) — text that does not scale with Dynamic Type. Covers three forms: `.font(.system(size: N))`; a custom typeface at a fixed size without a `relativeTo:` text style, `.font(.custom("Name", size: 17))`; and a `UIFont` at a fixed size, which needs `UIFontMetrics` to scale. `.font(.custom("Name", size: 17, relativeTo: .body))`, `UIFont.preferredFont(forTextStyle:)`, anything already wrapped in `UIFontMetrics`, and a size fed by a `@ScaledMetric` property are exempt — `@ScaledMetric` already tracks Dynamic Type, so `.font(.system(size: scaledSize))` scales.
- **`line-limit-1`** (error, WCAG 1.4.4) — `.lineLimit(1)` truncates text at larger Dynamic Type sizes.
- **`fixed-height-clips-text`** (warning, WCAG 1.4.4) — a text view pinned to an exact `.frame(height:)` between 28 and 60pt. One line of body text is about 53pt at the largest accessibility size, so a snug box clips. The fix is mechanical: change `height:` to `minHeight:`. Deliberately narrow to avoid false positives — it skips `minHeight`/`maxHeight`, heights under 28pt (badges, page dots, icon frames), heights of 60pt and above, chains with `.minimumScaleFactor`, non-text views, and Buttons whose label renders no prose such as `Button { Rectangle() }` or `Button("⬅️")`. Reported as a warning rather than an error because static analysis cannot tell a short string in an adequate box from one that clips.

### Page Titles
- **`missing-navigation-title`** (error, WCAG 2.4.2) — a screen inside a `NavigationStack` or `NavigationView` that sets no page title, so VoiceOver has nothing to announce on arrival. A navigation container is often a **host** rather than a screen, and then the title is not its to set, so three shapes are exempt, each read from a declaration rather than from a name: the content **titles itself** (`NavigationStack { IDCardView() }` where `IDCardView` sets `.navigationTitle()` on its own root in another file — resolved through a cross-file index of self-titled views); the content is **injected** via a `@ViewBuilder` init, so whatever is handed in carries the title; and a design system's **own titling modifier** is resolved through its declaration. The deprecated `.navigationBarTitle()` spelling is accepted — it still sets the title and VoiceOver still announces it, so migrating off it is a different concern from "this screen has no title". `.navigationBarTitleDisplayMode` does **not** count, since it only sets how a title displays.

### Accessibility Hidden
- **`hidden-parent-with-controls`** (error, WCAG 4.1.2) — `.accessibilityHidden(true)` on a container view that has interactive children (`Button`, `Toggle`, `TextField`, etc.).
- **`hidden-label-text`** (warning, WCAG 1.3.1) — `.accessibilityHidden(true)` on visible label text. Moving the label onto the control with `.accessibilityLabel()` and hiding the visible copy to avoid a double announcement removes content sighted users can read. Associate the two instead and accept the repetition — this is what the web does with `<label for>` and `aria-describedby`. A label and a placeholder saying the same thing is normal; the fix is never to delete one side.

### Color Contrast
- **`color-contrast-insufficient`** (error, WCAG 1.4.3) — Computed contrast ratio below 4.5:1 for normal text or 3.0:1 for large text when both foreground and background colors are resolvable.
- **`hardcoded-color`** (warning on text colour, otherwise info, WCAG 1.4.3) — `.foregroundColor(.black)`, `.foregroundColor(.white)`, or inline colour construction (`Color(red:)`, `Color(white:)`, `Color(hue:)`, hex, `#colorLiteral`, `UIColor(...)`) that may not adapt to Dark Mode. A fixed colour on **text** is reported as a warning, since it inverts against the background in the other appearance; decorative uses such as `.background()` and `.tint()` stay at info. Colours held in a file-local `let`/`var` are resolved through their declaration. A chain that pins **both** foreground and background (`.foregroundColor(.white).background(Color.black)`) is skipped — the pair renders the same in either appearance, so Dark Mode adaptation does not apply, and its legibility is `color-contrast-insufficient`'s concern instead.

### Form Controls
- **`textfield-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `TextField` or `SecureField` with an empty title, or relying only on placeholder text as the accessible name. Both variants cite 4.1.2 as well as 3.3.2: device testing confirms that **once a value is entered, VoiceOver never speaks the placeholder again**, so a placeholder-only field loses its accessible name and not just its visible label — a populated field announces "120, text field", which does not say whether it is systolic or diastolic. The placeholder-only case is the nastier of the two to catch, because it *passes* a VoiceOver pass over an empty form and fails only after data entry.
- **`slider-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Slider` with no label and no `.accessibilityLabel()`.
- **`stepper-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Stepper` with an empty label and no `.accessibilityLabel()`.
- **`picker-missing-label`** (error, WCAG 3.3.2, 4.1.2) — `Picker` with no persistent visible label (3.3.2) and no accessible name (4.1.2). The `label:` closure is read, so a picker titled that way is not reported as unlabelled, and a `Picker` inside a `Menu` can take its name from the menu. Reported once per picker rather than once per missing modifier.
- **`picker-style-missing-accessibility`** (error, WCAG 4.1.2) — `Picker` with `WheelPickerStyle` or `SegmentedPickerStyle` missing `.accessibilityLabel()` or `.accessibilityElement(children: .contain)`. Without both modifiers, VoiceOver will not speak the picker's label.

### Focus
- **`sheet-focus-return`** (error, WCAG 2.4.3, 2.1.2) — `.sheet()`, `.fullScreenCover()`, `.popover()`, `.alert()`, or `.confirmationDialog()` with no focus state management on dismiss. VoiceOver focus is lost after dismissal instead of returning to the trigger. Return it by setting `@AccessibilityFocusState` (or `@FocusState`) when the presentation closes. A `ViewModifier` gets advice it can act on, rather than being told to manage focus it has no trigger for.

### Animation
- **`animation-missing-reduce-motion`** (warning, WCAG 2.2.2) — motion that starts **on its own** and either repeats without end or runs past 5 seconds, in a file that does not check `accessibilityReduceMotion` or `UIAccessibility.isReduceMotionEnabled`. Gate it on `@Environment(\.accessibilityReduceMotion)` — note that SwiftUI does **not** disable `.animation()` under Reduce Motion for you, so the check has to be explicit.

  The rule is deliberately narrow, because 2.2.2 reaches less motion than it first appears to. It requires motion that starts automatically **and** lasts over five seconds. `withAnimation` is imperative — it is called from inside an action closure, so it is user-initiated almost by construction, and brief user-initiated transitions (`proxy.scrollTo`, selection toggles, load-state swaps, pager moves, press highlights) fail no success criterion. Motion a user started is WCAG 2.3.3, which is Level AAA and not what this rule cites. Still a warning rather than an error because source cannot always settle whether an animation is essential.

### Tab Bars
- **`tabview-missing-label`** (error, WCAG 4.1.2, 2.4.2) — Views inside a `TabView` that lack a `.tabItem` modifier. Also flags custom tab bar containers using `.accessibilityAddTraits(.isTabBar)` that are missing an `.accessibilityLabel()` group label. VoiceOver users need to hear the tab bar name when entering it.

### Input Purpose
- **`input-missing-purpose`** (error, WCAG 1.3.5) — `TextField` or `SecureField` without `.textContentType()`. Infers the expected content type from variable name, label, or placeholder.

### Gestures
- **`gesture-missing-alternative`** (error, WCAG 2.1.1, 2.5.1) — `.onLongPressGesture` or `.gesture(DragGesture() / RotationGesture() / etc.)` without an `.accessibilityAction()` alternative for VoiceOver users and a visible single-tap Button alternative for touch users who cannot perform the gesture.
- **`draggable-missing-accessibility-action`** (warning, WCAG 2.5.7, 2.1.1) — `.draggable()`, `.dropDestination()`, or `.onDrag()` without `.accessibilityAction(named:)` alternatives (e.g. `"Move Up"`, `"Move Down"`) on the same modifier chain. Use `.accessibilityAction` and `.accessibilityHint("Reorderable. Use actions to move.")`. Warning because the actions may be defined in a parent view. Covers both the new SwiftUI Transferable API (`.draggable`) and the older UIKit-backed API (`.onDrag`); `gesture-missing-alternative` covers `.gesture(DragGesture())`.

### Reading Order / Grouping
- **`missing-accessibility-grouping`** (info, WCAG 1.3.1) — `HStack` or `VStack` containing both `Image` and `Text` without `.accessibilityElement(children: .combine)`.
- **`zstack-order-confusing`** (info, WCAG 1.3.2) — `ZStack` with multiple interactive elements and no `accessibilitySortPriority` or `accessibilityElement` to control VoiceOver reading order.
- **`sort-priority-overused`** (info, WCAG 1.3.2) — **advisory, not a defect.** `.accessibilitySortPriority()` overrides VoiceOver's default reading order, and whether the resulting order is right is a manual check that source cannot make. Deliberate use is correct and expected — ZStack overlays and custom layouts need it. Reported at info so the override is visible to a reviewer, not because it is wrong.
- **`sort-priority-negative`** (error, WCAG 2.5.1 / 2.1.1 / 4.1.2) — `.accessibilitySortPriority(-N)` with a negative numeric literal. Sort priority also governs Explore by Touch hit testing — when overlapping accessibility elements share a touch point, the higher-priority one wins. A negative-priority overlay (e.g., a floating tab bar with `.accessibilitySortPriority(-1)`) loses hit tests to any default-priority (0) scroll content sitting behind it, silently breaking VoiceOver Explore by Touch. Raise the overlay above 0 instead of lowering it below 0. See [AccessibilitySortPriority.md](AccessibilitySortPriority.md).

### Timing
- **`auto-dismiss-no-control`** (error, WCAG 2.2.1) — `.task` or `.onAppear` containing `Task.sleep` or `asyncAfter` with a dismiss, without giving the user control to extend or pause.

### Label in Name
- **`label-in-name`** (error, WCAG 2.5.3) — `.accessibilityLabel()` does not **begin with** the visible text. WCAG 2.5.3 is specific about this: "the accessible name is identical to or begins with the same sequence of characters as the visible text label." Voice Control users who say what they see cannot activate the control otherwise. Note the direction — the fix is to extend the accessible name so it starts with the visible copy, never to delete the visible copy.

### Orientation
- **`orientation-lock`** (warning, WCAG 1.3.4) — `supportedInterfaceOrientations` restricts the app to portrait-only or landscape-only. Users with mounted devices (e.g. wheelchair mounts) may not be able to rotate their device. Does not flag `.all` or `.allButUpsideDown`.

### Video / Audio
- **`video-audio-autoplay`** (warning, WCAG 1.4.2) — `.play()` called inside `.onAppear {}` or `.task {}`, causing audio or video to start without user initiation. VoiceOver speech is disrupted and users with cognitive disabilities cannot stop the media in time. Provide a play/pause Button instead. Warning because silent decorative video or user-acknowledged audio may be acceptable — review manually.

### Motion Actuation
- **`motion-actuation-missing-alternative`** (warning, WCAG 2.5.4) — `CMMotionManager` or CoreMotion update methods (`startAccelerometerUpdates`, `startGyroUpdates`, `startDeviceMotionUpdates`, `startMagnetometerUpdates`) detected without a confirmed UI control alternative in the same file. Functionality driven by device motion (shake, tilt, accelerometer) must also be operable via a standard Button so users with mounted devices can access it. Warning because the UI alternative may live in a parent view or different file — review manually.

### Context Changes
- **`input-triggers-context-change`** (warning, WCAG 3.2.2) — `.onChange` on a `Picker`, `Toggle`, `Slider`, `DatePicker`, or `Stepper` whose closure calls `dismiss()` or mutates a navigation path, triggering an unexpected context change. Move the navigation or dismiss into a user-initiated confirm `Button` instead. Warning because the behavior may be intentional with prior user notice.

### Hints
- **`missing-accessibility-hint`** (warning, WCAG 3.3.2) — Interactive element with a complex gesture (`onLongPressGesture`, `onDrag`, `onDrop`, `contextMenu`, `swipeActions`, `DragGesture`, `LongPressGesture`) without `.accessibilityHint()`. Standard taps and buttons are not flagged.
- **`hint-describes-action-method`** (warning, WCAG 3.3.2) — `.accessibilityHint()` describes how to interact (e.g. "Double tap to purchase") instead of what happens. VoiceOver already announces the gesture. Use third-person form: "Purchases this item".

## Applicable WCAG Success Criteria
- [1.1.1: Non-text Content](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content)
- [1.4.2: Audio Control](https://www.w3.org/WAI/WCAG22/Understanding/audio-control)
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships)
- [1.3.2: Meaningful Sequence](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence)
- [1.3.4: Orientation](https://www.w3.org/WAI/WCAG22/Understanding/orientation)
- [1.3.5: Identify Input Purpose](https://www.w3.org/WAI/WCAG22/Understanding/identify-input-purpose)
- [1.4.3: Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)
- [1.4.4: Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text)
- [2.1.1: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard)
- [2.1.2: No Keyboard Trap](https://www.w3.org/WAI/WCAG22/Understanding/no-keyboard-trap)
- [2.2.1: Timing Adjustable](https://www.w3.org/WAI/WCAG22/Understanding/timing-adjustable)
- [2.2.2: Pause, Stop, Hide](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide)
- [2.4.2: Page Titled](https://www.w3.org/WAI/WCAG22/Understanding/page-titled)
- [2.4.3: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order)
- [2.4.4: Link Purpose (In Context)](https://www.w3.org/WAI/WCAG22/Understanding/link-purpose-in-context)
- [2.4.6: Headings and Labels](https://www.w3.org/WAI/WCAG22/Understanding/headings-and-labels)
- [2.5.1: Pointer Gestures](https://www.w3.org/WAI/WCAG22/Understanding/pointer-gestures)
- [2.5.3: Label in Name](https://www.w3.org/WAI/WCAG22/Understanding/label-in-name)
- [2.5.4: Motion Actuation](https://www.w3.org/WAI/WCAG22/Understanding/motion-actuation)
- [2.5.7: Dragging Movements](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements)
- [2.5.8: Target Size (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum)
- [3.2.2: On Input](https://www.w3.org/WAI/WCAG22/Understanding/on-input)
- [3.3.2: Labels or Instructions](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions)
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value)

## Swift Technique Source Code
[A11yCheckView.swift](../iOSswiftUIa11yTechniques/A11yCheckView.swift)

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
