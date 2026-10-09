---
name: iOS Accessibility Design Annotations
description: Rules for generating accessibility annotations on iOS/iPadOS mobile designs in Figma. Enforces a strict annotation budget, an iOS/SwiftUI vocabulary instead of web ARIA terms, and exact grammar for labels, traits, values, hints, headings, groups, and reading order. Use whenever asked to annotate, spec, or review a mobile design for accessibility.
---

# iOS Accessibility Design Annotations

You are annotating a **native iOS design** so that an engineer can build it accessibly in SwiftUI. These rules are mandatory and override your defaults.

An annotation is a **specification**, not a report. It exists for exactly one reason: to tell the developer something they **cannot** work out from looking at the design. If a developer would build it correctly without the note, the note is noise — and noise is the main way AI annotation fails. An over-annotated frame is worse than an un-annotated one, because the reviewer stops reading and the three annotations that mattered get lost with the forty that didn't.

Read "Rule 0" and "The gate" before writing a single annotation.

---

## Rule 0 — The annotation budget

**Hard ceiling: 10 annotations per screen, plus one screen-level block.** Most screens need 3–6.

If you are over the ceiling, you are annotating things the design already says. Delete until you are under it. Do not negotiate with yourself about "but this one is also important" — if everything is annotated, nothing is.

Additional hard limits:

- **One annotation per element, maximum.** Combine all fields for an element into one note. Never place separate "label" and "trait" and "hint" annotations on the same layer.
- **Annotate a repeating component once.** A list of 12 cards, a 5-star rating, a 4-tab tab bar: annotate the first instance, then write `Applies to all N instances.` Never annotate every row.
- **Annotate a design-system component zero times** if its accessibility is already specified in the design system. Write `Uses DS/Button — accessibility per component spec.` once, at the screen level, and move on.

---

## The gate

Before writing any annotation, ask these four questions in order. If you cannot answer "yes" to #4, **do not write it.**

1. **Is this iOS?** If the note only makes sense on the web, delete it.
2. **Is it visible in the design?** If the developer can see it (the visible button text, the obvious tap target, the layout order), they do not need a note telling them it exists.
3. **Is it already the platform default?** SwiftUI gives a `Button` the button trait, a `Link` the link trait, a `Toggle` its on/off value, and a `TextField` its placeholder-to-label relationship for free. Do not annotate the default.
4. **Would omitting this note cause a real defect?** Name the failure. If you cannot name it, there is no annotation.

### Annotate — these are invisible in a static design

- An **accessible name that differs from the visible text**, or an icon-only control with no visible text at all.
- A **heading structure**, because "big bold text" and "a heading" look identical in Figma.
- A **grouping boundary** — which elements VoiceOver should read as one swipe versus separately.
- A **reading order that does not match the visual flow**, and only then.
- The **state** a control conveys, and what it changes to.
- A **non-obvious gesture** (long press, swipe-to-action, drag, context menu) and its non-gesture alternative.
- What happens to **VoiceOver focus** when a modal opens and closes.
- A **dynamic change** that must be announced (error appears, result count changes, async content loads).
- **Reflow intent** where a layout would break at large text sizes.

### Never annotate — pick a fight with yourself about these

- ❌ Every text layer's contrast ratio. Contrast is a **token** concern. Annotate it **only** where a style is off-system or sits on an image or gradient. One screen-level line covers the rest.
- ❌ Decorative images, one by one. One note: `Decorative — hidden from VoiceOver.` Applies to the group.
- ❌ "This is a button." The design shows a button. The developer will use `Button`.
- ❌ Visible text as an "accessible name" when the accessible name **is** the visible text. The default is already correct.
- ❌ Reading order, when the layout is a plain top-to-bottom stack. VoiceOver already does leading-to-trailing, then top-to-bottom.
- ❌ Hints on ordinary buttons and links. See the hint rules — they are **optional** in WCAG and most users switch them off.
- ❌ Touch target size on controls that are already ≥ 44pt in the design. Measure first; annotate the violation, not the compliance.
- ❌ Generic advice. `Ensure sufficient contrast`, `Add appropriate labels`, `Test with VoiceOver`, `Follow WCAG guidelines` are not annotations. They tell the developer nothing and cannot be checked.
- ❌ A WCAG criterion number with no instruction attached. `WCAG 1.3.1` is not a spec.

---

## The nine annotation types — this list is closed

Use **only** these keys. Do not invent fields. Do not import fields from a web annotation kit.

| Key | Builds to | Use when |
| --- | --- | --- |
| `Name` | `.accessibilityLabel` | The accessible name differs from the visible text, or there is no visible text |
| `Trait` | `.accessibilityAddTraits` / correct view type | The element is not already the right native control |
| `Value` | `.accessibilityValue` | The element carries state or a quantity not in its name |
| `Hint` | `.accessibilityHint` | **Only** for the non-obvious interactions listed below |
| `Heading` | `.accessibilityAddTraits(.isHeader)` + `.accessibilityHeading(.hN)` | The text is a heading |
| `Group` | `.accessibilityElement(children: .combine / .contain)` | Several layers should be one VoiceOver stop, or need a shared group name |
| `Order` | restructure, or `.accessibilitySortPriority` | The visual order genuinely disagrees with the default order |
| `Focus` | `@AccessibilityFocusState` | Focus must move or return on a screen or modal change |
| `Announce` | `UIAccessibility.post(notification:)` | A change happens without a screen transition and must be spoken |

**Format.** Figma's native Dev Mode annotation is a free-text note on a layer (optionally tagged with a category such as "Accessibility"). Put these as plain `Key: value` lines inside one note, in the order above. This format works unchanged in a native annotation, in any annotation plugin, and in a handoff doc.

```
Name: Refill
Trait: Button
Hint: Starts a refill for this prescription.
```

---

## Banned vocabulary — this is where AI annotation goes wrong for mobile

Every term on the left belongs to the web. On an iOS design it is wrong, and it tells the developer you do not know the platform. Use the right column.

| ❌ Never write | ✅ Write instead |
| --- | --- |
| `alt text`, `alt=` | `Name:` |
| `aria-label`, `aria-labelledby`, `aria-describedby` | `Name:` / `Hint:` |
| `role="button"`, `role=` anything | `Trait: Button` |
| `aria-live`, `role="status"`, `role="alert"` | `Announce:` |
| `aria-expanded`, `aria-checked`, `aria-selected` | `Value: Expanded` / `Value: Checked` / `Trait: Selected` |
| `aria-hidden` | `Decorative — hidden from VoiceOver` |
| `tabindex`, `tab order`, `keyboard focus order` | `Order:` (VoiceOver swipe order) |
| `landmark`, `region`, `banner`, `main`, `complementary` | Nothing. **iOS has no landmarks.** Use `Heading:` and `Group:` |
| `skip to content` link | Nothing. **iOS has no skip links.** Headings serve this via the VoiceOver Rotor |
| `H1`–`H6` as HTML tags | `Heading: 1`–`Heading: 6` (an iOS heading **level**, not a tag) |
| `<fieldset>` / `<legend>` | `Group: contain, name "…"` |
| `focus ring`, `focus indicator`, `:focus-visible` | Nothing for touch. Only relevant under Full Keyboard Access |
| `screen reader` (generic) | `VoiceOver` — name the actual AT |
| `px`, `rem`, `em` | `pt` |
| `breakpoint`, `mobile/tablet/desktop` | `Compact` / `Regular` size class |
| `hover` state | Nothing. Touch has no hover. Specify `pressed` and `disabled` instead |
| `double tap to activate` | Nothing. **Never** put a gesture in a hint |

Two more mobile-specific traps:

- **Do not annotate a "mobile breakpoint."** An iOS app has size classes and Dynamic Type, not breakpoints. Reflow is driven by text size at least as often as by width.
- **Do not annotate orientation as fixed.** Never write `Portrait only`. Locking orientation fails WCAG 1.3.4 and breaks users with a wheelchair- or arm-mounted device. If a screen is designed portrait-first, annotate `Supports portrait and landscape; content scrolls in landscape.`

---

## Per-type rules

### `Name:` — the accessible name

- **Omit it entirely when the visible text is already the name.** This is the single biggest source of over-annotation.
- 1–3 words where possible. Capitalized. **No trailing period.**
- **Never include the role**: no "button", "icon", "image", "link", "tab", "graphic", "menu". VoiceOver speaks the trait itself, so "Delete button" is heard as "Delete button, button".
- **The name must start with the visible text**, verbatim, when there is visible text. Voice Control users say what they see — a name that does not contain the visible label fails WCAG 2.5.3 Label in Name and leaves the control unspeakable.
- Distinguish repeated controls by appending context, not by rewording: `Refill, Atorvastatin 20mg`, not `Refill prescription number two`.
- Describe what an image **conveys**, not what it depicts and not its file name.

```
✅ Name: Refill, Atorvastatin 20mg
❌ Name: Refill button                  (role in the name)
❌ Name: Start prescription refill      (visible text is "Refill" — fails Label in Name)
❌ Name: icon_refill_24                 (file name)
❌ Name: Refill.                        (trailing period)
```

### `Trait:` — the role

- Allowed values: `Button`, `Link`, `Header`, `Image`, `Selected`, `Modal`, `Search field`, `Static text`, `Toggle`, `Tab`.
- **Omit it when the native control is obvious.** A rectangle with centered text is a `Button`; you do not need to say so. Annotate the trait when the design **lies** about the element:
  - Text that navigates but does not look like a link.
  - A row that acts as a button.
  - A custom control imitating a native one.
- **`Button` vs `Link` is a real distinction on iOS.** `Link` is for anything leaving the app or opening a URL — a web page, Mail, Maps, the App Store. In-app navigation is a `Button` (or `NavigationLink`). Getting this backwards is a 4.1.2 defect.
- If a control is drawn greyed out or dimmed, annotate `Trait: Button, disabled` so the developer marks it genuinely disabled rather than just styling it. A control that looks disabled but is not is a defect that only AT users hit.

### `Value:` — state and quantity

- Annotate the value a sighted user reads from the picture but VoiceOver cannot: a star count, a step position, a selected segment, a badge number, a collapsed/expanded state.
- Write the spoken result and the pattern, not prose: `Value: "3 of 5 stars"`, `Value: "Step 2 of 4"`, `Value: "Collapsed" / "Expanded"`.
- **A badge needs a value.** An iOS tab-bar or icon badge is **not** spoken by VoiceOver on its own. If the design shows a `3` badge, annotate `Value: "3 unread"`. Missing this is one of the most common shipped iOS defects.
- If the user can change the value by dragging or stepping, add `Adjustable: increment / decrement` so the developer wires the VoiceOver swipe-up/down action.
- Do **not** annotate a value that is already the control's visible text, and do not annotate a native `Toggle` — iOS speaks on/off for free.

### `Hint:` — almost always omit this

Hints are **optional** under WCAG and many VoiceOver users turn them off, so a hint can never be the only place information lives. AI annotation vastly over-uses them.

**Omit the hint** for every ordinary button, link, tab, toggle, and text field. If the name says what happens, the hint is redundant.

**A hint is required** only where an interaction is invisible and undiscoverable:

- Long press
- Swipe actions on a row
- Drag and drop / reorder
- Context menu
- Any custom gesture (pinch, rotate, two-finger)

Grammar, when you do write one:

- **Third-person singular verb**, describing the result: `Adds this item to your favorites.`
- **Not** imperative: ❌ `Add this item to your favorites.`
- **Never name the gesture.** ❌ `Double tap to add…` ❌ `Tap to open` ❌ `Swipe to delete`. VoiceOver already tells the user how to interact; your job is to say what happens.
- Capitalized, ends with a period.
- Never repeat the name, and never include the role.

Every custom gesture also needs a **visible, single-tap alternative** — a button a user who cannot long-press or drag can reach. Annotate the alternative as part of the design, not just the hint:

```
Hint: Shows refill and transfer actions.
Gesture alternative: "More" button in the row, same actions. Required — gesture-only
controls fail WCAG 2.1.1 and 2.5.1.
```

### `Heading:` — the one thing you must not skip

Figma renders a heading and a large bold label identically, so this is genuinely invisible and belongs in almost every screen's annotations.

- Mark **every** heading, and give its level: `Heading: 1`, `Heading: 2`, …
- **Do not skip levels.** 1 → 2 → 3, never 1 → 3.
- The screen's **navigation title is the page title**, not a heading — annotate it as `Page title: "Prescriptions"` in the screen block. The first heading inside the content starts at level 1.
- Never express a heading by putting the word "heading" in the name. It will not appear in the VoiceOver Rotor, which is the entire point.
- **A card's first element should be its heading.** If a card leads with an image or a price, annotate the intended order.

```
✅ Heading: 2
❌ Name: Ready for pickup heading
❌ Heading: H2                      (HTML tag, not an iOS level)
```

### `Group:` — grouping and the one dangerous mistake

Two different behaviours, and they are not interchangeable:

- **`Group: combine`** — merge several layers into **one** VoiceOver stop with one name. For an icon + text that mean one thing, or a card the user taps as a whole.
- **`Group: contain, name "Delivery method"`** — keep the children individually focusable but give VoiceOver a group name it speaks on entry. This is the iOS equivalent of a fieldset and legend. Use it for radio-style choices, rating controls, segmented groups, and any set of controls whose visible labels only make sense under a shared heading.

⚠️ **The dangerous mistake:** a group **name** without `contain` silently overrides the visible labels of every control inside the group, which both hides the controls' names and fails WCAG 2.5.3 Label in Name. Whenever you annotate a group name, `contain` must be in the same annotation. Never write `Name:` on a container of controls.

For a card with several actions, say which it is. Either the whole card is one stop, in which case the secondary actions must be preserved explicitly:

```
Group: combine — whole card is one VoiceOver stop.
Name: Atorvastatin 20mg, ready for pickup, CVS Main St
Actions: Refill, Directions (expose as accessibility actions — combining removes
the buttons from the swipe order).
```

…or the card is a container and its buttons stay separate:

```
Group: contain — heading and both buttons stay individually focusable.
```

Never annotate both. Pick one and say why.

### `Order:` — reading order, used sparingly

- VoiceOver defaults to leading-to-trailing, then top-to-bottom. **For a normal stacked layout, write nothing.**
- Annotate order **only** where the visual layout genuinely disagrees with that default: overlapping/z-stacked content, a floating element, a label visually above but after in the layer tree, a two-column compact layout, content that must be read before a sticky overlay.
- State the intended sequence, numbered, and name what is wrong with the default: `Order: 1 heading, 2 price, 3 badge. Badge overlaps the image and would otherwise be read first.`
- Prefer the fix that survives: **restructure the layout, or use `Group: contain`, before asking for explicit sort priorities.** Sort-priority overrides are fragile — every new element needs a number, and the existing numbers get renumbered. Only annotate explicit priorities when no restructuring works.
- Never call this "tab order."

### `Focus:` — where VoiceOver focus goes

Invisible in a static design and a frequent real-world defect, so annotate it whenever the design includes a sheet, modal, alert, popover, or an expanding section.

- On open: `Focus: moves to the sheet title on open.`
- On close: `Focus: returns to the "Refill" button that opened the sheet.` Without this, focus lands unpredictably — usually at the top of the screen — and the user loses their place.
- For an inline expansion: `Focus: stays on the disclosure control; Value changes to "Expanded".`
- Any modal needs `Trait: Modal` so VoiceOver does not wander into the content behind it.
- If a sheet's content could exceed the screen at large text, add `Scrolls` — a modal that cannot scroll is unusable at accessibility text sizes.

### `Announce:` — changes with no screen transition

Use when something changes on screen and VoiceOver would otherwise say nothing: validation errors appearing, a filter changing a result count, async content finishing, a cart total updating, a toast.

- Write the announcement text and its scope: `Announce: "3 results" when the filter changes. Layout change — does not move focus.`
- Use `Screen change` only when the whole screen's content is replaced; `Layout change` for a region.
- An error must **also** be visible text associated with its field — an announcement is not a substitute. Annotate both: `Error text below the field, programmatically associated. Announce on validation failure.`

---

## The screen-level block — one per frame

Put this **once** per screen, not on individual layers. It absorbs most of what AI tries to spread across forty element annotations.

```
SCREEN: Prescriptions

Page title: "Prescriptions" (navigation title — announced on arrival)
Heading structure: 1 "Your prescriptions" → 2 "Ready for pickup" → 2 "In progress"
Dynamic Type: supports up to AX5. Rx cards reflow to vertical stack; no truncation,
  no fixed heights, no single-line limits on body text.
Orientation: portrait and landscape both supported. Content scrolls.
Contrast: all colors from the design system palette and verified. Exception: the
  "Ready" badge sits on the photo — see its annotation.
Touch targets: all controls ≥ 44pt. Exception: the 32pt "info" glyph — see its
  annotation.
Motion: card expansion animation is removed under Reduce Motion; state change is
  instant, not animated.
Components: DS/Button, DS/Card, DS/Badge — accessibility per component spec,
  not re-annotated here.
```

Three notes on that block:

- **Dynamic Type is reflow intent, not a pixel spec.** iOS body text goes from 17pt to roughly 53pt at the largest accessibility size — over 300%, well past the 200% WCAG requires. Do not annotate a target pixel size; annotate what must not happen: no truncation, no fixed heights, no one-line limits, and text containers that grow. If a layout genuinely cannot survive it, design and annotate the large-text variant rather than writing `text may truncate`.
- **Touch targets:** 24×24pt is the WCAG 2.2 AA floor (2.5.8); 44×44pt is Apple's guidance and what you should specify. Targets inline within a line of text are exempt. Measure the design and annotate only the ones that fall short.
- **Contrast:** 4.5:1 for body text, 3:1 for large text (18pt+, or 14pt+ bold), 3:1 for icons, borders, and other meaningful non-text. Annotate the measured ratio only for the exceptions.

---

## Worked example

A prescription card: thumbnail, "Ready for pickup" badge, drug name, store name, a Refill button, a Directions icon button, and swipe-to-archive. Twelve of these in a list.

### ❌ What AI typically produces — 28 annotations, mostly wrong

```
1.  Image: alt text "prescription bottle icon"
2.  Badge: role="status", aria-live="polite", text "Ready for pickup"
3.  Badge: contrast 4.6:1 — passes
4.  Drug name: H3, aria-label "Atorvastatin 20mg", contrast 15.2:1 — passes
5.  Store name: static text, contrast 7.1:1 — passes
6.  Refill: role="button", aria-label "Refill button", tabindex 1,
    hint "Tap to refill this prescription"
7.  Directions: role="button", aria-label "Directions icon",
    hint "Double tap to get directions"
8.  Card: landmark region "prescription", aria-describedby drug name
9.  Card: tab order 1 → 2 → 3 → 4 → 5
10. Card: ensure sufficient color contrast (WCAG 1.4.3)
11. Card: add appropriate ARIA labels (WCAG 4.1.2)
12. Card: test with screen reader
13–24. [the same twelve annotations repeated on every row]
25. List: mobile breakpoint 390px
26. Screen: portrait only
27. Screen: text may truncate at large sizes
28. Screen: skip to content link at top
```

What is wrong with it: the entire web vocabulary (1, 2, 6, 7, 8, 9, 28) does not exist on iOS. Roles are annotated that SwiftUI gives for free (6, 7). Names include the role and break Label in Name (6, 7). Both hints name the gesture, and neither was needed (6, 7). Contrast is annotated where it passes (3, 4, 5) and generically where it cannot be checked (10). Four annotations say nothing actionable (10, 11, 12, 27). Landmarks and skip links are invented (8, 28). Twelve identical rows are annotated twelve times (13–24). Portrait-only fails 1.3.4 (26). Breakpoints are not an iOS concept (25).

And the things that will actually break are all missing: the badge is never spoken, the heading level is unknown, the two icon buttons are indistinguishable across twelve rows, swipe-to-archive is undiscoverable with no alternative, and nothing says how the card groups.

### ✅ Correct annotation set — 5 element annotations + 1 screen block

```
SCREEN: Prescriptions

Page title: "Prescriptions"
Heading structure: 1 "Your prescriptions" → 2 "Ready for pickup"
Dynamic Type: up to AX5. Card reflows to vertical stack, button full width.
  No fixed heights, no line limits.
Orientation: portrait and landscape. List scrolls.
Contrast: design-system palette, verified. No exceptions on this screen.
Touch targets: all ≥ 44pt.
Motion: no animation on this screen.
Components: DS/Card, DS/Button, DS/Badge — accessibility per component spec.
```

```
① RX CARD  — applies to all 12 rows
Group: contain — heading and both buttons stay individually focusable.
Order: default is correct. No override.

② THUMBNAIL
Decorative — hidden from VoiceOver. The drug name carries the information.

③ "Ready for pickup" BADGE
Value: on the card heading — "Atorvastatin 20mg, ready for pickup".
Reason: an iOS badge is not spoken on its own, and the status must not be a
separate VoiceOver stop.

④ DRUG NAME
Heading: 2

⑤ REFILL + DIRECTIONS BUTTONS
Name: "Refill, Atorvastatin 20mg" / "Directions, CVS Main St"
Reason: 24 identically-named buttons in the swipe order are unusable. Visible
text comes first, so Voice Control still works.

⑥ SWIPE TO ARCHIVE
Hint: "Archives this prescription."
Gesture alternative: required. Add "Archive" to the row's accessibility actions
and to the "More" menu — a swipe-only action fails WCAG 2.1.1 and 2.5.1.
```

Six notes instead of twenty-eight, and every one of them tells the developer something the design does not.

---

## Self-check before you deliver

Run every annotation through this. Delete, do not soften.

1. **Count them.** Over 10 per screen? Delete down.
2. **Grep your own output** for: `alt`, `aria`, `role=`, `tabindex`, `landmark`, `skip to`, `H1`–`H6`, `px`, `rem`, `breakpoint`, `hover`, `focus ring`, `tab order`, `screen reader`, `double tap`, `click`. Every hit is a rewrite.
3. **Every `Name:`** — does it contain the visible text, verbatim and first? Is it free of "button", "icon", "image", "link"? No trailing period?
4. **Every `Hint:`** — is this one of the five required interactions? If not, delete it. If so: third person, no gesture named, ends with a period, does not repeat the name?
5. **Every custom gesture** — does it have a visible single-tap alternative annotated?
6. **Every `Group:` with a name** — does it say `contain`?
7. **Every heading** — does it have a level, and do the levels run without skipping?
8. **Every modal, sheet, and alert** — is focus-on-open and focus-on-return annotated?
9. **Every badge, star rating, stepper, and expandable** — does it have a `Value:`?
10. **Every repeated component** — annotated once, with `Applies to all N`?
11. **Every `Order:`** — would the default order genuinely be wrong here? If not, delete it.
12. **Anything unactionable** — "ensure", "appropriate", "consider", "test with", a bare WCAG number? Delete it.
13. **Any contrast or target-size note on something that passes?** Delete it.
14. **Finally:** for each surviving annotation, name the defect it prevents. If you cannot, it should not ship.

---

## WCAG 2.2 criteria these annotations specify

| Annotation | WCAG 2.2 |
| --- | --- |
| `Name` on images | 1.1.1 Non-text Content |
| `Heading`, `Group` | 1.3.1 Info and Relationships |
| `Order` | 1.3.2 Meaningful Sequence |
| Orientation | 1.3.4 Orientation |
| Form field labels | 1.3.5 Identify Input Purpose, 3.3.2 Labels or Instructions |
| Contrast | 1.4.3 Contrast (Minimum), 1.4.11 Non-text Contrast |
| Dynamic Type, reflow | 1.4.4 Resize Text, 1.4.10 Reflow |
| Gesture alternative | 2.1.1 Keyboard, 2.5.1 Pointer Gestures |
| Auto-dismissing content | 2.2.1 Timing Adjustable |
| Motion | 2.3.1 Three Flashes or Below Threshold |
| `Page title` | 2.4.2 Page Titled |
| `Focus` | 2.4.3 Focus Order |
| Link text | 2.4.4 Link Purpose |
| `Name` starts with visible text | 2.5.3 Label in Name |
| Touch targets | 2.5.8 Target Size (Minimum) |
| Error annotations | 3.3.1 Error Identification, 3.3.3 Error Suggestion |
| `Name`, `Trait`, `Value` | 4.1.2 Name, Role, Value |
| `Announce` | 4.1.3 Status Messages |

---

## Handing off to engineering

These annotations map one-to-one onto SwiftUI modifiers. For the implementation rules the developer should follow — and for an AI coding assistant building from these annotations — use **[SKILL.md](SKILL.md)** in this repository, and verify the result with **[a11y-check](a11y-check/README.md)**.

| Annotation | SwiftUI |
| --- | --- |
| `Name` | `.accessibilityLabel("…")` |
| `Trait: Button` | `Button { }` or `.accessibilityAddTraits(.isButton)` |
| `Trait: Link` | `Link("…", destination:)` |
| `Trait: Button, disabled` | `.disabled(true)` |
| `Value` | `.accessibilityValue("…")` |
| `Adjustable` | `.accessibilityAdjustableAction { }` |
| `Hint` | `.accessibilityHint("…")` |
| `Heading: N` | `.accessibilityAddTraits(.isHeader)` + `.accessibilityHeading(.hN)` |
| `Group: combine` | `.accessibilityElement(children: .combine)` |
| `Group: contain, name` | `.accessibilityElement(children: .contain)` + `.accessibilityLabel("…")` |
| `Actions` on a combined element | `.accessibilityAction(named:)` |
| `Order` | restructure, or `.accessibilitySortPriority(…)` |
| `Focus` | `@AccessibilityFocusState` + `.accessibilityFocused($…)` |
| `Announce` | `UIAccessibility.post(notification: .announcement / .layoutChanged / .screenChanged, argument:)` |
| `Page title` | `.navigationTitle("…")` |
| `Decorative` | `Image(decorative:)` or `.accessibilityHidden(true)` |
| Dynamic Type | text styles, `ScrollView`, no `.lineLimit(1)`, no fixed heights |
| Touch targets | `.frame(minWidth: 44, minHeight: 44)` |
| Motion | `@Environment(\.accessibilityReduceMotion)` |

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
