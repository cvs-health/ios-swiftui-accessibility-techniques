/*
   Copyright 2024-2026 CVS Health and/or one of its affiliates

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
 
struct AccessibilityHidden: View {
    @State private var searchText = ""
    @State private var emailGood = ""
    @State private var emailBad = ""

    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityHidden(true)` to hide decorative content or repetitive text from VoiceOver, Voice Control, Full Keyboard Access, and Switch Control users. Don't use `.accessibilityHidden(true)` on any informative content or UI controls. Don't use `.accessibilityHidden(true)` on any parent view containers that hold informative or functional content because all child elements will be hidden. Don't use `.accessibilityHidden(true)` on visible label text to avoid hearing a label twice, because that removes the label from the screen entirely for assistive technology users.")
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.top)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Decorative Badge Numbers Hidden")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HeaderContainer(searchText: $searchText)
                DisclosureGroup("Details") {
                    Text("The good example uses a custom `HeaderContainer` view that holds a search input, notifications button, and shopping cart button. `.accessibilityHidden(true)` is used on the icon button's badge numbers to prevent VoiceOver from speaking repetitive text.")
                }.padding(.bottom).accessibilityHint("Good Example Decorative Badge Numbers Hidden")
                Text("Good Example Visible Label Text Not Hidden")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    Text("Email address")
                    TextField("", text: $emailGood)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Email address")
                }
                DisclosureGroup("Details") {
                    Text("The good label example leaves the visible `Text(\"Email address\")` label in the accessibility tree and also gives the `TextField` the same accessible name. VoiceOver users hear the label when swiping to the text and again as the name of the input, which is the same behavior a correctly associated `<label>` and `<input>` give on the web. Voice Control users can speak the label to reach the field, and braille users reading the screen line by line still find it.")
                }.padding(.bottom).accessibilityHint("Good Example Visible Label Text Not Hidden")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.top)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Parent Container Hidden")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HeaderContainer(searchText: $searchText)
                    .accessibilityHidden(true)
                DisclosureGroup("Details") {
                    Text("The bad container example uses a custom `HeaderContainer` view that holds a search input, notifications button, and shopping cart button. `.accessibilityHidden(true)` is incorrectly used to hide the contents of the custom view. VoiceOver, Voice Control, Full Keyboard Access, and Switch Control users cannot focus on or activate any of the controls inside the custom view with `.accessibilityHidden(true)` applied.")
                }.padding(.bottom).accessibilityHint("Bad Example Parent Container Hidden")
                Text("Bad Example Visible Label Text Hidden")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    Text("Email address")
                        .accessibilityHidden(true)
                    TextField("", text: $emailBad)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Email address")
                }
                DisclosureGroup("Details") {
                    Text("The bad label example uses `.accessibilityHidden(true)` on the visible `Text(\"Email address\")` label so that VoiceOver speaks it only once. Hearing a label twice is not a failure, but hiding it is: the label is visible on screen and is now missing from the accessibility tree, which fails WCAG 1.3.1 Info and Relationships. Swiping through the form skips over it, so there is no way to review the label without focusing the input, and nothing is left if the input's `.accessibilityLabel` is later changed or removed. Hide text only when it is decorative or repeats something already announced.")
                }.padding(.bottom).accessibilityHint("Bad Example Visible Label Text Hidden")
            }
            .navigationTitle("Accessibility Hidden")
            .padding()
        }
 
    }
}
 
#Preview {
    NavigationStack {
        AccessibilityHidden()
    }
}


struct HeaderContainer: View {
    
    @Binding var searchText: String
    @Environment(\.colorScheme) var colorScheme
    var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)

    var body: some View {
        HStack {
            Text("Search")
            TextField("", text: $searchText)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .accessibilityLabel("Search")
            Spacer()
            Button(action: {
            }) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 24))
            }
            .accessibilityLabel("3 Notifications")
            .overlay(
                Text("3")
                    .accessibilityHidden(true)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10),
                alignment: .topTrailing
            )
            Button(action: {
            }) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 24))
            }
            .accessibilityLabel("1 item in cart")
            .overlay(
                Text("1")
                    .accessibilityHidden(true)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(5)
                    .background(colorScheme == .dark ? .white : .black)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10),
                alignment: .topTrailing
            )

        }
        .padding(.horizontal)
    }
}
