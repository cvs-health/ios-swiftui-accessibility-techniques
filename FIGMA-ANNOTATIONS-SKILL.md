---
name: figma-a11y-annotations
description: Rules for generating accessibility annotations on iOS/iPadOS mobile designs in Figma. Enforces a bare-minimum annotation discipline, an iOS vocabulary instead of web ARIA terms, and exact grammar for names, components, values, hints, headings, groups, and reading order. Never annotates visible text as a label, never annotates traits as iOS API, never annotates default reading order. Use whenever asked to annotate, spec, or review a mobile design for accessibility.
---

# iOS Accessibility Design Annotations

You are annotating a **native iOS design** so that an engineer can build it accessibly in SwiftUI. These rules are mandatory and override your defaults.

An annotation is a **specification**, not a report. It exists for exactly one reason: to tell the developer something they **cannot** work out from looking at the design. If a developer would build it correctly without the note, the note is noise — and noise is the main way AI annotation fails. An over-annotated frame is worse than an un-annotated one, because the reviewer stops reading and the three annotations that mattered get lost with the forty that didn't.

Read the principles, "Rule 0", and "The gate" before writing a single annotation.

---

## Principles

Ten ideas the rest of this file is built on. When a specific rule below is unclear, resolve it against these.

### 1. Never annotate visible text as an accessibility label

If a control's visible text is already its accessible name, **write no `Name:` annotation at all.** This is the most common and most damaging annotation mistake, and it is damaging in three separate ways:

- **It clutters.** A button labeled "Refill" annotated `Name: Refill` has spent a note to say nothing. Do this across a screen and the handful of notes that carry real information are buried.
- **It introduces drift, and manufactures a failure that did not exist.** An annotated label is retyped prose, so it is rarely byte-identical to the visible text — "Refill" becomes "Refill prescription", "Add to Cart" becomes "Add to cart", "Done" becomes "Save". The moment it differs, the accessible name no longer contains the visible label, and you have created a **WCAG 2.5.3 Label in Name** failure — along with a control that Voice Control users cannot activate by saying what they see. The code was correct before you annotated it.
- **It produces redundant code.** A developer handed `Name: Refill` will write `.accessibilityLabel("Refill")` on a `Button("Refill")`, because the annotation implies something was needed. Now the same string exists twice, must be localized twice, and will be updated in one place and not the other. SwiftUI already derived that name from the visible text, for free and correctly.

SwiftUI gets this right by default: `Button("Refill")`, `Text`, `Toggle("Notifications")`, `Link("Privacy Policy")`, and `TextField` with a visible label all take their accessible name from their visible content. **Annotating the default is not neutral — it is a regression.**

`Name:` is for the two cases where the name is genuinely invisible in the design:

- **There is no visible text** — an icon-only button, a glyph, an informative image.
- **The visible text is generic or repeated** — a column of "Edit" buttons, twelve "Refill" buttons, a list of "Learn more" links. Each one is ambiguous in the VoiceOver swipe order, where the user hears the control without the context a sighted user gets from its position.

**For that second case, try combining focus before you add a name.** A generic label is usually only ambiguous because it has been separated from the text next to it. A row reading "Email Address … Edit" needs no annotation if the row is one VoiceOver stop: combined, it announces "Email Address, Edit", which is already unique and already correct. Reach for `Group: combine` first — it costs one annotation instead of one per control, it adds no duplicated strings, and it stays correct when the field is renamed. Annotating ten unique names where one grouping would do is the clutter this principle is about.

Add a unique `Name:` only when combining cannot fix it or does not make sense:

- Combining would **swallow a heading** — a card titled with a `Heading: 2` must stay its own stop, so its buttons cannot absorb it.
- Combining would **merge two distinct actions** into one stop.
- There is **nothing adjacent to combine with**, or the context lives far from the control.

So the order of preference is: **fix the component and the visible text → combine focus → and only then annotate a unique name.**

When you do reach the last step, the name is an *extension*, not a restatement. The visible text stays verbatim and first, and the appended context is the part that was invisible: `Name: "Refill, Atorvastatin 20mg"`. If you find yourself annotating a name whose only content is the visible text, delete the annotation.

### 2. Put it in the properties panel, not a callout on the canvas

**Where** an annotation lives matters as much as what it says. If Figma exposes a field for the value, **put it in the field** — select the image and type the alt text into its description/alt-text property, set the component's `level` property on a heading, set the component variant, use the layer's annotation category. Do not place a floating text callout next to the element when a property will hold the same value.

Three reasons, and the first is the one that matters most now:

- **A property is structured data; a callout is a picture of data.** An AI generating an accessible prototype or SwiftUI code from the file can read a property reliably and attach it to the correct layer, because the value *is* on the layer. A canvas callout is a separate text node that happens to sit near something, connected by a line the tool cannot follow. Associating callouts with their targets is guesswork, and guessing wrong silently puts the alt text on the wrong image. If you want AI to build an accessible prototype from the design, properties are the channel that survives the trip.
- **A property travels with the layer.** Copy the component, swap the instance, reflow the layout, move the frame — the property goes with it. A callout detaches, gets left behind, or ends up pointing at a neighbour. Annotations that drift are worse than none, because they are confidently wrong.
- **A property adds nothing to the canvas.** The design stays readable. Thirty callouts do not just clutter the handoff, they clutter the *design*, which is how a reviewer ends up unable to see either.

So the order of preference is: **fix the component → set the property → write a callout.** A callout is the last resort, not the default.

**Callouts are still correct for anything that is not a property of one layer.** These are inherently about relationships between elements, so no single field can hold them:

- `Group:` — which elements merge or contain
- `Order:` — which container is read before which
- `Focus:` — where focus goes when a sheet opens and closes
- `Announce:` — what is spoken when something changes
- Gesture alternatives

⚠️ **A property is not a loophole.** Moving a value into a field does not exempt it from any other rule here: a redundant label is still redundant in a properties panel, visible text restated in an alt-text field still manufactures a Label in Name failure, and `role="button"` typed into a field is still web vocabulary. The properties panel changes the delivery, not the content — and it does not exempt a value from the gate.

### 3. Annotate the bare minimum — and the bare minimum is images and decorative elements

Start from zero annotations and add only what is forced. On a typical screen the irreducible set is just two things, and a great many screens need little else:

**Give every informative image a name.** An image is the one element whose meaning is genuinely unavailable to a developer and to VoiceOver — nothing else on screen conveys it. Describe what it communicates, not what it depicts and never its file name.

**Mark everything else decorative.** Most glyphs in a mobile UI carry no information, and the clearest case is a glyph inside a control that already has sufficient visible text:

- a `>` caret or chevron on a list row or navigation button
- a `+` on an "Add to Cart" button
- a trailing arrow on a "Continue" button
- an icon that duplicates the text beside it
- dividers, rules, background shapes, gradients, decorative illustrations
- a selected-state checkmark, where the selection is already annotated as a `Value: Selected`

For all of these: **hide them from VoiceOver and give them no name.** The visible text already names the control. The caret on `Refill >` is a visual affordance, not content — "Refill" is the whole accessible name.

Getting this wrong produces one of three real defects, which is why it earns a place in the minimum set:

- An unmarked glyph becomes **an extra VoiceOver stop that says nothing** — the user swipes onto silence and cannot tell whether something failed to load.
- Or iOS **auto-names it from the SF Symbol**, and the user hears "chevron dot right" or "plus".
- Or an annotator gives the glyph **its own label**, and the user hears "Refill, chevron right" — two stops where there should be one, with the second carrying no meaning.

Two rules that keep this from becoming clutter in its own right:

- **Mark it decorative in the properties panel, and write no callout at all.** If the image or layer has a decorative/hidden toggle, an empty-alt option, or a description field you can set to decorative, set it there. Per Principle 2 this is both the cleanest result and the one an AI can actually read — and it keeps the design free of callouts that say nothing a field could not.
- **If you must use a callout, give each element its own.** One note reading `Decorative: thumbnail, row caret, divider` looks economical and is not: it is a single text node pointing at three layers, so nothing in the file says *which* three. A developer or a code-generating AI has to infer the targets from position, which is exactly the ambiguity Principle 2 is about — and the failure mode is silent, because an unmarked glyph still renders fine. A callout must point at one element, unambiguously.

That pair is not a contradiction, it is an argument for the properties panel: a property is the design specifying itself, where a callout is a note competing for the reviewer's attention. If you find yourself needing a dozen decorative callouts, that is the signal to set them as properties instead.
- **Never write a name and "decorative" on the same element.** They are mutually exclusive. If you are unsure which an image is, ask what a sighted user loses if it disappears. Nothing lost means decorative.

### 4. Never annotate reading order unless the visual order does not make sense

VoiceOver already reads leading-to-trailing, then top-to-bottom. **A normal vertical stack of content needs no order annotation** — the default is correct, and saying so wastes an annotation and invites a developer to hand-write an order that will break the next time a layout changes.

Annotate order only when the **layout itself** breaks the expected sequence. In practice that is a narrow set:

- A **grid or multi-column layout** where elements that belong together are side by side. This is the main case. A two-column plan comparison — "Plan A / $20 / 5GB" beside "Plan B / $30 / 10GB", with the rows visually aligned — sweeps leading-to-trailing and comes out as "Plan A, Plan B, $20, $30, 5GB, 10GB". Every value is read next to the wrong label.
- **Overlapping or z-stacked content** — a badge over an image, a floating action button, a sticky overlay — where the stacking order and the visual order disagree.
- A **label positioned after its value** in the layer tree despite reading before it visually.

And when you do annotate it, **annotate containers, not element numbers.** The instruction the developer needs is "these belong together" or "finish this container before moving to the next one" — not a renumbered list of every leaf:

```
✅ Order: group each plan column as one container, read fully before the next
   column. Default sweeps across the columns and pairs every price with the
   wrong plan name.

✅ Order: "Ready" badge is part of the card heading, not a separate stop. It
   overlaps the image and would otherwise be read first.

❌ Order: 1 title, 2 price, 3 data, 4 title, 5 price, 6 data
   (per-element numbering — fragile, and every new element renumbers the rest)
```

Container grouping is both the clearer instruction and the more durable fix: it survives layout changes, where explicit per-element priorities have to be renumbered every time something is added. Reach for explicit priorities only when no grouping or restructuring can express the order.

### 5. The design is the spec; annotate only the delta

The design already specifies most of the accessible experience — the labels, the layout, the order, the control types. Annotations cover the remainder: the semantics the picture cannot carry. Your job is the difference between what a developer can see and what they need to know, and nothing else.

### 6. Fewer annotations are more accessible

This is counter-intuitive and it is the whole point. Annotations compete for a finite amount of reviewer and developer attention. Forty notes do not get read; six do. An over-annotated frame ships *more* defects than a lightly annotated one, because the notes that mattered were indistinguishable from the ones that did not. Volume is not thoroughness.

### 7. Native defaults are accessible — do not override them

iOS ships more accessibility for free than any web platform: traits on native controls, Dynamic Type on text styles, toggle states, focus order, Voice Control, the Rotor. Every annotation that restates a default invites a developer to replace working platform behaviour with hand-written code that is worse. Annotate where you need to *depart* from the default or *add* to it.

### 8. Annotate behaviour, not implementation

Say what the user must experience — "focus returns to the button that opened this sheet" — not which API to call. The developer owns the implementation and knows the codebase; a prescribed modifier is often the wrong one for their view hierarchy, and it dates. The modifier table at the end of this file exists to translate, not to be pasted into annotations.

### 9. The platform is iOS, not the web

iOS has no landmarks, no skip links, no tabindex, no hover, no breakpoints, and no `alt` attribute. Importing web vocabulary makes an annotation unimplementable and signals that the annotator does not know the platform. Use the iOS terms in the banned-vocabulary table below.

### 10. Every annotation must name a defect it prevents, and be verifiable

If you cannot state what breaks without the note, there is no note. And if a developer cannot tell whether they have satisfied it, it is not a specification — "ensure appropriate labels" and "test with VoiceOver" fail both halves of this.

---

## Rule 0 — Annotate the bare minimum

**There is no annotation quota.** There is one test, applied to each annotation on its own merits: would omitting it cause a real defect you can name? If yes, it stays — however many that leaves. If no, it goes — however few that leaves.

A fixed ceiling is the wrong instrument, and it fails in both directions. It invites deleting a *correct* annotation to satisfy a count: the gesture alternative that prevents a 2.1.1 failure is exactly as deletable as a redundant label when the only instruction is "get under ten." And on a screen that needed two, a stated allowance of ten reads as room to fill. Neither error is about volume; both come from letting a number stand in for the gate.

Most screens do land at three to six callouts. That is an observation about how little in a design is genuinely invisible — not a target to hit, and not a limit to stay under. A dense settings screen with forty rows and six sections may legitimately need more, and a simple confirmation screen may need none at all.

What keeps the set small is not counting. It is that the gate is strict and the four never-annotate principles remove whole categories before you ever tally anything: visible text as a label, traits, default reading order, and decoratives beyond image names. Apply those honestly and the number takes care of itself.

So if you find yourself with fifteen annotations, do not delete five. **Re-run the gate on all fifteen and name the defect each one prevents.** Most will not survive that, and the ones that do should stay. Volume is a symptom worth noticing — it almost always means the gate was applied loosely — but it is never itself the thing to fix. The failure the budget was reaching for is real: if everything is annotated, nothing is, because the reviewer stops reading and the three notes that mattered are lost with the forty that did not. The gate prevents that directly. A quota only approximates it.

**Properties-panel values are not callouts.** Setting alt text in a field, marking a layer decorative, or setting a heading component's level is the design specifying itself, not a note competing for attention (Principle 2). They are still bound by every content rule here: a redundant label in a field is still redundant, and a field is never a reason to annotate something you would otherwise leave alone. When a set of callouts feels heavy, the first question is not "what do I delete" — it is "which of these belongs in a property."

These limits are structural rather than numeric, and they hold at any count:

- **One callout per element, maximum.** Combine all fields for an element into one note. Never place separate "label" and "trait" and "hint" annotations on the same layer.
- **One callout, one element.** A note must point at exactly one layer. Never write a single callout covering several layers ("the icons are decorative") — nothing in the file records which layers it meant, and the association is left to guesswork.
- **Annotate a repeating component once.** A list of 12 cards, a 5-star rating, a 4-tab tab bar: annotate the first instance, then write `Applies to all N instances.` Never annotate every row.
- **Annotate a design-system component zero times** if its accessibility is already specified in the design system. Write nothing — not even `Uses DS/Button — accessibility per component spec`, which reads like a specification while containing no instruction a developer can act on. If the component's accessibility is not specified, the fix belongs in the component, not in a note on a screen that happens to use it.

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

- ❌ Every text layer's contrast ratio. Contrast is a **token** concern. Annotate it **only** where a style is off-system or sits on an image or gradient, and then on that element. A verified palette needs no annotation anywhere.
- ❌ Decorative images as callouts, when the properties panel has a decorative or hidden option. Set it there and write nothing on the canvas. If there is no field, each decorative element gets **its own** callout — never one note covering several layers, which leaves the targets ambiguous. **Principle 3.**
- ❌ "This is a button." The design shows a button. The developer will use `Button`.
- ❌ **Accessibility traits, in any form.** No `Trait: isButton`, no `.accessibilityAddTraits(...)`, no `role=`. Name the component, or fix the component in the design. See `Component:` — Principle 1's redundant-code problem applies to traits exactly as it does to labels.
- ❌ Visible text as an "accessible name" when the accessible name **is** the visible text. The default is already correct, and annotating it manufactures a Label in Name failure. **Principle 1.**
- ❌ A unique name on a generic or repeated control before checking whether `Group: combine` with the adjacent text would make it unique. Combining is one annotation; renaming is one per control.
- ❌ A name on a caret, chevron, `+`, or any glyph inside a control that already has visible text. Mark it decorative instead. **Principle 3.**
- ❌ A callout on the canvas for anything Figma has a field for — alt text, a heading level, a component variant. Put it in the properties panel. **Principle 2.**
- ❌ Heading levels, when the design uses heading components with the level visible in the Figma properties panel. The structure is already specified.
- ❌ Reading order, when the layout is a plain top-to-bottom stack. VoiceOver already does leading-to-trailing, then top-to-bottom. **Principle 4.**
- ❌ Reading order as a numbered list of individual elements. Group containers instead.
- ❌ Hints on ordinary buttons and links. See the hint rules — they are **optional** in WCAG and most users switch them off.
- ❌ Touch target size on controls that already clear **24×24pt**, the 2.5.8 AA floor. Measure first; annotate the violation, not the compliance. And do not annotate a 32pt control as a failure because it falls under Apple's 44pt guidance — it passes AA, and calling it a defect manufactures a failure that does not exist.
- ❌ Generic advice. `Ensure sufficient contrast`, `Add appropriate labels`, `Test with VoiceOver`, `Follow WCAG guidelines` are not annotations. They tell the developer nothing and cannot be checked.
- ❌ A WCAG criterion number with no instruction attached. `WCAG 1.3.1` is not a spec.

---

## The nine annotation types — this list is closed

Use **only** these keys. Do not invent fields. Do not import fields from a web annotation kit.

The **Key** column is what goes in the annotation. The **Builds to** column is the developer's side of the handoff and must never appear in an annotation — see Principle 8.

| Key | Builds to | Use when |
| --- | --- | --- |
| `Name` | `.accessibilityLabel` | There is no visible text, or it is generic/repeated **and** combining focus cannot fix it |
| `Component` | the native control — `Button`, `Link`, `Toggle`, … | The design misleads about which control this is. **Never written as a trait** |
| `Value` | `.accessibilityValue` | The element carries state or a quantity not in its name |
| `Hint` | `.accessibilityHint` | **Only** for the non-obvious interactions listed below |
| `Heading` | heading trait + level | The text is a heading **and** no heading component with a level is used |
| `Group` | `.accessibilityElement(children: .combine / .contain)` | Several layers should be one VoiceOver stop, or need a shared group name |
| `Order` | restructure, or `.accessibilitySortPriority` | The visual order genuinely disagrees with the default order |
| `Focus` | `@AccessibilityFocusState` | Focus must move or return on a screen or modal change |
| `Announce` | `UIAccessibility.post(notification:)` | A change happens without a screen transition and must be spoken |

**Where to put it.** Per Principle 2, prefer a **properties-panel field** whenever one exists for the value — an image's alt-text/description field, a heading component's `level`, a component variant. The key is then implied by the field and you write only the value.

**Format for anything with no field.** Figma's native Dev Mode annotation is a free-text note on a layer. Put these as plain `Key: value` lines inside one note, in the order above. This format works unchanged in a native annotation, in any annotation plugin, and in a handoff doc.

**Always tag the note with the Accessibility category — never leave it uncategorised.** Dev Mode lets a developer filter annotations by category, so an uncategorised accessibility note still exists but is invisible to the person who went looking for it. The category is metadata, not a note competing for attention.

**Figma HTML-escapes the annotation label.** A straight `"` renders as `&quot;` and `&` renders as `&amp;`, visibly, in the annotation card the developer reads. Use typographic quotes (`“ ”`) and write the word "and". This is worth knowing before you type a `Name:` value, since names are the key most likely to contain quotation marks.

Three practical notes for anyone writing annotations programmatically. Category IDs are **per file** — the same "Accessibility" category is a different ID in every file, so nothing can be hardcoded. And there is no API to enumerate them: `figma.root.annotationCategories` does not exist, and the only reliable way to obtain the ID is to read it off an annotation that already carries one. A file with no categorised annotation yet therefore needs one seeded by hand before a tool can match it.

```
Name: Directions, CVS Main St
Component: Link — opens Maps, leaves the app
```

Most annotations are one or two lines. If yours routinely runs to five keys, re-read the gate — you are specifying defaults.

Note what is *not* in that example: no `Trait:`, because the component is named instead; no `Hint:`, because a link's destination is obvious; and no `Name:` at all if the control had visible text.

---

## Banned vocabulary — this is where AI annotation goes wrong for mobile

Every term on the left belongs to the web. On an iOS design it is wrong, and it tells the developer you do not know the platform. Use the right column.

| ❌ Never write | ✅ Write instead |
| --- | --- |
| `alt text`, `alt=` | `Name:` |
| `aria-label`, `aria-labelledby`, `aria-describedby` | `Name:` / `Hint:` |
| `role="button"`, `role=` anything | `Component: Button` — name the component, not a role or trait |
| `.accessibilityAddTraits(.isButton)`, `isHeader`, any iOS trait API | `Component: Button` / `Heading: 2`. **Never put SwiftUI API in an annotation** |
| `aria-live`, `role="status"`, `role="alert"` | `Announce:` |
| `aria-expanded`, `aria-checked`, `aria-selected` | `Value: Expanded` / `Value: Checked` / `Value: Selected` |
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
| `role="list"`, `role="listitem"`, `aria-setsize`, `aria-posinset` | Nothing. **iOS has no list semantics.** Each row is already its own VoiceOver stop and the swipe order carries the sequence |
| `accessibilityContainerType: .list`, `List, N items`, `Announce list count` | Nothing. SwiftUI exposes **no** list role and no item count. UIKit has the enum, but it produces no such announcement and SwiftUI cannot reach it. If the count genuinely matters, put it in the section heading — `Heading: 2 "People you care for (3)"` |

Two more mobile-specific traps:

- **Do not annotate a "mobile breakpoint."** An iOS app has size classes and Dynamic Type, not breakpoints. Reflow is driven by text size at least as often as by width.
- **Do not annotate orientation as fixed.** Never write `Portrait only`. Locking orientation fails WCAG 1.3.4 and breaks users with a wheelchair- or arm-mounted device. If a screen is designed portrait-first, annotate `Supports portrait and landscape; content scrolls in landscape.`

---

## Per-type rules

### `Name:` — the accessible name

See Principle 1 — read it before using this key at all.

- **Omit it entirely when the visible text is already the name.** This is the single biggest source of over-annotation.
- **Omit it when `Group: combine` would make the control unique.** For a generic or repeated label — "Edit", "Refill", "Learn more" — combining the control with its adjacent text is the better fix: "Email Address, Edit" is unique without a single label annotation. Only annotate a unique name once combining is ruled out, and say why in the annotation ("combining would swallow the card heading").
- 1–3 words where possible. Capitalized. **No trailing period.**
- **Never include the role**: no "button", "icon", "image", "link", "tab", "graphic", "menu". VoiceOver speaks the component's role itself, so "Delete button" is heard as "Delete button, button".
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

### `Component:` — name the component, never the trait

**Do not annotate accessibility traits.** Name the component the design uses, in design-system or Figma terms: `Button`, `Link`, `Tab`, `Toggle`, `Text field`, `Checkbox`, `Radio`, `Segmented control`, `Stepper`, `Slider`, `Search field`, `Modal sheet`, `Image`.

The reason is the same one that governs labels (Principle 1): a trait written as iOS API gets implemented as iOS API. A developer handed `Trait: Button` or `.accessibilityAddTraits(.isButton)` will add that modifier — to a `Button`, which already has the trait. The result is redundant code, and in the worse cases a hand-rolled control carrying a manually-applied trait where a native control was available. Naming the component instead gives the developer the one instruction that matters: **use the native control**, and the trait comes with it for free, correctly, on every OS version.

```
✅ Component: Link
✅ Component: Segmented control
❌ Trait: isButton
❌ Trait: .isHeader
❌ Add .accessibilityAddTraits(.isButton)
❌ role="button"
```

- **Best of all: fix it in the design and annotate nothing.** If the Figma file has a Button component, use the Button component. A correctly-chosen component needs no annotation at all, and this is the preferred outcome — see Principle 2. Failing that, set the component variant as a property rather than writing a callout.
- **Omit it when the component is obvious.** A rectangle with centered text is a button, and the developer will build a `Button`. Annotate only where the design **misleads**: text that navigates but does not look tappable, a whole row that acts as one button, a custom control imitating a native one, or an off-system element with no component behind it.
- **`Button` vs `Link` is a real distinction on iOS, and worth annotating.** `Link` is for anything that leaves the app or opens a URL — a web page, Mail, Maps, the App Store. In-app navigation is a `Button` or `NavigationLink`. The two look identical in a design and getting it backwards is a genuine WCAG 4.1.2 defect, so name it: `Component: Link — opens Maps, leaves the app.`
- If a control is drawn greyed out or dimmed, annotate `Component: Button, disabled state` so the developer marks it genuinely disabled rather than only styling it. A control that looks disabled but is not is a defect only AT users hit.

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

### `Heading:` — annotate unless the design already carries levels

Figma renders a heading and a large bold label identically, so by default this is genuinely invisible and belongs in almost every screen's annotations. **Headings are the one thing you should expect to annotate** — they are the most commonly missed semantic on shipped iOS screens, and a screen with no heading structure has no Rotor navigation at all.

**The exemption:** if the design already uses a **heading component whose level is visible in the Figma properties panel** — a `Heading/H2` component, or a heading component with a `level` property — the structure is already specified and **you annotate nothing.** The design is the spec; do not restate it. This is the better outcome, and if a design system has heading components, pushing designers toward them beats annotating every screen forever.

Annotate when the heading is plain styled text, an off-system text layer, or a component with no level exposed.

- Mark **every** heading, and give its level: `Heading: 1`, `Heading: 2`, …
- The level is an **iOS heading level**, not markup and not a trait. Never write `H2` as a tag, and never write `.isHeader` or `accessibilityHeading` — see `Component:` above for why naming the API backfires.
- **Do not skip levels.** 1 → 2 → 3, never 1 → 3.
- The screen's **navigation title is the page title**, not a heading. SwiftUI derives it from the visible title, so annotate nothing unless the spoken title must differ from the one on screen. The first heading inside the content starts at level 1.
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

See Principle 4 — this is the type most often annotated when it should be left alone.

- VoiceOver defaults to leading-to-trailing, then top-to-bottom. **For a normal stacked layout, write nothing.** The default is already right.
- Annotate order **only** where the layout itself disagrees with that default: a **grid or multi-column layout** whose columns get interleaved, overlapping or z-stacked content, a floating element, a label positioned after its value in the layer tree, content that must be read before a sticky overlay.
- **Express it as containers, not element numbers.** Say which elements group together and which group is read first, and name what the default gets wrong: `Order: group each plan column as one container, read fully before the next. Default sweeps across the columns and pairs every price with the wrong plan.` Never hand over a renumbered list of leaves — it is fragile, and every element added later renumbers the rest.
- Prefer the fix that survives: **restructure the layout, or use `Group: contain`, before asking for explicit sort priorities.** Only annotate explicit priorities when no grouping or restructuring can express the order.
- Never call this "tab order."

### `Focus:` — where VoiceOver focus goes

Invisible in a static design and a frequent real-world defect, so annotate it whenever the design includes a sheet, modal, alert, popover, or an expanding section.

- On open: `Focus: moves to the sheet title on open.`
- On close: `Focus: returns to the "Refill" button that opened the sheet.` Without this, focus lands unpredictably — usually at the top of the screen — and the user loses their place.
- For an inline expansion: `Focus: stays on the disclosure control; Value changes to "Expanded".`
- Annotate `Component: Modal sheet` so VoiceOver does not wander into the content behind it.
- If a sheet's content could exceed the screen at large text, add `Scrolls` — a modal that cannot scroll is unusable at accessibility text sizes.

### `Announce:` — changes with no screen transition

Use when something changes on screen and VoiceOver would otherwise say nothing: validation errors appearing, a filter changing a result count, async content finishing, a cart total updating, a toast.

- Write the announcement text and its scope: `Announce: "3 results" when the filter changes. Layout change — does not move focus.`
- Use `Screen change` only when the whole screen's content is replaced; `Layout change` for a region.
- An error must **also** be visible text associated with its field — an announcement is not a substitute. Annotate both: `Error text below the field, programmatically associated. Announce on validation failure.`
- **`Announce:` is not a route to a list role.** `Announce: "List, 3 items"` reads as compliant — it contains no banned term and this key does map to a real API — but it specifies something SwiftUI cannot produce, so the developer either ignores it or hand-rolls a fake announcement on appear. The same applies to any count of static content that was never going to change. This key is for a change the user must hear: an error appearing, a result count changing, async content arriving. If nothing changed, there is no `Announce:`.

---

## Where each screen-wide fact goes — there is no screen-level block

Every annotation belongs **on the element it is about**: in that element's properties panel where Figma exposes a field, and as an annotation on the element where it does not. There is no separate collected note for the screen.

A screen block is tempting, because it gives a home to facts with no obvious owner. In practice it fails three ways. It renders in Dev Mode as a single oversized card laid over the design, so the reviewer can read neither. It makes that reviewer hold a list in their head and map it back onto layers by eye — the same association problem Principle 2 is about, one level up. And because it is the one place no single element has to answer for, it fills with compliance statements: "contrast verified", "all targets pass", "portrait and landscape supported". None of those name a defect, and the gate already forbids every one of them.

Each fact has an owner:

| Fact | Where it goes |
| --- | --- |
| Page title | Nowhere. The navigation title is visible text and SwiftUI derives it. Annotate only if the spoken title must differ from the visible one |
| Heading levels | On each heading element — the `level` property where heading components are used, otherwise `Heading: N` on that text layer |
| Dynamic Type reflow | On the element that must reflow: the row, the card, the two-column strip. `No fixed height, no line limit, must not truncate at AX5` |
| Orientation | Nowhere — unless the screen is locked to one orientation, which is a 1.3.4 defect. Then annotate the frame and name the failure |
| Contrast | On the failing element only. A verified palette is not an annotation |
| Touch targets | On the element below 24×24pt only. Compliance is not an annotation |
| Motion | On the element that animates |
| Design-system components | Nowhere. A DS component is annotated zero times, and `per component spec` is not an annotation — it is the absence of one |

That last row repays a second look. `Uses DS/Button — accessibility per component spec` reads like a specification and contains no instruction; there is nothing a developer can do with it. If the component's accessibility is specified, say nothing at all. If it is not, the fix belongs in the component, not in a note attached to one screen that happens to use it.

**The frame is an element too.** When a fact genuinely is screen-wide *and* genuinely names a defect — an orientation lock, a layout that cannot survive AX5 anywhere — annotate the frame. That is rare, and both of those examples are things you would rather fix in the design than document.

Three notes on the facts above:

- **Dynamic Type is reflow intent, not a pixel spec.** iOS body text goes from 17pt to roughly 53pt at the largest accessibility size — over 300%, well past the 200% WCAG requires. Do not annotate a target pixel size; annotate what must not happen: no truncation, no fixed heights, no one-line limits, and text containers that grow. If a layout genuinely cannot survive it, design and annotate the large-text variant rather than writing `text may truncate`.
- **Touch targets: the threshold you annotate against is 24×24pt**, the WCAG 2.2 AA floor (2.5.8). 44×44pt is Apple's HIG guidance and WCAG's AAA criterion (2.5.5) — worth recommending, never worth reporting as a defect. A 32pt control conforms; annotating it as a failure is the same manufactured-failure error as retyping a visible label. Targets inline within a line of text are exempt. Measure the design and annotate only what falls below 24×24pt. If a design is systematically under 44pt and the team wants Apple's number, that is a design-system conversation, not a per-screen annotation.
- **Contrast:** 4.5:1 for body text, 3:1 for large text (18pt+, or 14pt+ bold), 3:1 for icons, borders, and other meaningful non-text. Annotate the measured ratio only for the exceptions.

---

## Worked example

A prescription card: thumbnail, "Ready for pickup" badge, drug name, store name, a `Refill >` button with a trailing caret, a Directions icon button, a divider, and swipe-to-archive. Twelve of these in a list.

### ❌ What AI typically produces — 32 annotations, nearly all wrong

```
1.  Image: alt text "prescription bottle icon"
2.  Badge: role="status", aria-live="polite", text "Ready for pickup"
3.  Badge: contrast 4.6:1 — passes
4.  Drug name: H3, aria-label "Atorvastatin 20mg", contrast 15.2:1 — passes
5.  Store name: static text, contrast 7.1:1 — passes
6.  Refill: role="button", aria-label "Refill button", tabindex 1,
    hint "Tap to refill this prescription"
7.  Caret: role="button", aria-label "chevron right icon", tabindex 2
8.  Directions: role="button", aria-label "Directions icon",
    hint "Double tap to get directions"
9.  Divider: aria-hidden="true"
10. Card: landmark region "prescription", aria-describedby drug name
11. Card: tab order 1 → 2 → 3 → 4 → 5 → 6
12. Card: ensure sufficient color contrast (WCAG 1.4.3)
13. Card: add appropriate ARIA labels (WCAG 4.1.2)
14. Card: test with screen reader
15–28. [the same fourteen annotations repeated on each of the other eleven rows]
29. List: mobile breakpoint 390px
30. Screen: portrait only
31. Screen: text may truncate at large sizes
32. Screen: skip to content link at top
```

What is wrong with it:

- **The entire web vocabulary** (1, 2, 6, 7, 8, 9, 10, 11, 32) does not exist on iOS — `alt`, `aria-*`, `role=`, `tabindex`, landmarks, skip links.
- **Roles SwiftUI gives for free** are annotated anyway (6, 8).
- **Names restate or contradict the visible text** (6, 8). "Refill button" puts the role in the name and will be heard as "Refill button, button"; "Directions icon" does the same with a word VoiceOver never needed.
- **The caret is given its own label** (7). It is a visual affordance on a button that already says "Refill" — annotating it creates a second VoiceOver stop that announces "chevron right icon" and means nothing. It should be hidden.
- **Both hints name the gesture, and neither was needed** (6, 8) — "Tap to", "Double tap to".
- **Contrast is annotated where it passes** (3, 4, 5) and generically where it cannot be checked (12).
- **Four annotations are unactionable** (12, 13, 14, 31) — "ensure", "appropriate", "test with", "may truncate".
- **Twelve identical rows are annotated twelve times** (15–28), which is where more than half the volume comes from.
- **Portrait-only fails WCAG 1.3.4** (30), and breakpoints are not an iOS concept (29).

And every defect that would actually ship on this screen is missing: the badge is never spoken, because an iOS badge is not read by VoiceOver on its own; the heading level is unknown; 24 identically-named icon buttons are indistinguishable in the swipe order; swipe-to-archive is undiscoverable and has no alternative; and nothing says how the card groups.

### ✅ Correct annotation set — 5 properties + 5 annotations, no screen block

**In the properties panel — nothing on the canvas.** Set on the first row's layers; the component carries them to all 12.

```
"Your prescriptions"  → Heading component, level 1
Drug name             → Heading component, level 2
Thumbnail             → decorative / hidden
Refill caret          → decorative / hidden   ("Refill" already names the button)
Divider               → decorative / hidden
```

**Annotations, each on the element it is about — one per element.**

```
① RX CARD  — applies to all 12 rows
Group: contain — heading and both buttons stay individually focusable.
Dynamic Type: card reflows to a vertical stack, button full width. No fixed
heights, no line limits.

② "Ready for pickup" BADGE
Value: merge into the card heading — "Atorvastatin 20mg, ready for pickup".
Reason: an iOS badge is not spoken on its own, and the status must not become a
separate VoiceOver stop.

③ REFILL BUTTON
Name: "Refill, Atorvastatin 20mg"
Reason: 12 identical "Refill" buttons are unusable in the swipe order. Combining
the button with the drug name would fix it without a label, but that would
swallow the level-2 heading and cost the Rotor — so a unique name it is.
Visible text comes first, so Voice Control still works.

④ DIRECTIONS BUTTON
Name: "Directions, CVS Main St"
Component: Link — opens Maps, leaves the app.

⑤ SWIPE TO ARCHIVE
Hint: "Archives this prescription."
Gesture alternative: required. Add "Archive" to the row's accessibility actions
and to the "More" menu — a swipe-only action fails WCAG 2.1.1 and 2.5.1.
```

Five callouts instead of thirty-two, and every one of them tells the developer something the design does not.

Note where the reduction came from. The screen block is gone: its heading levels became properties on the heading layers, its reflow intent moved onto the card that has to reflow, and the rest of it — page title, orientation, contrast, target size, motion, "per component spec" — was compliance rather than specification and so is written nowhere at all. Five facts moved into properties, where they are the design specifying itself rather than notes competing for attention, and where an AI can read them off the layer they belong to. No label survives on a control whose visible text was already correct. There are no trait annotations at all. No contrast or target-size notes, because none of them fail. The repeating row is annotated once. And the five that remain are each about a *relationship* — a grouping, a badge that must merge into a heading, two names that need sibling context, and a gesture that needs an alternative — which is precisely the class of thing no properties field can hold.

Note also what the one-callout-one-element rule changed: the two buttons get separate notes even though their reasoning is nearly identical, because a single note spanning both would leave a developer guessing which name belongs to which button.

---

## Self-check before you deliver

Run every annotation through this. Delete, do not soften.

1. **Look at the total.** There is no quota, so never delete down to a number — but a large set is a reliable sign the gate was applied loosely. If you are past six, re-read the gate and the four never-annotate principles before going further; most of the surplus usually fails one of them.
2. **Every callout — could it be a properties-panel field instead?** Alt text, heading level, component variant: move it. Only cross-element concerns (`Group`, `Order`, `Focus`, `Announce`, gesture alternatives) stay as annotations.
3. **Grep your own output** for: `alt`, `aria`, `role=`, `tabindex`, `landmark`, `skip to`, `H1`–`H6`, `px`, `rem`, `breakpoint`, `hover`, `focus ring`, `tab order`, `screen reader`, `double tap`, `click`. Every hit is a rewrite.
4. **Every `Name:` on a control that has visible text** — delete it unless the text is generic or repeated. If it is, could `Group: combine` with the adjacent text make it unique instead? If yes, delete the name and group instead. If no, say why in the annotation.
5. **Every surviving `Name:`** — does it contain the visible text, verbatim and first? Is it free of "button", "icon", "image", "link"? No trailing period?
6. **Any SwiftUI or trait API in your output?** Grep for `accessibility`, `.is`, `Trait:`, `AddTraits`, `isButton`, `isHeader`. An annotation naming an iOS API gets implemented as redundant code. Rewrite as `Component:` or `Heading:`.
7. **Every `Component:`** — is it a component name, and is it non-obvious? If the design already uses the right Figma component, delete the annotation.
8. **Every informative image** — does it have a name, set in its alt-text field if one exists? **Every glyph, caret, `+`, chevron, and divider** — is it marked decorative with no name, in the properties panel if possible?
9. **Every callout — does it point at exactly one element?** A note covering several layers ("these icons are decorative", "both buttons get…") must be split, one per element, or the targets are guesswork.
10. **Every `Hint:`** — is this one of the five required interactions? If not, delete it. If so: third person, no gesture named, ends with a period, does not repeat the name?
11. **Every custom gesture** — does it have a visible single-tap alternative annotated?
12. **Every `Group:` with a name** — does it say `contain`?
13. **Every heading** — does it have a level, and do the levels run without skipping? If the design uses heading components with levels in the properties panel, delete these annotations.
14. **Every modal, sheet, and alert** — is focus-on-open and focus-on-return annotated?
15. **Every badge, star rating, stepper, and expandable** — does it have a `Value:`?
16. **Every repeated component** — annotated once, with `Applies to all N`?
17. **Every `Order:`** — would the default top-to-bottom order genuinely be wrong here? If not, delete it. If so, is it expressed as containers rather than numbered leaves?
18. **Anything unactionable** — "ensure", "appropriate", "consider", "test with", a bare WCAG number? Delete it.
19. **Any contrast or target-size note on something that passes?** Delete it.
20. **Any list semantics?** Grep for `role="list`, `listitem`, `setsize`, `posinset`, `containerType`, `list count`, and `"List,`. iOS has none of it — not as a role, not as a trait, not as a count. Delete the annotation; if the count matters, it goes in the section heading. Note that `Announce: "List, 3 items"` passes steps 3 and 6 cleanly, so this step is the only one that catches it.

    **Grep those tokens, not the bare word "list".** Describing a design in English is fine and common — "a list of 12 cards", "the row styling reads like a list row", `grouped-list` as a component name. None of those claim a semantic, and a grep for bare `list` flags every one of them, including ten in this file. What is banned is asserting a **role, container type, or item count** that iOS does not have. If you cannot tell which you are looking at, ask whether a SwiftUI developer could implement it: `Component: Button` is implementable, `accessibilityContainerType: .list` is not.
21. **Is every annotation tagged with the Accessibility category?** An uncategorised note is invisible to a developer filtering by category.
22. **Finally:** for each surviving annotation, name the defect it prevents. If you cannot, it should not ship.

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
| `Name`, `Component`, `Value` | 4.1.2 Name, Role, Value |
| `Announce` | 4.1.3 Status Messages |

---

## Handing off to engineering

These annotations map onto SwiftUI as follows. For the implementation rules the developer should follow — and for an AI coding assistant building from these annotations — use **[SKILL.md](SKILL.md)** in this repository, and verify the result with **[a11y-check](a11y-check/README.md)**.

⚠️ **This table is for the developer, not for the annotation.** Never paste a modifier name into a Figma annotation. Note too that the right column is mostly *native controls*, not accessibility modifiers: picking the right view satisfies most of these with no accessibility code at all, and adding a modifier on top of a native control is the redundancy this file exists to prevent.

| Annotation | SwiftUI |
| --- | --- |
| `Name` | `.accessibilityLabel("…")` |
| `Component: Button` | `Button { }` — the trait is automatic, do **not** add `.accessibilityAddTraits(.isButton)` |
| `Component: Link` | `Link("…", destination:)` — trait automatic |
| `Component: Button, disabled state` | `.disabled(true)` |
| `Component: Modal sheet` | `.sheet()` / `.fullScreenCover()` |
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
| Touch targets | `.frame(minWidth: 24, minHeight: 24)` to conform (2.5.8); `44` to follow Apple's HIG |
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
