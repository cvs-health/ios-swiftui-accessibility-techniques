/*
   Copyright 2026 CVS Health and/or one of its affiliates

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import SwiftUI

struct A11yCheckView: View {
    @State private var toggleGood = true
    @State private var toggleBad = true
    @State private var textFieldGood = ""
    @State private var textFieldBad = ""
    @State private var emailFieldGood = ""
    @State private var emailFieldBad = ""
    @State private var sliderGood: Double = 50
    @State private var sliderBad: Double = 50
    @State private var stepperGood: Int = 5
    @State private var stepperBad: Int = 5
    @State private var pickerGood = "Apple"
    @State private var pickerBad = "Apple"
    @State private var segmentedGood = "A"
    @State private var segmentedBad = "A"
    @State private var showSheetGood = false
    @State private var showSheetBad = false
    @AccessibilityFocusState private var isSheetTriggerFocused: Bool
    @State private var showToastBad = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var animationOffset: CGFloat = 0
    @State private var swipeOffset: CGFloat = 0
    @State private var swipeDeleted = false
    @AccessibilityFocusState private var isDeletedTextFocused: Bool
    @State private var badSwipeOffset: CGFloat = 0
    @State private var badSwipeDeleted = false

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL

    var body: some View {
        ScrollView {
            VStack {
                Text("`a11y-check` is a static analysis tool that scans SwiftUI source code for accessibility issues. It includes 37 rules across 19 WCAG 2.2 success criteria. The good examples below pass the `a11y-check` rules. The bad examples trigger `a11y-check` violations. Run `a11y-check .` in your project folder to scan your own code.")
                    .padding(.bottom)
                // MARK: - Good Examples
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                // MARK: Good Images
                Text("Good Example Images")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
                        .foregroundColor(.orange)
                        .accessibilityLabel("Upload warning")
                    Image(systemName: "arrow.up.heart.fill")
                        .foregroundColor(.red)
                        .accessibilityHidden(true)
                    Text("Liked")
                }
                DisclosureGroup("Details") {
                    Text("The good image example uses `.accessibilityLabel(\"Upload warning\")` on the first image, passing the `image-missing-label` rule. The label says \"Upload warning\" not \"Upload warning icon\", passing the `image-label-contains-role` rule. The decorative heart image uses `.accessibilityHidden(true)` since the adjacent text already conveys the meaning.")
                }.padding(.bottom).accessibilityHint("Good Example Images")
                // MARK: Good Headings
                Text("Good Example Headings")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Account Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Manage your account preferences below.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good heading example uses `.font(.headline)` with `.accessibilityAddTraits(.isHeader)`, passing the `heading-trait-missing` rule. The heading trait is applied using the proper API rather than faking it in the accessibility label, passing the `fake-heading-in-label` rule.")
                }.padding(.bottom).accessibilityHint("Good Example Headings")
                // MARK: Good Buttons
                Text("Good Example Buttons")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Button {} label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete")
                    Button {} label: {
                        Text("Save")
                    }
                    .disabled(true)
                }
                DisclosureGroup("Details") {
                    Text("The good button examples pass three rules. The icon-only trash button has `.accessibilityLabel(\"Delete\")`, passing `icon-button-missing-label`. The label says \"Delete\" not \"Delete button\", passing `button-label-contains-role`. The disabled Save button uses `.disabled(true)` rather than just visual opacity, passing `visually-disabled-not-semantic`.")
                }.padding(.bottom).accessibilityHint("Good Example Buttons")
                // MARK: Good Traits
                Text("Good Example Traits")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .onTapGesture {}
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Blue Circle")
                DisclosureGroup("Details") {
                    Text("The good traits example uses `.onTapGesture` with `.accessibilityAddTraits(.isButton)` so VoiceOver announces the element as interactive, passing the `tap-gesture-missing-button-trait` rule.")
                }.padding(.bottom).accessibilityHint("Good Example Traits")
                // MARK: Good Toggles
                Text("Good Example Toggles")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Toggle("Wi-Fi", isOn: $toggleGood)
                DisclosureGroup("Details") {
                    Text("The good toggle example uses `Toggle(\"Wi-Fi\", isOn:)` with a visible label, passing the `toggle-missing-label` rule.")
                }.padding(.bottom).accessibilityHint("Good Example Toggles")
                // MARK: Good Links
                Text("Good Example Links")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Link("CVS Health Website", destination: URL(string: "https://www.cvshealth.com")!)
                    .accessibilityRemoveTraits(.isButton)
                DisclosureGroup("Details") {
                    Text("The good link example uses a `Link` view instead of a `Button` with `openURL`, passing the `button-used-as-link` rule. The link text says \"CVS Health Website\" rather than \"Click here\", passing the `generic-link-text` rule.")
                }.padding(.bottom).accessibilityHint("Good Example Links")
                // MARK: Good Touch Targets
                Text("Good Example Touch Targets")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button {} label: {
                    Image(systemName: "plus")
                }
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Add")
                DisclosureGroup("Details") {
                    Text("The good touch target example uses `.frame(minWidth: 44, minHeight: 44)` ensuring the button meets the minimum touch target size, passing the `small-touch-target` rule.")
                }.padding(.bottom).accessibilityHint("Good Example Touch Targets")
                // MARK: Good Dynamic Type
                Text("Good Example Dynamic Type")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text scales with Dynamic Type.")
                    .font(.body)
                DisclosureGroup("Details") {
                    Text("The good Dynamic Type example uses `.font(.body)` which scales with the user's preferred text size, passing the `fixed-font-size` rule. No `.lineLimit(1)` is used so the text wraps rather than truncating, passing the `line-limit-1` rule.")
                }.padding(.bottom).accessibilityHint("Good Example Dynamic Type")
                // MARK: Good Page Titles
                Text("Good Example Page Titles")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This page uses `.navigationTitle(\"a11y-check\")` on the scroll view container.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good page title example uses `.navigationTitle()` on the view inside a `NavigationStack`, passing the `missing-navigation-title` rule. Every screen should have a navigation title so VoiceOver users know which page they are on.")
                }.padding(.bottom).accessibilityHint("Good Example Page Titles")
                // MARK: Good Accessibility Hidden
                Text("Good Example Accessibility Hidden")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .accessibilityHidden(true)
                    Button("Continue") {}
                }
                DisclosureGroup("Details") {
                    Text("The good accessibility hidden example only hides the decorative checkmark image, not the interactive Button. This passes the `hidden-parent-with-controls` rule because `.accessibilityHidden(true)` is not applied to a container that has interactive children.")
                }.padding(.bottom).accessibilityHint("Good Example Accessibility Hidden")
                // MARK: Good Color Contrast
                Text("Good Example Color Contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text uses adaptive colors.")
                    .foregroundColor(.primary)
                DisclosureGroup("Details") {
                    Text("The good color contrast example uses `.foregroundColor(.primary)` which adapts to both light and dark mode, passing the `hardcoded-color` rule. Adaptive colors like `.primary`, `.secondary`, and semantic system colors automatically provide sufficient contrast in all appearances.")
                }.padding(.bottom).accessibilityHint("Good Example Color Contrast")
                // MARK: Good Form Controls
                Text("Good Example Form Controls")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing: 2) {
                    Text("Search")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $textFieldGood)
                        .accessibilityLabel("Search")
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.bottom, 8)
                VStack(spacing: 2) {
                    Text("Email")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $emailFieldGood)
                        .accessibilityLabel("Email")
                        .textContentType(.emailAddress)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.bottom, 8)
                VStack(spacing: 2) {
                    Text("Volume")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Slider(value: $sliderGood, in: 0...100) {
                        Text("Volume")
                    }
                }
                .padding(.bottom, 8)
                Stepper("Quantity: \(stepperGood)", value: $stepperGood, in: 0...10)
                    .padding(.bottom, 8)
                VStack(spacing: 2) {
                    Text("Fruit")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Picker("Fruit", selection: $pickerGood) {
                        Text("Apple").tag("Apple")
                        Text("Banana").tag("Banana")
                    }
                }
                VStack(spacing: 2) {
                    Text("Option")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Picker("Option", selection: $segmentedGood) {
                        Text("A").tag("A")
                        Text("B").tag("B")
                    }
                    .pickerStyle(.segmented)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Option")
                }
                DisclosureGroup("Details") {
                    Text("The good form control examples pass five rules. The `TextField` has `.accessibilityLabel(\"Search\")`, passing `textfield-missing-label`. The email field has `.textContentType(.emailAddress)`, passing `input-missing-purpose`. The `Slider` has a \"Volume\" label, passing `slider-missing-label`. The `Stepper` has a \"Quantity\" label, passing `stepper-missing-label`. The `Picker` has a \"Fruit\" label, passing `picker-missing-label`. The segmented `Picker` has both `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Option\")`, passing `picker-style-missing-accessibility`.")
                }.padding(.bottom).accessibilityHint("Good Example Form Controls")
                // MARK: Good Focus
                Text("Good Example Focus")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Show Sheet") {
                    showSheetGood = true
                }
                .accessibilityFocused($isSheetTriggerFocused)
                .sheet(isPresented: $showSheetGood, onDismiss: {
                    isSheetTriggerFocused = true
                }) {
                    VStack {
                        Text("Sheet Content")
                        Button("Dismiss") {
                            showSheetGood = false
                        }
                    }
                    .presentationDetents([.medium])
                }
                DisclosureGroup("Details") {
                    Text("The good focus example uses `@AccessibilityFocusState` to return VoiceOver focus to the trigger button when the sheet is dismissed, passing the `sheet-focus-return` rule.")
                }.padding(.bottom).accessibilityHint("Good Example Focus")
                // MARK: Good Animation
                Text("Good Example Animation")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Circle()
                    .fill(Color.purple)
                    .frame(width: 30, height: 30)
                    .offset(x: animationOffset)
                Button("Animate") {
                    if reduceMotion {
                        animationOffset = animationOffset == 0 ? 50 : 0
                    } else {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            animationOffset = animationOffset == 0 ? 50 : 0
                        }
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good animation example checks `@Environment(\\.accessibilityReduceMotion)` before using `withAnimation`, passing the `animation-missing-reduce-motion` rule. When Reduce Motion is enabled the position changes instantly without animation.")
                }.padding(.bottom).accessibilityHint("Good Example Animation")
                // MARK: Good Tab Bars
                Text("Good Example Tab Bars")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("The `tabview-missing-label` rule flags views inside a `TabView` that lack a `.tabItem` modifier, and custom tab bar containers using `.accessibilityAddTraits(.isTabBar)` that are missing an `.accessibilityLabel()`. Every tab must have `.tabItem { Label(\"Name\", systemImage: \"icon\") }` so VoiceOver users can identify each tab. Custom tab bars must use `.accessibilityElement(children: .contain)`, `.accessibilityAddTraits(.isTabBar)`, and `.accessibilityLabel()` so VoiceOver users hear the tab bar name and tab count.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The `tabview-missing-label` rule maps to WCAG 4.1.2 Name, Role, Value and WCAG 2.4.2 Page Titled. Without `.tabItem` labels, tabs have no accessible name. Custom tab bars using `.accessibilityAddTraits(.isTabBar)` without `.accessibilityLabel()` leave VoiceOver users without context about what the tab bar is for. See the Tabs technique page for full custom tab bar examples.")
                }.padding(.bottom).accessibilityHint("Good Example Tab Bars")
                // MARK: Good Gestures
                Text("Good Example Gestures")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                if swipeDeleted {
                    Text("Item deleted")
                        .foregroundColor(.secondary)
                        .padding()
                        .accessibilityFocused($isDeletedTextFocused)
                } else {
                    HStack {
                        Text("Swipe left or tap Delete")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .offset(x: swipeOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.width < 0 {
                                            swipeOffset = value.translation.width
                                        }
                                    }
                                    .onEnded { value in
                                        if value.translation.width < -100 {
                                            swipeDeleted = true
                                            isDeletedTextFocused = true
                                        }
                                        swipeOffset = 0
                                    }
                            )
                            .accessibilityAction(named: "Delete") {
                                swipeDeleted = true
                                isDeletedTextFocused = true
                            }
                        Button("Delete") {
                            swipeDeleted = true
                            isDeletedTextFocused = true
                        }
                        .foregroundColor(.red)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good gestures example uses `.gesture(DragGesture())` with both a visible single-tap `Button(\"Delete\")` alternative for touch users who cannot perform a swipe gesture, and an `.accessibilityAction(named: \"Delete\")` for VoiceOver users, passing the `gesture-missing-alternative` rule. WCAG 2.5.1 requires that path-based gestures have a single-pointer alternative so all touch users can perform the action.")
                }.padding(.bottom).accessibilityHint("Good Example Gestures")
                // MARK: Good Reading Order / Grouping
                Text("Good Example Reading Order / Grouping")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Image(systemName: "person.fill")
                    Text("John Doe")
                }
                .accessibilityElement(children: .combine)
                DisclosureGroup("Details") {
                    Text("The good grouping example uses `.accessibilityElement(children: .combine)` on an `HStack` containing an `Image` and `Text`, passing the `missing-accessibility-grouping` rule. VoiceOver reads the combined content as a single element.")
                }.padding(.bottom).accessibilityHint("Good Example Reading Order / Grouping")
                // MARK: Good Label in Name
                Text("Good Example Label in Name")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Save Changes") {}
                    .accessibilityLabel("Save Changes")
                DisclosureGroup("Details") {
                    Text("The good label in name example has a `.accessibilityLabel` that matches the visible text \"Save Changes\", passing the `label-in-name` rule. Speech input users can activate the button by saying what they see on screen.")
                }.padding(.bottom).accessibilityHint("Good Example Label in Name")
                // MARK: - Bad Examples
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                // MARK: Bad Images
                Text("Bad Example Images")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
                        .foregroundColor(.orange)
                    Image(systemName: "arrow.up.heart.fill")
                        .foregroundColor(.red)
                        .accessibilityLabel("Heart icon")
                }
                DisclosureGroup("Details") {
                    Text("The bad image examples fail two rules. The first image has no `.accessibilityLabel` or `.accessibilityHidden(true)`, failing the `image-missing-label` rule. VoiceOver reads the raw SF Symbol name which is not meaningful. The second image label says \"Heart icon\" which includes the word \"icon\", failing the `image-label-contains-role` rule since VoiceOver already announces the image role. Note: words like \"photo\" and \"picture\" are valid descriptive terms and are not flagged by this rule.")
                }.padding(.bottom).accessibilityHint("Bad Example Images")
                // MARK: Bad Headings
                Text("Bad Example Headings")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Account Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Profile Options")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("heading Profile Options")
                DisclosureGroup("Details") {
                    Text("The bad heading examples fail two rules. \"Account Settings\" uses `.font(.headline)` but has no `.accessibilityAddTraits(.isHeader)`, failing the `heading-trait-missing` rule. \"Profile Options\" fakes the heading announcement by putting the word \"heading\" in its `.accessibilityLabel`, failing the `fake-heading-in-label` rule. Use `.accessibilityAddTraits(.isHeader)` instead.")
                }.padding(.bottom).accessibilityHint("Bad Example Headings")
                // MARK: Bad Buttons
                Text("Bad Example Buttons")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Button {} label: {
                        Image(systemName: "trash")
                    }
                    Button {} label: {
                        Image(systemName: "pencil")
                    }
                    .accessibilityLabel("Edit button")
                    Button {} label: {
                        Text("Submit")
                    }
                    .opacity(0.4)
                }
                DisclosureGroup("Details") {
                    Text("The bad button examples fail three rules. The trash button has no `.accessibilityLabel`, failing `icon-button-missing-label`. The pencil button label says \"Edit button\" which includes the word \"button\", failing `button-label-contains-role`. The Submit button uses `.opacity(0.4)` to appear disabled but has no `.disabled(true)`, failing `visually-disabled-not-semantic`.")
                }.padding(.bottom).accessibilityHint("Bad Example Buttons")
                // MARK: Bad Traits
                Text("Bad Example Traits")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Circle()
                    .fill(Color.orange)
                    .frame(width: 50, height: 50)
                    .onTapGesture {}
                    .accessibilityLabel("Orange Circle")
                DisclosureGroup("Details") {
                    Text("The bad traits example uses `.onTapGesture` but has no `.accessibilityAddTraits(.isButton)`, failing the `tap-gesture-missing-button-trait` rule. VoiceOver will not announce this element as interactive.")
                }.padding(.bottom).accessibilityHint("Bad Example Traits")
                // MARK: Bad Toggles
                Text("Bad Example Toggles")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Wi-Fi")
                    Toggle("", isOn: $toggleBad)
                }
                DisclosureGroup("Details") {
                    Text("The bad toggle example has a visible \"Wi-Fi\" text label but it is a separate `Text` element not connected to the `Toggle`. The `Toggle(\"\", isOn:)` has an empty label string and no `.accessibilityLabel`, failing the `toggle-missing-label` rule. VoiceOver users will not know what this toggle controls because the visible text is not programmatically associated with it.")
                }.padding(.bottom).accessibilityHint("Bad Example Toggles")
                // MARK: Bad Links
                Text("Bad Example Links")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Click here") {
                    openURL(URL(string: "https://www.cvshealth.com")!)
                }
                DisclosureGroup("Details") {
                    Text("The bad link example fails two rules. A `Button` is used with `openURL` to navigate to a URL, failing the `button-used-as-link` rule — use `Link` instead. The text says \"Click here\" which is generic and non-descriptive, failing the `generic-link-text` rule.")
                }.padding(.bottom).accessibilityHint("Bad Example Links")
                // MARK: Bad Touch Targets
                Text("Bad Example Touch Targets")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button {} label: {
                    Image(systemName: "plus")
                        .font(.caption2)
                }
                .frame(width: 20, height: 20)
                .accessibilityLabel("Add")
                DisclosureGroup("Details") {
                    Text("The bad touch target example uses `.frame(width: 20, height: 20)` which is below the minimum 24pt touch target size, failing the `small-touch-target` rule. Small targets are hard to tap for users with motor impairments.")
                }.padding(.bottom).accessibilityHint("Bad Example Touch Targets")
                // MARK: Bad Dynamic Type
                Text("Bad Example Dynamic Type")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text does not scale.")
                    .font(.system(size: 14))
                    .lineLimit(1)
                DisclosureGroup("Details") {
                    Text("The bad Dynamic Type example fails two rules. `.font(.system(size: 14))` uses a fixed font size that does not scale with Dynamic Type, failing the `fixed-font-size` rule. `.lineLimit(1)` truncates text at larger sizes, failing the `line-limit-1` rule.")
                }.padding(.bottom).accessibilityHint("Bad Example Dynamic Type")
                // MARK: Bad Page Titles
                Text("Bad Example Page Titles")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("A `NavigationStack` with no `.navigationTitle()` fails the `missing-navigation-title` rule. VoiceOver users will not hear a page title when the screen loads.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The `missing-navigation-title` rule checks that every `NavigationStack` or `NavigationView` has a `.navigationTitle()` somewhere in its view hierarchy. Without a title, VoiceOver users cannot identify which screen they are on.")
                }.padding(.bottom).accessibilityHint("Bad Example Page Titles")
                // MARK: Bad Accessibility Hidden
                Text("Bad Example Accessibility Hidden")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .accessibilityHidden(true)
                    Button("Cancel") {}
                        .accessibilityHidden(true)
                }
                DisclosureGroup("Details") {
                    Text("The bad accessibility hidden example uses `.accessibilityHidden(true)` on the Cancel button, hiding an interactive control from VoiceOver. The `hidden-parent-with-controls` rule flags when `.accessibilityHidden(true)` is applied to a container with interactive children, or when interactive controls themselves are hidden. VoiceOver users will not be able to activate the Cancel button.")
                }.padding(.bottom).accessibilityHint("Bad Example Accessibility Hidden")
                // MARK: Bad Color Contrast
                Text("Bad Example Color Contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text uses hardcoded colors.")
                    .foregroundColor(.black)
                DisclosureGroup("Details") {
                    Text("The bad color contrast example uses `.foregroundColor(.black)` which is a hardcoded color that does not adapt to Dark Mode, failing the `hardcoded-color` rule. In Dark Mode, black text on a dark background will have insufficient contrast. The `color-contrast-insufficient` rule checks computed contrast ratios against WCAG requirements (4.5:1 for normal text).")
                }.padding(.bottom).accessibilityHint("Bad Example Color Contrast")
                // MARK: Bad Form Controls
                Text("Bad Example Form Controls")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                TextField("Search", text: $textFieldBad)
                    .textFieldStyle(.roundedBorder)
                TextField("Email", text: $emailFieldBad)
                    .textFieldStyle(.roundedBorder)
                Slider(value: $sliderBad, in: 0...100)
                    .labelsHidden()
                HStack {
                    Text("Quantity")
                    Stepper("", value: $stepperBad, in: 0...10)
                }
                Picker("", selection: $pickerBad) {
                    Text("Apple").tag("Apple")
                    Text("Banana").tag("Banana")
                }
                Picker("Option", selection: $segmentedBad) {
                    Text("A").tag("A")
                    Text("B").tag("B")
                }
                .pickerStyle(.segmented)
                DisclosureGroup("Details") {
                    Text("The bad form control examples fail six rules. The `TextField` fields use placeholder text which has insufficient contrast and disappears when typing, and have no `.accessibilityLabel`, failing `textfield-missing-label`. The email `TextField` has no `.textContentType(.emailAddress)`, failing `input-missing-purpose`. The `Slider` uses `.labelsHidden()` with no `.accessibilityLabel`, failing `slider-missing-label`. The `Stepper` has a visible \"Quantity\" text next to it but it is a separate `Text` element not programmatically associated with the `Stepper`, which has an empty label, failing `stepper-missing-label`. The `Picker` has an empty label, failing `picker-missing-label`. The segmented `Picker` is missing `.accessibilityElement(children: .contain)` and `.accessibilityLabel()`, failing `picker-style-missing-accessibility`.")
                }.padding(.bottom).accessibilityHint("Bad Example Form Controls")
                // MARK: Bad Focus
                Text("Bad Example Focus")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Show Sheet") {
                    showSheetBad = true
                }
                .sheet(isPresented: $showSheetBad) {
                    VStack {
                        Text("Sheet Content")
                        Button("Dismiss") {
                            showSheetBad = false
                        }
                    }
                    .presentationDetents([.medium])
                }
                DisclosureGroup("Details") {
                    Text("The bad focus example uses `.sheet(isPresented:)` with no `onDismiss` handler to return VoiceOver focus to the trigger button, failing the `sheet-focus-return` rule. After the sheet is dismissed, VoiceOver focus is lost and may jump to an unexpected location.")
                }.padding(.bottom).accessibilityHint("Bad Example Focus")
                // MARK: Bad Animation
                Text("Bad Example Animation")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("The `animation-missing-reduce-motion` rule flags files that use `.animation()` or `withAnimation` without checking `@Environment(\\.accessibilityReduceMotion)` or `UIAccessibility.isReduceMotionEnabled`.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The `animation-missing-reduce-motion` rule ensures animations respect the user's Reduce Motion preference. Users with vestibular disorders may experience discomfort from animations that cannot be disabled.")
                }.padding(.bottom).accessibilityHint("Bad Example Animation")
                // MARK: Bad Gestures
                Text("Bad Example Gestures")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                if badSwipeDeleted {
                    Text("Item deleted")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    Text("Swipe left to delete")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .offset(x: badSwipeOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.width < 0 {
                                        badSwipeOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.width < -100 {
                                        badSwipeDeleted = true
                                    }
                                    badSwipeOffset = 0
                                }
                        )
                }
                DisclosureGroup("Details") {
                    Text("The bad gestures example uses `.gesture(DragGesture())` with no `.accessibilityAction` alternative and no visible single-tap button, failing the `gesture-missing-alternative` rule. VoiceOver and Switch Control users cannot perform a swipe gesture, and touch users who cannot drag have no visible single-pointer alternative to trigger the delete action. WCAG 2.5.1 requires single-pointer alternatives for path-based gestures.")
                }.padding(.bottom).accessibilityHint("Bad Example Gestures")
                // MARK: Bad Reading Order / Grouping
                Text("Bad Example Reading Order / Grouping")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Image(systemName: "person.fill")
                        .accessibilityLabel("Person")
                    Text("Jane Doe")
                }
                DisclosureGroup("Details") {
                    Text("The bad grouping example has an `HStack` containing an `Image` and `Text` without `.accessibilityElement(children: .combine)`, failing the `missing-accessibility-grouping` rule. VoiceOver reads the image and text as separate elements instead of a single combined element. The `zstack-order-confusing` rule flags `ZStack` views with multiple interactive elements that lack `accessibilitySortPriority` to control VoiceOver reading order.")
                }.padding(.bottom).accessibilityHint("Bad Example Reading Order / Grouping")
                // MARK: Bad Sort Priority
                Text("Bad Example Sort Priority")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    Text("First item")
                        .accessibilitySortPriority(2)
                    Text("Second item")
                        .accessibilitySortPriority(1)
                }
                DisclosureGroup("Details") {
                    Text("The bad sort priority example uses `.accessibilitySortPriority()` on a `VStack` where VoiceOver's default top-to-bottom order already matches the visual layout, failing the `sort-priority-overused` rule. Sort priority should only be used when the visual layout doesn't match the logical reading order, such as ZStack overlays. Prefer restructuring the view hierarchy or using `.accessibilityElement(children: .combine)` instead.")
                }.padding(.bottom).accessibilityHint("Bad Example Sort Priority")
                // MARK: Bad Timing
                Text("Bad Example Timing")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("The `auto-dismiss-no-control` rule flags views that auto-dismiss using `Task.sleep` or `asyncAfter` inside `.task` or `.onAppear` closures without giving the user control to extend or stop the timer. Toast messages and auto-closing alerts should let users pause or dismiss them manually.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The `auto-dismiss-no-control` rule maps to WCAG 2.2.1 Timing Adjustable. Content that auto-disappears can be missed by users who need more time to read, including screen reader users and people with cognitive disabilities.")
                }.padding(.bottom).accessibilityHint("Bad Example Timing")
                // MARK: Bad Label in Name
                Text("Bad Example Label in Name")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Save Changes") {}
                    .accessibilityLabel("Submit form data")
                DisclosureGroup("Details") {
                    Text("The bad label in name example has visible text \"Save Changes\" but the `.accessibilityLabel` is \"Submit form data\" which does not contain the visible text, failing the `label-in-name` rule. Speech input users who say \"tap Save Changes\" will not be able to activate this button because VoiceOver uses a different name.")
                }.accessibilityHint("Bad Example Label in Name")
            }
            .padding()
            .navigationTitle("A11y-check")
        }
    }
}

#Preview {
    NavigationStack {
        A11yCheckView()
    }
}
