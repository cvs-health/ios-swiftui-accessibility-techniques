# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Versioning

This repository ships two products on independent release schedules, so they have independent version lines:

| Product | Scheme | Released via | Current |
| --- | --- | --- | --- |
| iOS app | `26.x` | App Store | **26.7** |
| `a11y-check` CLI | semver | Homebrew and git tags | **0.7.0** (tag) |

Rules:

- **A version header means something shipped.** Create `## [iOS 26.7]` only when a build is submitted to the App Store, and `## [a11y-check 0.5.0]` only when the CLI is tagged and released. Ordinary commits never get a version.
- **Prefix the product**, so `26.x` and `0.x` headers cannot be confused for one another.
- **One `## [Unreleased]` section, undated.** Everything accumulates there until it ships. Do not add a new dated `[Unreleased]` header per batch of work — that is how this file ended up with six of them, and how the `26.7`, `26.8`, and `26.9` headers below came to describe work that was never released to the App Store (`26.9` is CLI-only changes filed under an app version number).
- At release time, rename `[Unreleased]` to the version header for the product that shipped, move any entries belonging to the *other* product into a fresh `[Unreleased]`, and start over.

## [Unreleased]

iOS app changes made after 26.7 shipped and CLI changes made after `a11y-check` 0.7.0. Not yet in the App Store or tagged.

### iOSswiftUIa11yTechniques

#### Added

- **New `FIGMA-ANNOTATIONS-SKILL.md`**, a second skill file covering the *design* stage, where `SKILL.md` covers the code stage. It is the rule set an AI must follow when asked to annotate an iOS design in Figma for accessibility.

  The file exists because AI design annotation fails in three consistent ways, and generic WCAG guidance does not address any of them:

  - **Volume.** It annotates every layer, including everything the design already says — "this is a button" on a button, a passing contrast ratio on every text node, the visible label as the accessible name. Forty notes where six belong, which means the reviewer stops reading and the ones that mattered are lost. Countered with a hard ceiling of 10 element annotations per screen, one annotation per element, one annotation per repeating component, and zero for design-system components whose accessibility is already specified.
  - **Platform.** It annotates iOS designs in web ARIA vocabulary: `alt text`, `aria-label`, `role="button"`, `aria-live`, `tabindex`, landmark regions, skip links, `H1`–`H6` as HTML tags, `px`, breakpoints, hover states, focus rings. Landmarks and skip links do not exist on iOS at all. Countered with a 20-row banned-vocabulary table mapping each term to its iOS equivalent, plus two mobile-specific traps — breakpoints (iOS has size classes and Dynamic Type) and `Portrait only`, which fails 1.3.4 for anyone with a mounted device.
  - **Content.** The annotations that survive are wrong on their own terms: roles inside labels ("Refill button", heard as "Refill button, button"), labels that do not contain the visible text and so fail 2.5.3 Label in Name, hints on every control when hints are optional and most users switch them off, hints that name the gesture ("Double tap to…") when VoiceOver already says that, headings faked by putting "heading" in the label so they never reach the Rotor, and group labels without `children: .contain`, which silently overrides every child control's visible name. Countered with exact grammar per annotation type.

  Structure: ten stated principles; a closed set of nine annotation types (`Name`, `Component`, `Value`, `Hint`, `Heading`, `Group`, `Order`, `Focus`, `Announce`) expressed as `Key: value` lines, which work unchanged in a native Figma Dev Mode note, in any annotation plugin, or in a handoff doc; a four-question gate that must return "name the defect this prevents" before an annotation may be written; explicit annotate / never-annotate lists; a screen-level block that absorbs what AI otherwise spreads across dozens of element notes (page title, heading structure, Dynamic Type reflow intent, orientation, contrast, target size, motion, components); a 22-step self-check including three greps of the model's own output, one for web terms, one for SwiftUI API and one for list semantics; a WCAG 2.2 criterion table; and a modifier table mapping every annotation to the SwiftUI it builds to, so design and engineering share one vocabulary.

  One principle governs *where* an annotation lives rather than what it says, and it is the one that matters most for AI-assisted work: **put the value in the Figma properties panel, not a callout on the canvas.** Select the image and type the alt text into its description field; set a heading component's `level`; set the component variant. The reason is that a property is structured data attached to the layer, while a canvas callout is a separate text node that merely sits near something, joined by a line no tool can follow — so an AI generating an accessible prototype or SwiftUI code can read a property reliably and can only guess at a callout's target, and guessing wrong silently puts the alt text on the wrong image. Properties also travel with the layer through instance swaps and reflows, where callouts detach or end up pointing at a neighbour, and they keep the canvas readable. The order of preference is fix the component → set the property → write a callout, with callouts reserved for the cross-element concerns no single field can hold: `Group`, `Order`, `Focus`, `Announce`, gesture alternatives, and the screen block. The file is explicit that this is not a loophole — a redundant label is still redundant in a properties panel, and the budget does not rise.

  Four more principles are "do not annotate this" rules, because each names a case where the annotation is not merely wasted but actively harmful:

  - **Never annotate visible text as a label.** The failure is not only clutter. A retyped label is rarely byte-identical to the visible text — "Refill" becomes "Refill prescription", "Done" becomes "Save" — and the moment it differs, the accessible name no longer contains the visible label, so the annotation *manufactures* a 2.5.3 Label in Name failure in code that was already correct. It also produces redundant code: a developer handed `Name: Refill` writes `.accessibilityLabel("Refill")` on a `Button("Refill")`, and the same string now exists twice, is localized twice, and will be updated in one place only.
  - **Never annotate traits.** The same mechanism, one level up. `Trait: Button` or `.accessibilityAddTraits(.isButton)` in an annotation gets implemented as that modifier, on a `Button` that already has the trait. The key is therefore `Component:`, which names the design-system component (`Button`, `Link`, `Segmented control`) and carries the one instruction that matters — use the native control, and the trait arrives for free. Best case is that the designer picks the right Figma component and the annotation disappears entirely.
  - **Never annotate default reading order.** A plain vertical stack is already correct. The narrow real case is a multi-column or grid layout whose columns interleave — a two-column plan comparison sweeps leading-to-trailing and reads "Plan A, Plan B, $20, $30", pairing every price with the wrong plan. And the fix is annotated as *containers* ("group each column, read fully before the next"), never as a numbered list of leaves, which is fragile and renumbers whenever an element is added.
  - **Annotate the bare minimum, which is images and decoratives.** An informative image's meaning is the one thing genuinely unavailable to both a developer and VoiceOver, so it needs a name. Everything else — a `>` caret, a `+` on an "Add to Cart" button, a trailing arrow on "Continue", dividers — gets hidden with no name, because the visible text already names the control. Leaving a glyph unmarked produces an empty VoiceOver stop, or an auto-name read as "chevron dot right"; annotating it produces "Refill, chevron right". The preferred delivery is the properties panel — mark the layer decorative in its field and write no callout at all — and when no field exists, **each decorative element gets its own callout**. A single note reading `Decorative: thumbnail, caret, divider` looks economical but records nothing about which three layers it meant, which is the same ambiguity the properties-panel principle is about, with a failure mode that is silent because an unmarked glyph still renders fine.

  Two more points are deliberately argued rather than asserted, because both are places the existing guidance in this repo is more specific than the WCAG text:

  - **Hints are optional**, so a hint can never be the only place information lives. The file names the five interactions where one is genuinely required — long press, row swipe actions, drag and drop, context menu, custom gesture — and tells the model to delete every other hint. Each of those five also requires a visible single-tap alternative, annotated as part of the design, since a gesture-only control fails 2.1.1 and 2.5.1 regardless of how well it is hinted.
  - **Dynamic Type is annotated as reflow intent, not a pixel target.** Body text runs 17pt to roughly 53pt at AX5, over 300% and well past the 200% that 1.4.4 requires, so a target size is the wrong spec. The annotation states what must not happen — no truncation, no fixed heights, no single-line limits — and if a layout cannot survive it, the instruction is to design the large-text variant rather than annotate `text may truncate`.

  Headings are the one semantic the file expects to be annotated on most screens, since Figma renders a heading and a large bold label identically and a screen with no heading structure has no Rotor navigation at all. The exemption is a design that uses heading components with the level exposed in the properties panel, in which case the structure is already specified and nothing is annotated.

  Two fix-order rules keep the budget from being spent on near-duplicates:

  - For a **generic or repeated label** — a column of "Edit" buttons, twelve "Refill" buttons — try combining focus before adding unique names. "Email Address" + "Edit" combined is one stop reading "Email Address, Edit", already unique, with no duplicated strings and nothing to resync when the field is renamed. Unique names are the fallback for when combining would swallow a heading, merge two distinct actions, or has nothing adjacent to combine with. The order is: fix the component → combine focus → annotate a unique name.
  - For **grouping**, `combine` and `contain` are not interchangeable, and a group *name* without `contain` silently overrides every child control's visible name — a 2.5.3 failure introduced by the annotation.

  Two limits follow from the properties-panel principle and are stated in the budget rule. The ceiling of 10 counts **callouts**, not properties-panel values — a field entry is the design specifying itself, not a note competing for attention, so being over the ceiling prompts "which of these belongs in a property" before "what do I delete". And **one callout points at exactly one element**: a note spanning several layers leaves no record of which layers it meant.

  The worked example is a 12-row prescription list, shown first as the 32-annotation output AI typically produces with each error attributed, then as the correct set — 4 properties, 5 callouts, and one screen block. The point of the pairing is that the 32 notes miss every defect that would actually ship on that screen: the badge is never spoken (an iOS badge is not read by VoiceOver on its own), the heading level is unknown, 24 identically-named icon buttons are indistinguishable in the swipe order, and swipe-to-archive is undiscoverable with no alternative. The correct version splits the two halves explicitly — thumbnail, caret, divider, and heading level set as properties with nothing on the canvas; five callouts for the things that are *relationships* and so cannot live in any field. The one-callout-one-element rule is visible in it too: the Refill and Directions buttons get separate notes despite nearly identical reasoning, because one note spanning both would leave a developer guessing which name belongs to which button.

  Filed under the app rather than the CLI: it is project documentation, like `SKILL.md`, and ships no rule the checker can run. Static analysis sees Swift, not Figma.

- **`FIGMA-ANNOTATIONS-SKILL.md` is now installable as a skill, where before it could only be pasted.** Two things stopped it loading. Its frontmatter `name` was `iOS Accessibility Design Annotations` — title case with spaces, where a skill name must be kebab-case and match its containing directory — and the file sat at the repository root rather than in a skills directory, which is the only place a skill is discovered. Renamed to `figma-a11y-annotations` and exposed at `.claude/skills/figma-a11y-annotations/SKILL.md`.

  The new path is a **symlink to the root file, not a copy**, so there is one source of truth. A 663-line rule set duplicated across two paths in the same repository drifts, and the drift is silent: the pasted copy and the loaded copy would disagree about the annotation budget with nothing to flag it. Verified that skill discovery resolves the symlink.

  Nothing moved, so the `FIGMA-ANNOTATIONS-SKILL.md` link in `README.md` still resolves and the paste-into-Figma-AI workflow is unchanged. Only the H1 carries the human-readable title now; the `name` field is an identifier, and it was being used as a heading.

  `SKILL.md` at the root has the same two problems — `name: iOS SwiftUI Accessibility` and no skills directory — so the README instruction to copy it into `~/.claude/skills/` does not currently produce a loadable skill. Left alone here rather than fixed in passing, because renaming it changes the identifier for anyone who has already installed it and that deserves its own change.

- **New Show Borders technique** (`ShowBordersView.swift`, `Documentation/ShowBorders.md`), the sixth preference-detection technique alongside Increase Contrast, Reduce Transparency, Reduce Motion, Smart Invert, and Dim Flashing Lights. The setting previously appeared in the repo only as a status row in `ATdetectionView.swift`, with no technique page.
  - Titled for the current Settings label. Reading `BUTTON_SHAPES` from `AccessibilitySettings.bundle` across the installed simulator runtimes shows `Button Shapes` on iOS 26.0 and `Show Borders` on 26.3, 26.4, 26.5, and 27.0. Only the label changed: the preference key is still `BUTTON_SHAPES` and the API is still `accessibilityShowButtonShapes`. The page and the docs both record the old name so the Settings steps work on either version.
  - Both examples are the basic SwiftUI `Button` with a text label, which renders as plain tinted text with no border or fill. They are identical while the setting is off and differ in two modifiers.
  - Good example: `.frame(minHeight: 44)` with no fixed width. With the setting on it adds padding and strokes a border in `Color.accentColor`, and grows to fit so the label is not clipped.
  - Bad example: a hardcoded frame with `.lineLimit(1)`. It reserves horizontal room with the setting on but draws no border, and the fixed width forces that room out of the label, so "Add to Cart" truncates to "Add to…". Carries one deliberate `line-limit-1` error (1.4.4), the only finding in the file.
  - The bad example's frame and reserved room use `@ScaledMetric` rather than raw points. A first attempt hardcoded `width: 100`, which left about 13pt of slack at the default text size and none above it: at Dynamic Type XXL the label measures 104pt, so it truncated with the setting off and demonstrated a Dynamic Type bug instead. Scaling the frame and the reserved room together holds the relationship at every text size, verified by measuring the label against the frame across all twelve content size categories (`offFits` and `onTruncates` both true from `extraSmall` through `accessibilityExtraExtraExtraLarge`).
  - The docs are scoped to SwiftUI and to the mechanics of the setting. Earlier drafts carried two incorrect WCAG claims, both now gone: that a text-only button fails 1.4.1, and that the border must meet 3:1 for 1.4.11. Neither holds — a standalone button is distinguished by position and label as well as color, and 1.4.11 does not require a boundary on a control that has visible text. Both criteria are off the list; 1.4.4 Resize Text is the one the examples exercise. UIKit API links were also dropped, since this is a SwiftUI techniques project.
  - Both states of both examples were verified by rendering the view with the `accessibilityShowButtonShapes` branches inverted, because the setting cannot be set programmatically. `accessibilityShowButtonShapes` is read-only so it cannot be set with `.environment()` in a `Preview`, and writing `com.apple.Accessibility ButtonShapesEnabled` via `simctl` has no effect even across a simulator reboot.

#### Fixed

- **Unresolved merge conflict markers committed into `SKILL.md`.** `<<<<<<< HEAD`, `=======`, and `>>>>>>> 40d6936` were live on `main` inside the Reading Order / Grouping section, so the published coding skill — the one the README tells people to copy into `~/.claude/skills/` — shipped with raw conflict markers and a duplicated rule.

  Resolved as the union of both sides rather than by picking one, since each carried something the other lacked. The feature side contributed the `children: .contain` plus container-label rule for groups of related buttons, which documents the shipping `button-group-missing-container-label` rule; HEAD contributed the fuller ZStack source-order prose, the note that overusing `.accessibilitySortPriority()` across many elements makes reading order unmaintainable (which documents `sort-priority-overused`), and the code examples. Both of those rules were confirmed present in `a11y-check --list-rules` before resolving, so neither bullet could be dropped. The two sides' ZStack bullets were duplicates and HEAD's are strict supersets, so only one copy survives.

  Also added the warning that was in neither side but is in the project's own `GroupingControls.md`: a container `.accessibilityLabel` *without* `.accessibilityElement(children: .contain)` overrides the visible label text of every control inside the group and causes a Label in Name failure (2.5.3). It now has a good/bad code pair, since it is the kind of mistake that reads as correct.

  The commit the marker named, `40d6936`, no longer exists in the repository — it was rebased away — so the conflict could not be re-resolved with `git` and was resolved from content.

- **Two real contrast failures inside good examples**, found once the contrast rule could see them. Classifying all 25 `color-contrast-insufficient` findings showed 23 on bad examples and 2 on good ones, both genuine:
  - **Tabs** (`TabsView.swift`): the unread badge in the good custom-tabs example used white on `Color.red`, which is 3.5:1 — short of the 4.5:1 its small bold text requires. Now uses the crimson the file already defines. The badge being `.accessibilityHidden(true)` does not excuse it: 1.4.3 protects low-vision sighted users, not VoiceOver users, and the count is conveyed visually. The matching bad example keeps `Color.red` deliberately.
  - **A11y-check** (`A11yCheckView.swift`): the good gesture-alternative example's `Button("Delete")` used `.foregroundColor(.red)`, 3.5:1 against the default background — a good example of WCAG 2.5.1 that failed 1.4.3. Now crimson, which clears 4.5:1 against both the light and dark backgrounds, so no `colorScheme` ternary is needed. Verified with the tool rather than by hand; an initial hand-estimate of crimson-on-black was wrong.
- **`WebViewDocs.updateUIView` reloading the documentation on every SwiftUI update** (`ContentView.swift`). The method called `webView.load(URLRequest(url: url))` on each update, resetting the page and discarding the web view's back-forward list. `url` is a constant, so the body is now empty. No visual change.

- **`FIGMA-ANNOTATIONS-SKILL.md` had no coverage of list semantics, so it passed the one web-platform error its banned-vocabulary table was built to catch.** Found by pointing the skill at a real annotated CVS file rather than a synthetic fixture: the existing AI annotations on the H100 Caregiving landing page used `accessibilityContainerType: .list` with `Announce list count: "List, 2 items"` twice, and nothing in the skill rejected either.

  The word "list" appeared ten times in the file before this change and every one was ordinary English — "a list of 12 cards", "a numbered list of leaves". Never as a semantic to reject. The gap matters because the annotation is **unimplementable**, not merely verbose: SwiftUI exposes no list role, no item count, and no container-type API at all, and while UIKit does have `UIAccessibilityContainerType.list`, it produces no "list, N items" announcement and SwiftUI cannot reach it. A developer handed that annotation either ignores it or hand-rolls a fake announcement on appear.

  Three existing guards each came close and all three let it through, which is why this needed more than one edit. The `role=` row catches `role="list"`, but that is not what gets written. The trait-API row says "any iOS *trait* API", and `accessibilityContainerType` is a container API, so it is arguably out of scope. And most seriously, **`Announce: "List, 3 items"` contains no banned term whatsoever** — it passes the self-check's web-vocabulary grep and its SwiftUI-API grep cleanly, and the `Announce:` key actively sanctions it, since that key does map to a real `UIAccessibility.post(notification:)` call. The failure was therefore not a missing table row but an existing key blessing the error, so the fix is a table row *and* a prohibition inside the `Announce:` rules *and* a dedicated self-check step that states it is the only step which catches this.

  Step 20's grep targets the specific tokens — `role="list`, `listitem`, `setsize`, `posinset`, `containerType`, `list count`, `"List,` — and says so explicitly, because an earlier draft grepped the bare word "list" and flagged ten legitimate uses in this very file ("a list of 12 cards", "a numbered list of leaves") along with any annotation describing a design in plain English, such as `Component: Button — the row styling reads like a list row`. Describing appearance is not asserting a semantic. The test the step now gives is whether a SwiftUI developer could implement the line: `Component: Button` yes, `accessibilityContainerType: .list` no.

  Two rows added to the banned-vocabulary table, taking it to 20: one for `role="list"` / `role="listitem"` / `aria-setsize` / `aria-posinset`, and one for `accessibilityContainerType: .list` / `List, N items` / `Announce list count`. Both resolve to "nothing" — each row is already its own VoiceOver stop and the swipe order carries the sequence. Where a count genuinely carries meaning, it belongs in the section heading rather than a container role.

- **`Group: combine` is never annotated on a control — the control already combines its own content.** A `Button` wrapping an icon and a label is a single accessibility element by default, and so is a disclosure, a toggle, a link, a segmented control. Annotating combine on any of them specifies a platform default, which gate question 3 already rules out — but the `Group:` rules never said so, describing combine only as "merge several layers into one VoiceOver stop" with a card and an icon-plus-text as the examples.

  The omission produced an inconsistency inside a single screen: the showcase's pill-shaped "Place order" button was deliberately left unannotated because a `Button` is already one stop, while the disclosure row directly below it was given `Group: combine` for content a disclosure or button would have combined for free.

  The rule now gives the test as one question — **is this element a control?** If it is, the combining is free. `Group: combine` is for containers that are *not* controls: a card of sibling text layers that should read as one stop, a row whose status glyph and message belong together, an icon and caption that mean one thing. That cleanly separates the legitimate uses already in play (an error row of glyph plus message, an action row whose plus and label are siblings in a plain frame) from the redundant ones.

- **The disclosure conditional stated: a native `DisclosureGroup` needs no annotation, a custom row needs a `Value:`.** The `Value:` rules listed "a collapsed/expanded state" among the things to annotate without noting that the native control supplies it for free. An annotator following the rule would therefore annotate a platform default on any design using a `DisclosureGroup` — the same class of error as the file's old claim that a `TextField` names itself, inverted.

  A native `DisclosureGroup` carries the button trait *and* announces collapsed/expanded. A custom row built from a frame, a label and a chevron provides neither. The two are pixel-identical in a design, which makes this unresolvable by looking — so the rule says **ask**, treating it as the same situation as behaviour the design does not show.

  On how to write it, the rule draws a line the file had not drawn before: **a condition the developer controls may be stated; a condition about the design may not.** A first pass banned all conditionals, which was too absolute. "If the control is custom" is resolvable by the person reading it, because *the developer chooses the control* — unlike `.button (if tappable)`, which asks them to guess a fact only the designer knows and which the annotator should have asked about instead of passing the uncertainty along. That distinction is what separates a usable conditional from the hedging this file rejects elsewhere.

  The annotation names **both routes and what each requires**, so the developer can act on whichever they build: `Native accordion (disclosure group): no trait or value needed. If a custom control: use a Button, with Value: "Collapsed" / "Expanded".` Written as control *categories* — "accordion", "disclosure group", "Button" — not SwiftUI types, since `DisclosureGroup` in an annotation is API and Principle 8 still forbids that.

  This reinstates a control type inside an annotation, which the `Component:` removal otherwise rules out, so the carve-out is bounded by a stated test rather than left to erode that rule. A disclosure differs on three counts: the design cannot show which of the two it is, the **developer** chooses, and the accessibility consequences of the choice are not the same. The test is one question — **can the design express the choice?** If it can, fix the design and annotate nothing; if it cannot and the developer resolves it, state both paths. Without that test written down, the two rules would quietly contradict each other.

  Where the control is custom, the missing *button* behaviour is routed to the design rather than the annotation, per the removal of the `Component:` key.

- **The outside-label rule generalised from text inputs to any control, and the visible-value trap made concrete.** The label-association rule added moments earlier was written input-shaped — "every input needs a visible label" — when the gap it describes is not about inputs at all. It is about any control whose visible label is a *separate layer* rather than its own content: a `Text` above a `TextField`, an item name above a stepper, a caption beside a slider, a heading above a rating control. `Button("Refill")` and `Toggle("Notifications")` name themselves because the text is part of the control; none of those others do, and iOS has no `<label for>` to connect them.

  Found by annotating a quantity stepper. The stepper drew `Value: quantity 2, adjustable from 1 to 5` — restating a number printed on screen, which the `Value:` rules already forbid ("do not annotate a value that is already the control's visible text") — while the thing it actually needed went unwritten: a bare `− 2 +` has no label of its own, and its name has to come from the item name above it.

  So the rule now reads as the general case with text inputs as the common instance, keeping the placeholder sub-rule. And the `Value:` prohibition now names the trap concretely — a stepper showing `2`, a counter, a price, a quantity beside its label — and points at the outside-label rule for what the control usually needs instead.

- **Never annotate behaviour the design does not show.** The file listed "a non-obvious gesture (long press, swipe-to-action, drag, context menu) and its non-gesture alternative" among the things invisible in a static design and therefore worth annotating — without ever saying how an annotator is supposed to *know* the gesture exists. `Hint:`, `Focus:`, `Announce:` and gesture alternatives all describe **runtime behaviour**, and a static frame shows none of it: nothing in a drawing says a row swipes, a button opens a sheet, a count updates in place, or an error appears on submit.

  The failure mode is not a missing annotation but a fabricated one. Annotating an invented swipe produces a note a developer may actually build — a gesture nobody designed, with an accessibility alternative for a feature that does not exist. That is confidently wrong and it creates work, which is worse than silence. It happened while building the showcase screen: a swipe-to-remove `Hint:` and gesture alternative were written onto an item row that has no swipe behaviour anywhere in the design, purely so the screen would demonstrate the `Hint:` key.

  The rule now says: if you did not see it, you do not know it — **ask**. A handoff that states behaviour is one you can annotate; a handoff that does not is one where those three keys are unreachable, and saying so is the correct output rather than a gap to fill. Where the design *does* show the behaviour — a swipe-revealed state drawn as its own frame, a sheet drawn beside the screen that opens it — annotate it, because then you are reading the design instead of guessing. Self-check step 11 now asks whether the design actually showed the gesture.

- **An annotation carries the instruction, not the reasoning.** Rule 0 caps nothing about length, and the file's only guidance was "most annotations are one or two lines. If yours routinely runs to five keys, re-read the gate" — which measures keys, not words. So a set could sit comfortably inside the bare-minimum rule while being unreadable, and repeatedly did: three adjacent nav icons each carrying the same three-line rationale, a fourteen-line screen block, an input annotation explaining iOS view hierarchy on every field.

  It is the clutter Rule 0 exists to prevent, arriving by a different route: the number of annotations stays low while the amount to read does not. A reviewer facing a paragraph per element stops reading just as surely as one facing forty notes, and in Dev Mode a long annotation renders as a card large enough to cover the design it describes — observed directly on this file.

  The rule now states that a reason needed to make an instruction intelligible gets **one short clause**, and anything longer belongs in this file instead, where it is read once rather than on every element. With a corollary that closes the loop with the repeating-component rule: **if the same reason appears on more than one annotation, it is a rule and not a note** — state it once at the design-system level and delete the copies.

- **Inputs now require a visible label, and the label-to-field association is a mandatory annotation.** Three statements in the file were wrong in the same direction, all of them telling the annotator that text inputs name themselves.

  Principle 1 listed "`TextField` with a visible label" among the controls that "take their accessible name from their visible content". The gate's third question listed "a `TextField` its placeholder-to-label relationship" among the free platform defaults and said not to annotate it. And a first attempt at fixing this only narrowed the claim to a `TextField` *with a persistent visible label*, which is still false.

  **None of it is a default.** A `Button("Refill")` or `Toggle("Notifications")` names itself because the text *is* part of the control. A label above a `TextField` is a **separate view**, and iOS has no `<label for>` — nothing connects the two unless the developer does it. To a sighted user the pairing is obvious from the layout; to VoiceOver the field is simply unnamed. So the association is genuinely invisible in the design, which is exactly the thing an annotation is for.

  Two mandatory halves now sit under `Name:`. First, **a placeholder is not a label** — the label vanishes the instant the user types, a 3.3.2 failure affecting every user, and the fix is the design rather than an annotation working around it. Second, **every input carries the association annotation**, pointing at the visible label rather than retyping its string so the name cannot drift when the label is reworded.

  This is one of the few annotations that applies to *every* instance of a control type rather than to exceptions, and the rule says why that is not a contradiction of Rule 0: the gap is in the platform rather than in a particular design, so it is present every time and omitting it always causes a nameable defect.

  The showcase screen's promo field was changed to match — a persistent visible `Promo code` label above it, and the field holding the code the user actually typed, so the error state is coherent rather than relying on a placeholder that would already have disappeared.

- **Principle 1's "generic label" case rewritten: a lone generic verb counts, not only a repeated one.** All three examples the rule offered were repetitions — a column of "Edit" buttons, twelve "Refill" buttons, a list of "Learn more" links — which reads as though the defect requires duplication. It does not. `Apply` beside a promo field and `Change` beside a saved card each appear once on a screen and are each ambiguous in the swipe order, because VoiceOver hands the user the control without the field or row sitting next to it: they hear "Apply, button" and cannot tell what is being applied.

  The rule now separates the two cases, names the common offenders (`Apply`, `Change`, `Save`, `Add`, `Remove`, `Edit`, `View`, `Update`, `Select`, `Learn more`, `Continue`), and states the test: **read the label on its own with the rest of the screen covered.** It also says why this case is the easiest to miss — a generic label always looks correct in the design, because the person reviewing it is looking straight at the context the label lacks.

  Self-check step 4 only ever ran in one direction: delete `Name:` annotations that restate visible text. Nothing asked the inverse — whether a control with a generic label is missing a name it needs. Those are the same rule read in opposite directions, and an annotation set can pass the first pass while failing the second completely, which is what happened on the showcase screen. Step 4 now runs both ways.

- **Status and security glyphs named as the decorative-vs-informative trap.** Principle 3 already carried the correct test — "ask what a sighted user loses if it disappears; nothing lost means decorative" — but it sits as the closing bullet after a list of six decorative examples, one of which is "an icon that duplicates the text beside it". A lock beside "Visa ···· 4242" pattern-matches to that example and fails the test: nothing in the visible text says **secure**, so a sighted user loses real information and the glyph needs a `Name:`. A chevron on the same row, same size and position, loses nothing. The rule was right and skimmable; the list invited the error.

  Added the trap explicitly for locks, shields, warning triangles, checkmarks, info circles and badge dots, and extended self-check step 8 to run the test on each of them by name.

  The change also adds a rule the file did not have: **a status icon that stands outside a control must be named, never hidden.** A warning triangle beside an error message, a success tick beside a confirmation, an info glyph beside a notice. Each is doing two jobs for every sighted user — it is the **non-colour indicator** a colour-blind user depends on when red text is the only other signal, which is why 1.4.1 Use of Color put it there, and it is what draws the eye to the message at all. Hiding one gives sighted users information VoiceOver users never receive, which is a 1.1.1 Non-text Content failure. It gets a `Name:` — `Name: Error` — and stays a VoiceOver stop.

  The rule states the **complete** spec rather than just the icon's half, because the icon alone leaves a worse result: a `Name:` on the icon plus `Group: combine` on the row holding the icon and the message, so VoiceOver announces "Error, that code expired on Feb 28" as one element instead of making the user swipe twice for one message. This works because combining concatenates each child's accessible *name*, not merely its raw text, so the icon's `Name:` is what makes the announcement lead with the condition. The rule also says explicitly that nothing goes on the field itself — the association is already in the `Announce:` line, and a third copy on the field's value would have VoiceOver read the error twice.

  The tempting counter-argument is explicitly rejected: the nearby text does not cover it. "That code expired on Feb 28" communicates a problem but never says *error*, and a user swiping the screen can reach that message without ever focusing the field whose value carries the state. The icon is the only element that names the condition.

  One exception survives, and it is the case the file already had right: a state glyph **inside** the control whose state it shows — a checkmark on a selected row where the row announces `Value: Selected`. There the glyph is redundant with the element the user actually lands on. That gives the general test: does the state reach VoiceOver through the thing the user focuses? Inside a control it does; in a message beside a field it does not.

  And a point worth stating once: **hiding from VoiceOver never means removing from the design.** A status glyph is frequently the non-colour indicator that satisfies 1.4.1 Use of Color — the thing that stops red text being the only signal of an error. It stays on screen; it just is not a separate VoiceOver stop.

- **`Group: contain` no longer quotes a group name — it points at the visible heading.** The rule's own example was `Group: contain, name "Delivery method"`, and following it on a screen whose section heading reads **Delivery** produced an annotation naming a string that appears nowhere in the design. That is Principle 1's drift problem at container level, and the file taught it: the example invented a name, so an annotation written from the example invented one too.

  A group that needs a name almost always already has one on screen — the section heading directly above it. The grammar now points at that element instead of restating it, so the developer references the same string constant that renders the heading and the group name cannot drift when the heading is reworded. Two candidate names with no stated authority is worse than one.

  Where a group has **no** visible label, that is itself the finding: either the design needs a heading, or the annotator is about to invent content, which is a design decision rather than an annotation. The banned-vocabulary row for `<fieldset>` / `<legend>` and the SwiftUI modifier row were updated to match — the modifier row now says to pass the same string constant that renders the heading, never a second literal.

  Fixing this surfaced the same error one example further down: the card example read `Group: combine` *and* `Name: Atorvastatin 20mg, ready for pickup, CVS Main St`. Since combine concatenates child text, that `Name:` restated what combining already produces. Removed.

- **`Page title` promoted to a real annotation key, resolving a contradiction the file already contained.** `Page title` appeared in the WCAG criterion table (2.4.2) and in the SwiftUI modifier table (`.navigationTitle("…")`), but it was not one of the closed annotation types, and the fact-ownership table said to write it **nowhere** — "the navigation title is visible text and SwiftUI derives it". Three places disagreed about whether the key existed.

  It should, and the reason is specific. Most visible text needs no annotation because the platform derives the accessible name from it. A navigation title is different: the design cannot show the difference between a real navigation title and a `Text` dropped into a custom header. The two are pixel-identical and behave nothing alike. A real navigation title carries WCAG 2.4.2 Page Titled, **the header trait applied automatically by iOS** so VoiceOver announces "Caregiving, heading", and an entry in the Rotor's Headings list. A `Text` in a bar carries none of them and fails silently. So the gate is satisfied — omitting the annotation causes a nameable defect — and what is being specified is the mechanism, not the string.

  The annotation is therefore `Page title` with **no string restated**, since the text is visible in the design and only the mechanism is invisible.

  The new per-type section also closes the trap this opens: **never write `Heading:` on a page title and never annotate a heading trait on it.** iOS applies the header trait to the navigation bar title itself, so `Heading: 1` on top of it doubles the announcement and, worse, invites a developer to build a trait-decorated `Text` instead of a navigation title — trading 2.4.2 away for an announcement that sounds identical. The heading behaviour is a consequence of being the page title, not something to specify. The closed set returns to nine types.

  Noted while checking whether the title could live in a properties field instead: the H100 top-nav component set exposes only `Screen type` and `Platform`, both variants, and **no `Title` text property** — the title is a raw text override on a layer inside the instance. So it is not structured data, and nothing in the file marks that layer as the page title. Adding a `Title` TEXT property to the nav component would fix that at the design-system level, the same shape as the `A11y name` conclusion, but it does not change the annotation.

- **Principle 2 corrected on two counts: the field it told you to use does not exist, and its preference was stated without the condition it depends on.**

  It instructed the annotator to "select the image and type the alt text into its description/alt-text property". There is no such field. Figma Design exposes no per-layer accessible-name field: `description` exists only on a `COMPONENT` or `COMPONENT_SET`, a plain frame or vector does not have it, and a component description is shared by every instance so it cannot carry three different names for three icon buttons. The field has to be **created** — a TEXT component property on the component, verified to appear per instance in the properties panel with the value on that instance. The order of preference is now name it in the component (an icon variant that knows its own name) → set a property on the instance → write an annotation.

  The second correction matters more. The principle argued properties beat callouts because they are structured data that travels with the layer — both true, and both about tools. It never asked whether a *developer* will find one. A property has no badge, no filter, and nothing pointing at it; it is discoverable only by selecting that exact layer and scanning a panel there was no reason to open. An annotation announces itself and Dev Mode can filter to it. So the preference is conditional: it holds when the design system documents the convention, or when Code Connect renders the property into the code the developer is shown. **Where neither is true, the annotation is correct** — a property nobody reads is worse than a callout everyone reads, and the unconditional version of this principle ships an unnamed icon button with its name in a field no one opened.

  The principle also now prohibits doing both for the same value, which had been left open. Two copies of one string drift, and that is the discrepancy Principle 1 exists to prevent.

  On the Code Connect escape hatch, checked against the Anatomy library rather than assumed: it is configured, and the SwiftUI mappings are **simple mappings** (`hasTemplate: false`) that name `StatusBadgeView` and its source file without rendering a snippet. Only the SVG icon mappings carry templates, and those emit React. A simple mapping cannot put an accessible name in the Code panel, so the principle now says the second condition requires a *templated* mapping and to verify which kind the library has.

- **The `Component:` key removed; the closed set is now eight types, not nine.** The key existed for the case where "the design misleads about which control this is" — a row that acts as a button, text that navigates but does not look tappable, a custom control imitating a native one.

  Every one of those is a design defect, and `Component: Button` documents it rather than fixing it. An element that behaves as a button should **be** a button in the design: the Button component, the Link component, the disabled variant. Then there is nothing to annotate. The file already specified the order as fix the component → set the property → write a callout, and for control types the first step is always available — so the key contradicted the file's own order of preference, and the per-type section said as much in its first bullet ("Best of all: fix it in the design and annotate nothing") while spending four more bullets on how to write the annotation anyway.

  A component mismatch is now **design feedback, not an annotation.** The section is replaced by "Why there is no `Component:` key", which keeps the whole anti-trait argument — a trait written as iOS API gets implemented as iOS API, on a control that already had it — and keeps the three mismatches worth raising with a designer, because each is a real defect: `Button` vs `Link` (a 4.1.2 failure, and the two are visually identical in a design), a control drawn greyed out that needs the disabled variant, and a hand-drawn control imitating a native one. `Component: Button` is added to the never-annotate list alongside traits.

  Removed from the types table, the `Key: value` example, the banned-vocabulary table's two right-hand columns, the modal-sheet rule (a sheet that must trap VoiceOver is a `Focus:` concern), the worked example's fourth callout, the WCAG criterion table's 4.1.2 row, four rows of the SwiftUI modifier table, the frontmatter description, and self-check steps 6 and 7 — step 7 now asks whether any annotation names a control type at all.

  Noted while making the change: the H100 Caregiving design already uses a `list-row button` component for its add-a-person row. The design had made the component choice correctly, and the `Component: Button` annotation written against it during this comparison was an artifact of the reconstruction using a plain frame — not a finding about the design. Which is the argument for deleting the key, observed in the wild.

- **Dynamic Type is no longer annotated at all — it is a design responsibility.** The file previously listed "reflow intent where a layout would break at large text sizes" among the things invisible in a static design and therefore worth annotating, and told the annotator to specify what must not happen: no truncation, no fixed heights, no line limits.

  That note asks a developer to achieve an outcome nobody has designed. Every decision about what moves, wraps, or stacks at AX5 is left to them at build time, which is exactly the judgement a designer is for. A layout that cannot survive the largest accessibility text size is a **missing design**, not a missing annotation — the answer is to produce the large-text variant and hand over both frames, and a designer may legitimately need several, one of them at the largest size. `text may truncate` was already on the unactionable list; `no truncation, no fixed heights` is the same failure stated as an instruction instead of an observation.

  Removed from the annotate list, the where-each-fact-goes table, the frame-level exception, the worked example's card annotation, the WCAG criterion table (1.4.4 / 1.4.10 no longer map to any annotation) and the SwiftUI modifier table. Added to the never-annotate list. The guidance bullet is retained but inverted: it now explains why the annotation is wrong rather than how to write it.

- **The `Group:` rules never said that `combine` concatenates child text, so an annotation written against them announced an initials avatar ahead of the name.** The section described `combine` as merging layers into "one VoiceOver stop with one name" and, in its worked card example, supplied an explicit `Name:` alongside it — which together imply the annotator provides the name. In fact the default announcement is every child's text run together in source order, which is why combining usually needs no `Name:` at all, and why any redundant text child is read *first*.

  The case that exposed it: a person row of initials avatar + name + date of birth. Combined, it announces the initials before the name, and nothing in the file warned that it would. The rule now states the concatenation behaviour, and adds the check — read the child text in order and ask what the concatenation actually says — as part of self-check step 8.

  The rule stops at stating the behaviour, and explicitly does **not** tell the annotator to hide redundant text children. A first pass at this change did, and that was wrong: visible text is on the screen, so it is read by design, and hiding it desynchronises what a low-vision user sees from what they hear — someone using Zoom with VoiceOver, or reading along while listening. That is a real cost against a saving of two syllables. Redundancy is not a defect, and deciding a visible string is surplus is a content judgement rather than an annotation. "LL, Lucas Lee, born March 21 2016" leads with redundant initials and is still correct, still unique, and still contains the visible label. Where a concatenation genuinely does not work, the question is whether the component should change, not what note to add.

  Finally, the rule now prohibits writing out what the combination will announce. Spelling out "announces 'Lucas Lee, born March 21 2016' as one stop" is the visible text retyped, carrying every drift risk Principle 1 describes — `Group: combine` plus a correctly hidden child is the entire specification.

- **The screen-level block removed; every fact now lives on the element it is about.** The section prescribing one collected note per frame is replaced by a table assigning each screen-wide fact an owner, and the worked example no longer shows a block.

  The block failed three ways. In Dev Mode it renders as one oversized card laid over the design, so the reviewer can read neither — observed directly on a real file, where a fourteen-line block covered the screen it described. It also forces the reviewer to hold a list in their head and map it back onto layers by eye, which is the same association problem Principle 2 exists to solve, one level up. And because it was the one place no single element had to answer for, it filled with compliance statements: "contrast verified", "all targets pass", "portrait and landscape supported", "no motion on this screen". None of those name a defect, and the gate already forbade every one of them — the block was the loophole that let them back in.

  Redistribution: heading levels go on each heading element, as the component's `level` property where heading components are used; Dynamic Type reflow intent goes on the element that must reflow; contrast and target size go on the failing element only; motion goes on the element that animates. Page title, orientation, and "accessibility per component spec" are now written nowhere. The frame remains annotatable for the rare fact that is genuinely screen-wide *and* genuinely a defect — an orientation lock failing 1.3.4 — with the note that both such cases are things to fix in the design rather than document.

  `Uses DS/Button — accessibility per component spec` is called out as the specific phrasing to stop writing: it reads like a specification and contains no instruction a developer can act on. If a component's accessibility is specified, say nothing; if it is not, the fix belongs in the component.

  Fixing the worked example surfaced one more self-inconsistency: its correct annotation set included `Order: default is correct. No override.` — an annotation of the default reading order, which Principle 4 and the never-annotate list both prohibit. Removed. The example now shows 5 properties and 5 annotations where it previously showed 4 properties, 5 callouts and a block.

- **Rule 0's hard ceiling of 10 callouts replaced with the bare-minimum rule it was approximating.** The ceiling was the wrong instrument and failed in both directions. "Delete until you are under it" makes a correct annotation exactly as deletable as a redundant one — the gesture alternative that prevents a 2.1.1 failure goes just as readily as a restated visible label, because the only instruction is to reach a number. And a stated allowance of ten reads as room to fill on a screen that needed two.

  Both errors come from letting a count stand in for the gate. The gate is the actual rule: would omitting this annotation cause a real defect you can name? Applied honestly, together with the four never-annotate principles that remove whole categories before anything is tallied, it produces the small set the ceiling was trying to force — without ever deleting something correct to hit a quota.

  The observation that most screens land at three to six callouts is kept, reframed as an observation rather than a target or a limit: a forty-row settings screen may legitimately need more, and a confirmation screen may need none. Volume is retained as a *symptom* — a large set almost always means the gate was applied loosely — but the instruction is now to re-run the gate on every annotation and name the defect each prevents, not to delete down to a number. The structural limits are untouched, because none of them was numeric: one callout per element, one callout one element, a repeating component annotated once, a design-system component annotated zero times.

  Nine downstream references assumed the quota and were rewritten, including the self-check's first step ("Count them. Over 10 per screen? Delete down."), the frontmatter description, and four places describing properties-panel values as "costing nothing against the budget" — which now say what they actually are: the design specifying itself, rather than a note competing for the reviewer's attention.

- **44pt was used as the touch-target pass/fail threshold, which manufactures failures.** The file already stated the rule correctly in one place — "24×24pt is the WCAG 2.2 AA floor (2.5.8); 44×44pt is Apple's guidance" — and then used 44 as the threshold everywhere else: in the never-annotate list ("already ≥ 44pt"), in both worked-example screen blocks, and in the SwiftUI modifier table (`.frame(minWidth: 44, minHeight: 44)`).

  The consequence is a reported defect that is not one. 24×24pt is 2.5.8 Target Size (Minimum) at AA; 44×44pt is Apple's HIG recommendation and, separately, WCAG 2.5.5 Target Size (Enhanced) at AAA. A 32pt control conforms to AA. Under the old wording it would be annotated as a violation, which is the same manufactured-failure error the file warns about at length for visible-text labels — and the worked example demonstrated it directly, listing "the 32pt 'info' glyph" as a touch-target exception when 32pt passes. That example is the part people copy.

  24×24pt is now the threshold annotations are measured against, 44 is described as a recommendation never to be reported as a defect, and the worked example's exception is a 20pt glyph that actually fails. Where a team wants Apple's number across the board, the file now says that is a design-system conversation rather than a per-screen annotation.

- **Figma HTML-escapes annotation labels, so straight quotes and ampersands render as entities.** A `Name:` value typed with `"` shows the developer `&quot;` in the annotation card, and `&` shows `&amp;`. Found on a real annotation where a screen-level note rendered as `cg1.03 Add &amp; manage landing` and `Page title: &quot;Caregiving&quot;`. Documented alongside the category notes, with the instruction to use typographic quotes and the word "and" — this matters most for `Name:`, the key most likely to contain quotation marks.

- **The Accessibility annotation category was described as optional, so annotations were written uncategorised.** The file said a Dev Mode annotation is "optionally tagged with a category such as 'Accessibility'" — a parenthetical, inside a sentence about text formatting — while Principle 2 separately listed "use the layer's annotation category" among the properties to set. The two disagreed, the self-check had no step for it, and the optional reading is the one that wins: a full annotation pass written against this file produced eight notes with no category on any of them.

  It is not cosmetic. Dev Mode lets a developer **filter** annotations by category, so an uncategorised accessibility note still exists but is invisible to the person who went looking for it. Now stated as required, with a self-check step, taking the self-check to 22.

  Two operational facts added for anyone writing annotations programmatically, both of which cost real time to discover. Category IDs are **per file** — the same "Accessibility" category is a different ID in every file, so nothing can be hardcoded. And there is no API to enumerate them: `figma.root.annotationCategories` does not exist, and the only reliable way to obtain the ID is to read it off an annotation that already carries one. A file with no categorised annotation yet therefore needs one seeded by hand before a tool can match it, which is a genuine bootstrap problem for any automated pass.

### a11y-check

#### Changed

- **`heading-trait-missing` now recognises design-system heading tokens, not just Apple's font styles.** The rule knew `.title`, `.title2`, `.title3`, `.largeTitle` and `.headline` and nothing else, which meant it saw almost nothing in any app with its own type scale — and most apps have one. On the Aetna Health iOS app it produced **5 findings against 380 `.font(.themeHeading*)` sites**, while that app's accessibility backlog carried **38 open "visual heading is not marked up as a heading" defects**. The rule was blind to precisely the defect class it exists to catch.

  Matching now works on the **font tokens** in the `.font()` argument, resolved in a fixed order: `heading_font_deny`, then `heading_fonts`, then the built-in styles, then a name heuristic for tokens containing `heading`, `header`, `title`, `headline`, or `display`. So `.themeHeadingXL`, `.appTitleLarge` and `.dsHeading2` are recognised with no configuration.

  **Subheadings are headings.** `.subheadline`, `.subtitle`, `.themeSubheadingM` and `subHeaderL` all report. WCAG 1.3.1 asks for anything that appears to be a heading to be marked up as one and makes no exemption for subordinate headings, so a section subheader that never reaches the Rotor is exactly the defect this rule exists to catch. An earlier revision of this change excluded `subtitle` and `subheadline` by name on the grounds that they are usually supporting text; that was the rule making a judgement that belongs to the content, and it would have silently dropped real subheadings.

  Scanning tokens rather than taking the leading identifier also handles chained, constructed and conditional fonts: `.themeHeadingL.weight(.bold)` reads as `themeHeadingL` rather than being missed, `.custom("AetnaSans", size: 17)` reads as `custom` and is never a heading, and `isHeader ? .themeParagraphMStrong : .themeParagraphM` is judged on its two paragraph branches instead of on the `isHeader` that chooses between them. That last one is not hypothetical — reading the condition as the font name reported two paragraph rows in `FindCare+CostEstimateLimitsView.swift` as unmarked headings.

  Measured on the same 13 Aetna Health packages: **5 findings to 211**, which matched an independent count of heading-font sites with no `isHeader` within ±6 lines. Every other rule's count was unchanged, confirmed against a control build of the previous commit.

- **Fonts passed in by variable are resolved to the token they hold** (new `FontConstantCollector`, mirroring the existing `ColorConstantCollector`). A variable's *name* is not evidence of its tier, and in this codebase it misleads in both directions: `subtitleFont` holds `.themeParagraphXS`, while `titleFont` holds `.themeHeadingM` in one component and `.themeParagraphS` in two others.

  So the old rule's handful of findings were mostly name-guesses. Of the **5** it produced on the Aetna Health app, **3 were false positives** — `InformationBannerView.swift:37` and `PharmacyInlineTitleView.swift:18` both report a `titleFont` that is declared `.themeParagraphS`, and line 41 of the same banner is a `subtitleFont` declared `.themeParagraphXS`. All three are gone, decided by the declared value rather than the name.

  Resolves `let`/`var` initialisers, single-expression computed properties, and function and init parameter defaults, including through one level of member access (`viewModel.titleFont`). Parameter defaults matter more than they sound: in a component whose fonts are injected, the stored properties carry no initialiser at all, so the signature is the only place the font appears.

  When one file declares the same name with two *different* fonts — two components that each have a `titleFont` — there is no way to tell which applies at a given call site, so the name is marked ambiguous and left unresolved rather than letting declaration order attach one component's type scale to the other's text.

- **Two config keys for type scales the heuristic cannot infer**: `options.heading_fonts` opts a token in (`brandJumbo`), `options.heading_font_deny` opts one out (`themeHeadingInline`). Deny beats allow, so a project that lists a token in both gets the safe answer rather than an arbitrary one. Both default to empty, so no existing project changes behaviour without asking.

#### Fixed

- **Paragraph text held in a heading-named variable was reported as a missing heading.** The old check asked whether the font *text* contained a known style name, so the identifier `subtitleFont` matched `title` and `subheadline` matched `headline` — the variable's name decided the answer and its declared value was never consulted. Three of the rule's five findings on the Aetna Health app were this; see the resolution entry above.

- **`HeadingRules.swift` was missing its Apache header**, which this repository requires of every file.

#### Known limits

Sampling the 211 findings by hand turned up two classes this rule cannot distinguish, both reported rather than silently filtered:

- **16 sit in `#Preview` / `PreviewProvider` bodies.** Preview code is flagged by every rule in the tool, so suppressing it for this one rule alone would be inconsistent; it needs a tool-wide decision.
- **27 sit within ±12 lines of an `.accessibilityElement(children: .combine)`.** Whether `.isHeader` on a child of a combined element reaches the merged element is a device question, not a source question, and it was not tested here — so no guard was added on an untested assumption.

A font heuristic also cannot tell a structural heading from display text that borrows a heading token: avatar initials styled `.themeHeadingXXL` report, and correctly so by the rule's own definition. `heading_font_deny` is the wrong instrument for that, since the token is a real heading elsewhere. Value resolution narrows this to genuinely inline tokens — anything injected as a variable is now judged on what it holds.


## [a11y-check 0.7.0] - 2026-09-25

### a11y-check

#### Added

- **New rule `fixed-height-clips-text`** (`FixedHeightTextRule.swift`, warning, WCAG 1.4.4). Flags a text view pinned to an exact `.frame(height:)` that cannot fit its own text once Dynamic Type grows — one line of body text is roughly 22pt by default and roughly 53pt at the largest accessibility size, so `Text("Total").frame(height: 30)` reads fine as written and clips for anyone using large text. The fix is mechanical, so the rule ships an auto-fix that rewrites `height:` as `minHeight:`. Rule count 44 to 45; WCAG criteria unchanged at 24, since 1.4.4 was already covered.

  The scope was set by measurement rather than guesswork, because the question asked was whether this could be done without false positives. A first cut reported **ten findings on this repository, six of them on good examples** — notification badges, carousel page dots, and emoji arrow buttons. Two tightenings followed:

  - **A floor of 28pt.** Below that the view is chrome, not a text box: a badge or a page dot holds at most a digit or a glyph, and one line of text does not fit in 24pt at any size. A small height says "decoration", not "text container that forgot to grow".
  - **A Button must actually render prose.** `Button { Rectangle() }` is a page indicator and grows with nothing; `Button("⬅️")` is a glyph used as an icon. Only a `Text` in the label or a title containing a letter or digit counts.

  Together those took the repository from ten findings to **zero**, while a synthetic probe confirms the real pattern is still caught at 30, 40, and 44pt. It also skips `minHeight`/`maxHeight`, `.infinity`, heights of 60pt and above, chains with `.minimumScaleFactor`, and non-text views. Warning rather than error, because static analysis cannot distinguish a short string in an adequate box from one that clips.

  Adding `minimumScaleFactor` to `ModifierCollector.trackedModifiers` was required for the exemption to work — the same allowlist trap that made the `buttonStyle` check silently match nothing in 0.5.1, caught this time by testing the exemption rather than assuming it.

## [a11y-check 0.6.0] - 2026-09-25

### a11y-check

#### Added

- **`fixed-font-size` now covers custom typefaces and `UIFont`.** Prompted by comparing the rule set against the [Axiom accessibility-auditor](https://github.com/CharlesWiltgen/Axiom) agent, which names custom font scaling as its own detection category. The rule caught `.font(.system(size: N))` but silently passed `.font(.custom("Helvetica", size: 17))` and `.font(Font(UIFont(name:size:)))` — arguably the worse defects, since a custom typeface at a fixed size never scales at all, whereas `.system(size:)` at least tracks the system font. It now flags a custom font without a `relativeTo:` text style, and a `UIFont` built at an explicit size. `.font(.custom("Name", size: 17, relativeTo: .body))`, `UIFont.preferredFont(forTextStyle:)`, and anything already wrapped in `UIFontMetrics` are exempt. The repository's own `DynamicType.md` already taught `relativeTo:`, so the documentation and the tool had been out of step. Adds zero findings to this repository, which uses no custom fonts — verified before shipping.

## [a11y-check 0.5.2] - 2026-09-25

Applies the "explicit backdrop" reasoning from 0.5.1 to `hardcoded-color`, which had been left inconsistent with the contrast rule.

### a11y-check

#### Fixed

- **`hardcoded-color` no longer warns about a foreground painted over a deliberate backdrop.** 0.5.1 taught the contrast rule that an explicit background means "do not assume", but left this rule reporting the same code. It warned on all four production patterns: white text over a `LinearGradient`, over `.ultraThinMaterial`, on a `.buttonStyle(.borderedProminent)` button, and on a child whose background sits on the enclosing `Button`. A backdrop now counts whether or not it is a colour this rule can read, and whether it is on the view's own chain or any enclosing view — because the rule's complaint is "may not adapt to Dark Mode", and that is simply the wrong complaint once the developer has pinned what sits behind the text. An appearance-*following* surface such as `Color(.systemBackground)` still does not count, on an ancestor as well as on the view itself, since that is precisely the case where a fixed text colour disappears.

  `.ultraThinMaterial` is deliberately included even though it does adapt. Contrast over a material is genuinely unpredictable, but that is a different concern from Dark Mode adaptation and is not worth making badly here.

  Verified against a six-case production probe: it now reports only the two true positives, `4.0:1` white on `Color.blue` and `3.3:1` `.gray` on the assumed background. `ContentView.swift` drops from two findings to one `info` advisory, and `DarkModeView` plus `ContrastView` still report all 15 of their intentional failures.

## [a11y-check 0.5.1] - 2026-09-25

Follow-up to 0.5.0, prompted by testing the colour rules against production-shaped SwiftUI rather than only this repository's self-contained examples. Two false positives turned up, both reporting an alarming `1.0:1` error on correct code.

### a11y-check

#### Changed

- **`assume_default_background` now defaults to `false`.** It was shipped on in 0.5.0 on the strength of this repository, which is the best case for it — small self-contained views, literal colours, no design system or `ButtonStyle` layer. In a production app the assumption is wrong often enough that a false `error` costs more than a miss, so it is now opt-in. This repository opts in via a new root `.a11ycheck.yml`, where the assumption holds and earns its keep. The two fixes below mean it is considerably safer when enabled.

#### Fixed

- **A background supplied by a style is no longer mistaken for no background.** `Button("Save") {}.foregroundColor(.white).buttonStyle(.borderedProminent)` has a fill and no `.background` modifier to inspect, so the rule assumed the system background and reported "1.0:1 white on white". The rule now treats `.buttonStyle(…)` other than `.plain` / `.borderless`, `.listRowBackground(…)`, and `.toolbarBackground(…)` — on the view or anything enclosing it — as an *unknown* background and skips, which is the safe direction for a linter. `.plain` still assumes, correctly, since it paints nothing. Required adding those three modifiers to `ModifierCollector.trackedModifiers`; the collector only records an allowlist, so the first attempt at this check silently matched nothing.
- **Backgrounds on enclosing non-container views are now found.** The ancestor walk consulted only `VStack`-style containers, so `Button { Text("x").foregroundColor(.white) }.background(Color.blue)` could not see the button's own background and fell through to the assumed one. It now considers every enclosing view, turning a bogus `1.0:1` into the real `4.0:1` finding. Siblings are still unreachable, since the walk only follows parent nodes.

## [a11y-check 0.5.0] - 2026-09-25

Tagged CLI release. Installed via `brew install --HEAD`, so these land for anyone who reinstalls.

### a11y-check

#### Added

- **`exclude_paths` now applies to explicit file arguments** (PR #27, thanks to [@danibachar](https://github.com/danibachar)). The patterns were only checked while walking a directory, so `a11y-check Sources/Generated/Auto.swift` analysed a file that `a11y-check Sources/` would skip — breaking CI that lints only changed files. Adds `shouldExclude(filePath:relativeTo:)`, which normalises the argument against the working directory so `./`-prefixed and absolute CI paths match the same relative-style globs.
- **A skip notice for excluded explicit files** (`A11yCheck.swift`). An excluded file previously produced no output at all, indistinguishable from a clean one. It now prints `note: skipping <path> — matches exclude_paths in .a11ycheck.yml`. Written to **stderr**, never stdout, because stdout carries the `--format json` / `sarif` / `html` payload — the same mistake the `--per-view` HTML corruption fix addressed. Verified that `--format json` output stays parseable with the notice present.
- **Colour rules now see through file-local constants** (`ColorConstantCollector.swift`, new). Storing a colour in a property is idiomatic SwiftUI, but `.foregroundColor(darkGreen)` gave the rules only the identifier, so both `color-contrast-insufficient` and `hardcoded-color` silently skipped the view. The collector records `let`/`var` declarations — and single-expression computed properties — whose initialiser is a colour, and both rules resolve one level of indirection through it, including `self.`-qualified references. This is the gap that mattered most in practice: every technique view in this repo declares colours as `private var darkGreen = Color(red:…)`, so a clean contrast score on those files meant "no parseable colour pair found" rather than "contrast verified".
- **Contrast is now checked against the system background when none is declared** (`ColorContrastRule.swift`). The rule previously required a background on the same chain or an ancestor container and bailed otherwise, which skipped the most common real failure — a fixed foreground colour over the default background, such as `.foregroundColor(.black)` being invisible in Dark Mode. When no background is found it now compares against white in light mode and black in dark. Controlled by the new `assume_default_background` option, default `true`; set it to `false` for text drawn over images, gradients, or materials where the assumption does not hold. Such diagnostics always say `assumed system background` so they can be told apart.
- **`Color(hue:saturation:brightness:)` now resolves for contrast maths** (`ColorParser.swift`), via a standard HSB to sRGB conversion with SwiftUI's 0–1 hue fraction and out-of-range hue wrapping. Previously an HSB colour on either side of a pair aborted the check.
- **`hardcoded-color` recognises the remaining inline forms**. It matched only `Color(red:` and `Color(uiColor:`, so `Color(white:)`, `Color(hue:)`, hex, `Color(.sRGB…)`, `Color(.displayP3…)`, `Color(cgColor:)`, `UIColor(...)`, and `#colorLiteral` were invisible.
- **CI: `a11y-check Unit Tests` workflow** (`.github/workflows/a11y-check-tests.yml`). Runs `swift test` for the a11y-check package on pull requests and pushes to main that touch `a11y-check/**`, with the SwiftPM build cached on `Package.resolved`. The repository previously had no automated test run for the CLI at all — PR #27 merged with **no checks reported** on its branch.

#### Changed

- **A named accent or a `colorScheme` ternary also pins a pair.** The first pass only recognised literal colours, so two false-positive classes survived on this repo's good examples: `.foregroundColor(.white).background(Color.blue)` and `.background(colorScheme == .dark ? Color(.systemRed) : darkRed)`. Both are now treated as self-contained — a named accent is a deliberate choice that the pair moves with, and a ternary counts when every branch counts, scanned at paren depth zero so labelled arguments inside `Color(red:green:blue:)` are not mistaken for the separator. Appearance-*following* colours are explicitly excluded: `.primary`, `.secondary`, `Color(.label)`, `Color(.systemBackground)` and friends never pin a pair, because `.foregroundColor(.black)` over a surface that flips to black is exactly the bug the rule exists to catch. Across the nine affected files this took good-example hits from 14 to 1, and that one is a legitimate advisory suggesting an asset catalog for a lone colour.
- **`hardcoded-color` pair detection resolves constants.** The first cut of the pair check compared raw modifier arguments, so `.background(darkRed)` read as an unknown identifier and the pair was missed — which meant the badge fixed in `TabsView.swift` was still reported. It now resolves through file-local constants the same way the rest of the rule does.
- **`hardcoded-color` no longer flags a self-contained colour pair.** A chain that pins both the foreground and the background — `Image(systemName: "xmark.circle.fill").foregroundColor(.white).background(Color.black)` — renders identically in either appearance, so "may not adapt to Dark Mode" is the wrong complaint; whether the pair is legible is `color-contrast-insufficient`'s job and it checks exactly that case. Found by classifying every finding in this repo as good-example or bad-example: this pattern accounted for most of the rule's hits inside good examples, including three carousel overlays, the documentation close button, and a styled Create Account button. A colour pinned on its own is still reported.
- **`hardcoded-color` severity now depends on what the colour paints.** A fixed colour on **text** (`.foregroundColor`, `.foregroundStyle`) is reported as a `warning`, because it inverts against the background in the other appearance and is a near-certain Dark Mode defect. Decorative uses such as `.background()` and `.tint()` stay at `info`. Previously the whole rule was `info`, so it could never gate a build. Per-diagnostic severity was already supported via `severityOverride`; `severity_overrides` in `.a11ycheck.yml` still takes precedence.

#### Fixed

- **Two stale unit tests**, both failing on main before this change and unrelated to PR #27. `testRegistryHasAllRules` expected 43 rules against a registry of 44, and `testLabelInName_flagsSuffixOnly` still expected `warning` for the visible-text-not-at-start case that was deliberately upgraded to `error`. The suite now passes 125/125.
- **Rule count corrected from 43 to 44** across `README.md`, `a11y-check/README.md`, `Documentation/A11yCheck.md`, `A11yCheckView.swift`, and `AppStore.md`. `a11y-check --list-rules` reports 44.
- **WCAG criteria count corrected from 23 to 24** across the same files plus `SKILL.md`. Counted from the structured WCAG field of each rule only — criterion numbers that appear in rule description prose are ignored, and `2.4.6b` folds into `2.4.6` because the `b` suffix is a CVS internal test-case label rather than a WCAG criterion. `AppStore.md` now carries the exact command to recount, so the number can be re-derived instead of guessed.
- **Contributor-specific test fixture paths** replaced with neutral ones (`/tmp/checkout/MyApp`, `Modules/Feature/...`). They were absolute paths from the contributor's employer's build machine. String-only, so the test remains platform-independent.

## [iOS 26.7] - 2026-09-23

App Store release. The previously published version was **26.6**, so this release contains everything since then, including the work recorded below under the `26.7`, `26.8`, and `26.9` headers, which were never released to the App Store.

The app target's build number (`CURRENT_PROJECT_VERSION`) is `1`, and no bump is required: App Store Connect only requires a build number to be unique within a given version string, and 26.7 is a new version string.

The App Store description and other listing fields live in [AppStore.md](AppStore.md).

### App Store Release Notes

Copy the block below into the What's New field. Plain text, no Markdown — the App Store does not render it.

```text
New technique pages

• Accessibility Custom Content — attach extra details to an element so VoiceOver can offer them under the More Content rotor, without lengthening the element's name. Demonstrated with a seat map where a seat's window, middle, or aisle position exists only in the layout.
• Web View Dynamic Type — make text inside a WKWebView scale with Dynamic Type.
• Motion Actuation — offer an alternative to a shake gesture for people who cannot shake the device.

New examples on existing pages

• Drag & Drop — accessible .draggable() and .dropDestination(), plus what breaks without an accessibility action.
• Pickers — avoiding unexpected context changes when a control's value changes.
• Videos — why auto-playing audio is a barrier.
• Alerts — what goes wrong when focus is not returned to the trigger after dismissal.
• Accessibility Sort Priority — how misused sort priority reorders what VoiceOver reads.

Also in this release

• New Explore by Touch prototype reproducing a tab bar that VoiceOver cannot reach by touch, with an in-page breakdown of the three causes.
• Tabs now set a unique navigation bar title per tab.
• Fixed sample video URLs that had stopped loading.
• The Simulator's Hardware > Shake menu now triggers the Motion Actuation demo.
```

### a11y-check

These CLI changes were recorded under the app's release date. They ship to users as part of **[a11y-check 0.5.0]** above, which is cut from main and therefore includes them.

#### Changed

- **`label-in-name` rule** (`LabelInNameRules.swift`, WCAG 2.5.3): upgraded the "visible text present but not at the beginning" case from `warning` to `error`. WCAG 2.5.3 Understanding states the accessible name must be "identical to or begins with the same sequence of characters as the visible text label" — prepending non-visible text (e.g. `.accessibilityLabel("Quick reply: Yes")` on `Button("Yes")`) is a definitive failure because Voice Control prefix-matches against what users see on screen, not what comes after an invisible prefix. The diagnostic message now explicitly names the Voice Control impact and offers two fix options: move the visible text to the start of the label, or remove `.accessibilityLabel()` entirely so SwiftUI derives the accessible name from the visible label automatically.

#### Fixed

- **`--per-view` corrupting `--format html` output** (`A11yCheck.swift`, `HTMLFormatter.swift`). When running `a11y-check ... --format html --per-view`, the per-view scores were rendered using the terminal formatter (ANSI color codes, Unicode block-character progress bars) and printed unconditionally after the HTML body, making the HTML file unparseable in a browser. Per-view data is now computed once before the format switch. For `--format html` it is rendered as a native HTML table and embedded in the report. For `--format terminal` the colored terminal view is still printed as before. Other formats (`json`, `xcode`, `sarif`) silently skip the per-view section (no ANSI pollution).

#### Added

- **New rule `duplicate-button-label`** (`DuplicateButtonLabelRule.swift`, WCAG 2.4.6, error/serious). Flags two patterns: (1) `Button("same text")` appearing two or more times in the same file without a unique `.accessibilityLabel()` — VoiceOver users navigating by controls hear identical announcements and cannot distinguish which button acts on which item; (2) `Button("static label")` or any component with a `title: "static label"` argument used directly inside a `ForEach` closure — every iteration will produce the same label. Handles `String(localized: "...")` and ignores interpolated strings (dynamic by definition). Cross-file patterns (e.g., a `PSButton` inside a child component that is then used in a `ForEach`) are noted in the rule description as requiring manual audit. Registered in `RuleRegistry.swift` under Buttons. CVS test case TLASTIATI-1552 — 2.4.6b Descriptive Labels.

- **New rule `sort-priority-negative`** (`GroupingRules.swift`, WCAG 2.5.1 / 2.1.1 / 4.1.2, error/serious). Flags `.accessibilitySortPriority(-N)` with any negative numeric literal (`-1`, `-10`, `-1.5`, etc.). Sort priority also governs Explore by Touch hit testing — a negative-priority element loses hit tests to any overlapping default-priority (0) content, silently breaking VoiceOver Explore by Touch for floating overlays over scroll content. Empirically verified against the CVS Pharmacy app tab bar bug reproduced in `ExploreByTouchBrokenView`. The existing `sort-priority-overused` rule now skips negative literals so the two rules don't produce duplicate diagnostics on the same line. Includes 5 unit tests. Rule count updated from 42 to 43.
- **New rule `value-contains-role`** (`AccessibilityValueRules.swift`, WCAG 4.1.2). Flags `.accessibilityValue()` strings that contain role words like "button", "tab", "link", "toggle", "switch", "slider", "checkbox", "picker", "menu", or "search field". Values are for state (e.g. "50 percent", "selected item 2 of 5"), not role — VoiceOver announces the role automatically from accessibility traits. Placing a role word in the value causes VoiceOver to speak it twice and is often a symptom of a missing or removed trait. **Severity is `error` for most role words but downgraded to `warning` for `checkbox`** — iOS has no checkbox trait, so writing "checkbox" is a defensible workaround (WCAG 4.1.2 is already satisfied by the Toggle's Switch trait). Whole-word matching prevents false positives on descriptive terms like "linked" or "buttonhole". Applies to any view type, not just Button. Custom diagnostic messages for `checkbox` and `tab` point developers at the correct iOS pattern (Toggle + `.toggleStyle(CheckboxToggleStyle())` for checkboxes; `.isTabBar` / `.isSelected` traits for tabs). Includes 9 unit tests. Rule count updated from 41 to 42 across the app, docs, and READMEs.

### Documentation

#### Added

- **`AppStore.md`** — copy-paste source for the App Store Connect listing fields, holding the app name and a rewritten description. The previous live description had drifted, claiming 76 techniques when the index holds 89, so the file records which numbers are hand-maintained and where their source of truth is. The new description leads with the good-and-bad-example comparison rather than the format, since only the first few lines show before the "more" link; names WCAG 2.2 rather than bare WCAG; and advertises a11y-check, which the listing had never mentioned. Headings use Title Case rather than ALL CAPS, because some screen reader verbosity settings spell short all-caps strings out letter by letter. Release notes are deliberately not duplicated there — they stay in this file under each version's App Store Release Notes heading.

### iOSswiftUIa11yTechniques

#### Changed

- **Accessibility Sort Priority** documentation (`Documentation/AccessibilitySortPriority.md`): added a "Never use negative sort priority values" section explaining that sort priority also governs Explore by Touch hit testing, not just swipe reading order. Negative-priority overlays (e.g., a tab bar with `.accessibilitySortPriority(-1)`) lose hit tests to any overlapping scroll content, silently breaking Explore by Touch — a critical WCAG 2.5.1 / 2.1.1 failure. Includes concrete remediation steps and points readers at the `ExploreByTouchBrokenView` prototype. Added WCAG 2.1.1 Keyboard and 2.5.1 Pointer Gestures to the success criteria list.
- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): restored `.accessibilitySortPriority(-1)` on the tab bar after empirical testing confirmed it is required — without it, Explore by Touch reaches the tabs. Doc comment updated to note the empirical confirmation.
- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): wrapped the bug explanation panel in a `DisclosureGroup` so it is collapsed by default. Users tap the "Why the tab bar is unreachable by touch" header to expand.

#### Added

- **New technique page: Accessibility Custom Content** (`AccessibilityCustomContentView.swift`, `Documentation/AccessibilityCustomContent.md`). Covers `.accessibilityCustomContent` for attaching extra details to an element as labelled key and value pairs without adding them to its accessible name, exposed under VoiceOver's More Content rotor. Leads with Apple's own stated purpose from the WWDC21 session "Tailor the VoiceOver experience in your data-rich apps" — delivering information from data-rich elements concisely and only when someone wants it — rather than only the repo's rationale. Does not teach VoiceOver rotor gestures, just states where the details appear. Documented as an accessibility usability enhancement rather than a conformance requirement — not using it fails no success criterion, so the page lists its WCAG criteria as `N/A` and has no bad examples, matching the existing `Rotor.md` precedent. Good example is a seat map: each seat is a `Button` containing only `Text("14C")` with **no `.accessibilityLabel` anywhere**, so VoiceOver derives the name from the visible text, and `.accessibilityCustomContent` carries the two dimensions that exist nowhere as text — whether it is a window seat, middle seat, or aisle seat (conveyed only by the seat's column, `importance: .high` because it is the attribute people choose a seat by) and front/middle/rear cabin area (conveyed only by vertical position, default importance). Seats use `.frame(maxWidth: .infinity, minHeight: 44)` so a row of six plus the aisle always fits the screen width — a fixed 44pt width overflowed narrower devices, widening the scroll view and clipping the body text on both edges. Verified on an iPhone SE (3rd generation) simulator that the row fits and the 44pt touch target height is preserved. Both use a reusable `AccessibilityCustomContentKey` with a stable `id` so the details keep a consistent rotor position across the grid. Seats are `Toggle`s with a custom `SeatToggleStyle` so VoiceOver conveys both the on and the off state, which a `Button` with only `.isSelected` cannot. The prose stays on `.accessibilityCustomContent` rather than explaining selection semantics or toggle styling, which belong to the Toggles and Multi-Selection Lists pages. Documents the verified announcement: focusing an unselected window seat speaks "12A, Window seat, Switch button, off, Double tap to toggle setting", confirming that `.high` content is spoken after the accessible name and before the role, that an empty content key label yields just the value rather than a redundant "Position, Window seat", and that `.default` importance content is not announced at all until requested from the rotor. Documentation states the two rules that follow from "custom content adds, it never replaces": never put information there that sighted users do not already have, and never put essential information there. Includes a "Discoverability" section explaining that `.default` importance content is always reachable through the More Content rotor, but VoiceOver's Verbosity > More Content setting controls whether users get any cue that an element has it — speak a hint, play a sound, change pitch, or Do Nothing. Set to Do Nothing there is no cue at all, so this is a discoverability limit rather than an availability one, and `.high` importance is immune to it because VoiceOver speaks that content as part of the element's announcement. Verified against a real device configuration. Also notes `.default` vs `.high` behavior, the unavailable `String`-label overload (wrap in `Text` or use a key), and iOS 15 availability. Registered in `Techniques.swift`, `ContentView.swift`, and the README documentation index.
- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): added an in-page bug explanation panel at the top of the scroll content. Describes the three compounding mechanisms — `.ignoresSafeArea(edges: .bottom)` on scroll content, `.accessibilitySortPriority(-1)` on the tab bar, and `.accessibilityElement(children: .combine)` on the cards — so readers can understand why the tab bar becomes unreachable via Explore by Touch even though swipe navigation still works. Panel uses a warning icon, orange border, and numbered steps with combined accessibility labels for VoiceOver. File-level doc comment expanded to describe the same three mechanisms.

#### Changed

- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): combined `ContentCard` accessibility focus into a single element matching CVS `ActivityCardView` — `.accessibilityElement(children: .combine)` with a merged `accessibilityLabel` ("title. subtitle") and `.accessibilityAddTraits(.isButton)`. VoiceOver now announces the whole card as one button instead of stopping on title, illustration, and subtitle separately.
- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): enlarged `ContentCard` to match the CVS Activity carousel cards — 360 pt tall, large 28 pt bold title at top, large centered SF Symbol illustration in the middle, `Divider` above a subtitle caption at the bottom, thin border + subtle shadow.
- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): added `.accessibilitySortPriority(-1)` to the tab bar container, matching `UnifiedNavigationTabBarView`'s setting in the CVS codebase. SwiftUI builds the accessibility hit-test tree in priority order (higher first); scroll content (default priority 0) is therefore checked before the tab buttons (-1), so Explore by Touch on any part of the tab bar — not just the 32 pt empty zone — now focuses scroll content instead of a tab button, replicating the full CVS bug.
- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): redesigned tab bar to match the CVS Pharmacy app visual — white pill with drop shadows (standard `backgroundBubble` mode), `systemFill` rounded-rect highlight on the selected tab (matches `TabsBubbleView.tabs`), CVS brand red icons, and 5 tabs (Home, Pharmacy, Health, Shop, Search) matching the real tab labels. Bug mechanisms unchanged: `.ignoresSafeArea(edges: .bottom)` on scroll content and `.padding(.top, 32)` empty zone above the pill.

## iOS 26.7 development — 2026-08-27

### iOSswiftUIa11yTechniques

#### Changed

- **Explore by Touch Broken** prototype (`ExploreByTouchBrokenView.swift`): rewrote to match `H100HomeScreenView` layout from the CVS codebase. Uses a `ZStack` (no overlay modifier) with the scroll content using `.ignoresSafeArea(edges: .bottom)` so it extends behind the floating tab bar. Tab bar sits inside the ZStack with `.padding(.top, 32)` matching `UnifiedNavigationTabBarView` — that 32 pt empty zone above the pill has no accessibility elements, so Explore by Touch there falls through to the scroll content. Tab buttons use `.accessibilityRemoveTraits(.isButton)` matching `BottomTabBubbleView`.

## iOS 26.7 development — 2026-08-26

### iOSswiftUIa11yTechniques

#### Added

- **Web View Dynamic Type** technique page (`WebViewDynamicTypeView.swift`) with good example (WKWebView using CSS `font: -apple-system-body` + `.id(dynamicTypeSize)` reload) and bad example (fixed `font-size: 16px` that ignores Dynamic Type). Demonstrates how to make web view text resizable with Dynamic Type (WCAG 1.4.4 Resize Text).
- **`WebViewDynamicType.md`** documentation explaining the CSS `-apple-system-*` font shorthands and the SwiftUI `.id(dynamicTypeSize)` reload pattern.

#### Changed

- Moved "Web View Apple System CSS Font Test" from Prototypes to the new **Web View Dynamic Type** technique page.
- Removed `WebView.swift` prototype file; replaced by `WebViewDynamicTypeView.swift` in the techniques layer.

## iOS 26.7 development — 2026-08-20

### Documentation

#### Changed

- Updated rule count from 37 to **41 rules** across **23 WCAG criteria** in `README.md`, `a11y-check/README.md`, `A11yCheckView.swift`, `A11yCheck.md`, and `SKILL.md`.
- Added missing rules (`video-audio-autoplay`, `motion-actuation-missing-alternative`, `input-triggers-context-change`, `draggable-missing-accessibility-action`) to the rules table in `a11y-check/README.md`.
- Fixed animation rule WCAG criterion in `a11y-check/README.md` table from `2.3.1` to `2.2.2`.
- Resolved unresolved git merge conflict in `SKILL.md`.

### a11y-check

#### Changed

- **`animation-missing-reduce-motion`** — downgraded from `error`/`serious` to `warning`/`moderate` and fixed WCAG criterion from `2.3.1` (Three Flashes, wrong) to `2.2.2` (Pause, Stop, Hide, Level AA). `@Environment(\.accessibilityReduceMotion)` is the SwiftUI mechanism for WCAG 2.2.2 — it stops auto-playing looping animations when the user enables Reduce Motion. Warning because static analysis cannot determine whether an animation loops >5 seconds, starts automatically, or is essential, and `withAnimation` is also used for incidental transitions that are hard to distinguish from problematic looping animations.

#### Added

- **`draggable-missing-accessibility-action`** (warning, WCAG 2.5.7, 2.1.1) — Flags `.draggable()`, `.dropDestination()`, or `.onDrag()` without `.accessibilityAction(named:)` alternatives. Covers both the SwiftUI Transferable API and the older UIKit-backed `.onDrag()` API. Covers the high-level SwiftUI drag-and-drop API; the existing `gesture-missing-alternative` rule covers the lower-level `.gesture(DragGesture())` API. Emitted as a warning because the accessibility actions may be defined in a parent view.
- **`motion-actuation-missing-alternative`** (warning, WCAG 2.5.4) — Flags `CMMotionManager` and CoreMotion update methods (`startAccelerometerUpdates`, `startGyroUpdates`, `startDeviceMotionUpdates`, `startMagnetometerUpdates`) without a confirmed UI control alternative in the same file. Emitted as a warning because the UI alternative may be in a parent view or different file.
- **`input-triggers-context-change`** (warning, WCAG 3.2.2) — Flags `.onChange` on `Picker`, `Toggle`, `Slider`, `DatePicker`, or `Stepper` whose closure calls `dismiss()` or mutates a navigation path. Emitted as a warning because the dismiss may be intentional with prior user notice.
- **`video-audio-autoplay`** (warning, serious, WCAG 1.4.2) — Flags `.play()` called inside `.onAppear {}` or `.task {}`, causing audio or video to start automatically without user initiation. Emitted as a warning because silent decorative video may be acceptable — review manually. Impact raised to `serious` (from `moderate`) to reflect WCAG Level A requirement.

### iOSswiftUIa11yTechniques

#### Added

- **Motion Actuation** technique view (`MotionActuationView.swift`) with good example (CMMotionManager + Undo Button) and bad example (CMMotionManager only, no Button alternative). Demonstrates the `motion-actuation-missing-alternative` rule (WCAG 2.5.4).
- **Drag & Drop** — added good and bad `.draggable()` / `.dropDestination()` API examples to `DragDropView.swift`. Good example includes `.accessibilityAction(named: "Move Up/Down")`; bad example uses `.draggable()` without any accessibility actions. Demonstrates the `draggable-missing-accessibility-action` rule (WCAG 2.5.7).
- **Pickers** — added Context Changes on Input good and bad examples to `PickersView.swift`. Good example uses a separate Save Button for dismiss; bad example calls `dismiss()` directly inside `.onChange`. Demonstrates the `input-triggers-context-change` rule (WCAG 3.2.2).
- **Videos** — added Auto-play bad example to `VideosView.swift` showing `.onAppear { player.play() }`. Demonstrates the `video-audio-autoplay` rule (WCAG 1.4.2).

#### Fixed

- **Videos** — replaced bad example video URLs (`commondatastorage.googleapis.com`) which now return 403 with working alternatives: `learningcontainer.com` (bad player example) and `filesamples.com` (auto-play example).
- **Motion Actuation** — Simulator `Hardware > Shake` now triggers the undo demo. The Simulator sends `UIEvent.motionShake` through the UIKit responder chain, not through `CMMotionManager`; added `ShakeDetector: UIViewControllerRepresentable` (wrapping a `UIViewController` that overrides `motionEnded`) as a companion to the existing `CMMotionManager` path, which continues to handle real-device shake.
- `XcodeFormatter` now maps `.info` severity diagnostics to `note:` (Xcode inline annotation level) instead of `warning:`. Previously info-level findings appeared as warnings in the Xcode issue navigator.

## iOS 26.7 development — 2026-08-13

### iOSswiftUIa11yTechniquesUITests

#### Fixed

- `testA11yCheck` and `testInformative` now report all `performAccessibilityAudit` failures in a single run. Previously each test would throw and stop at the first issue; now all issues are collected via the `issueHandler` closure and reported individually with `XCTFail`.
- New `XCTestAccessibilityView` page added with intentional good/bad examples for each `performAccessibilityAudit` failure type: missing accessibility label (button wrapping a shape with no label), insufficient contrast (light gray text on explicit white background), small hit area (20×20 button), and visually clipped text. Paired `testXCTestAccessibility()` uses the collect-all-failures pattern and scrolls down before the second audit to reveal the bad examples section, ensuring all failures are detected.

## iOS 26.7 development — 2026-07-29

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

## [26.9 — not an App Store release] - 2026-07-13

### a11y-check

#### Fixed

- `color-contrast-insufficient` rule now checks dark-mode and Increase Contrast asset variants — `.xcassets` color sets with `dark` or `high-contrast` appearance entries are resolved per theme and contrast is evaluated for each; the diagnostic message names the failing theme (e.g. "…in Dark Mode…"). Light-mode-only catalogs are unaffected.
- `color-contrast-insufficient` rule now pairs a text view's foreground color with the nearest enclosing container's (VStack, HStack, ZStack, ScrollView, List, etc.) `.background` when no same-chain background is present. Sibling view backgrounds are never paired. Ancestor-sourced diagnostics include a note "(background inherited from enclosing container)".
- `color-contrast-insufficient` rule now applies the WCAG 1.4.3 large-text threshold (3.0:1) to `.font(.system(size: N))` when `N ≥ 18`, or `N ≥ 14` with a bold/semibold/heavy/black weight. Previously only named styles (`.largeTitle`, `.title`, `.title2`, `.title3`) triggered the lower threshold.
- Fixed an internal `isInsideClosure` guard that was checking parent nodes in the wrong direction, causing all text views inside container closures to be silently skipped by the contrast rule regardless of whether a valid foreground/background pair existed. Replaced with `ModifierCollector.collectChainOnly` which is correct-by-construction.

#### Changed

- `AssetCatalogParser.discoverColors(in:)` now returns `ThemedColorMap` (`[String: ThemedColor]`) instead of a flat `[String: RGBA]`. `ThemedColor` carries `light`, `dark`, `highContrast`, and `darkHighContrast` variants with a `resolve(darkMode:contrastMode:)` helper. This is a **minor-version API change** — callers that assign to `RuleRegistry.assetColors` must update to `ThemedColorMap`. (WCAG 1.4.3)
- Added `bold`, `fontWeight`, and `italic` to `ModifierCollector.trackedModifiers`.

## [26.8 — not an App Store release] - 2026-06-10

### iOS App

#### Added

- Bad example native alert without focus management on Alerts technique page — uses `.alert()` but does not use `AccessibilityFocusState` to return focus to the trigger button when dismissed

### a11y-check

#### Added

- `button-group-missing-container-label` rule (warning, WCAG 1.3.1) — flags HStack/VStack/LazyVGrid/LazyHStack containers of 2+ Buttons that have a visible group label (preceding Text) but are missing `.accessibilityElement(children: .contain)` and/or `.accessibilityLabel()`, so VoiceOver users hear the group context when navigating to the buttons

## [26.7 — not an App Store release] - 2026-05-19

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






