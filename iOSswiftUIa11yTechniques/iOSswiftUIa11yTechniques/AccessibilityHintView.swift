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

struct AccessibilityHintView: View {
    @State private var password = ""
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityHint` to describe the result of performing an action on a control. Hints are optional and VoiceOver users can turn them off in Settings. Only provide a hint when the result of an action is not obvious from the element's label. Follow Apple's guidelines: use third-person singular verbs, do not mention gestures, and do not repeat the label or control type.")
                    .padding(.bottom)
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
                Text("Good Example Hint Describing Result")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Label("Favorite", systemImage: "heart")
                }
                .accessibilityHint("Adds this item to your favorites.")
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good hint example uses `.accessibilityHint(\"Adds this item to your favorites.\")` which describes the result of the action. It uses the third-person singular verb \"Adds\" (not the imperative \"Add\"), begins with a capital letter, and ends with a period. VoiceOver reads: \"Favorite, button. Adds this item to your favorites.\"")
                }.padding(.bottom).accessibilityHint("Good Example Hint Describing Result")
                Text("Good Example Hint for Ambiguous Action")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bohemian Rhapsody")
                        .font(.headline)
                    Text("Queen")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                .accessibilityHint("Plays the song.")
                DisclosureGroup("Details") {
                    Text("The good ambiguous action example uses `.accessibilityHint(\"Plays the song.\")` on a song list item. The label (song title and artist) does not imply what happens when the user taps it, so a hint is needed to describe the result. The hint uses third-person singular \"Plays\" and does not mention \"tap\" or \"double tap\".")
                }.padding(.bottom).accessibilityHint("Good Example Hint for Ambiguous Action")
                Text("Good Example Hint for Input Format")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("8 character minimum, at least one number.")
                    .font(.caption)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                SecureField("", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Password")
                    .accessibilityHint("Required. 8 character minimum, at least one number.")
                DisclosureGroup("Details") {
                    Text("The good input format example uses `.accessibilityHint(\"Required. 8 character minimum, at least one number.\")` to convey the input requirements that are visible on screen. VoiceOver users hear these requirements when focused on the field without needing to navigate to the instruction text separately.")
                }.padding(.bottom).accessibilityHint("Good Example Hint for Input Format")
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
                Text("Bad Example Hint Mentions Gesture")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Label("Favorite", systemImage: "heart")
                }
                .accessibilityHint("Double tap to add this item to your favorites.")
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad hint example uses `.accessibilityHint(\"Double tap to add this item to your favorites.\")` which mentions the gesture \"Double tap\". Hints should never include gesture names because VoiceOver users use VoiceOver-specific gestures. The hint should describe the result using a third-person verb like \"Adds this item to your favorites.\" not how to perform the action.")
                }.padding(.bottom).accessibilityHint("Bad Example Hint Mentions Gesture")
                Text("Bad Example Hint Repeats Label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .accessibilityLabel("Delete")
                .accessibilityHint("Delete")
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad hint example uses `.accessibilityHint(\"Delete\")` which simply repeats the label. VoiceOver reads \"Delete, button. Delete.\" which is redundant and provides no additional information. A hint should describe the result of the action, such as \"Removes this item from your cart.\"")
                }.padding(.bottom).accessibilityHint("Bad Example Hint Repeats Label")
                Text("Bad Example Hint Includes Control Type")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .accessibilityHint("Tap this button to share the current page.")
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad hint example uses `.accessibilityHint(\"Tap this button to share the current page.\")` which mentions both the gesture \"Tap\" and the control type \"button\". The user already knows it is a button from the trait. A correct hint would be \"Shares the current page.\" using a third-person verb without mentioning the gesture or control type.")
                }.padding(.bottom).accessibilityHint("Bad Example Hint Includes Control Type")
            }
            .padding()
            .navigationTitle("Accessibility Hint")
        }
    }
}

#Preview {
    NavigationStack {
        AccessibilityHintView()
    }
}
