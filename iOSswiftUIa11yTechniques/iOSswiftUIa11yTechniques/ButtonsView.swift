/*
   Copyright 2023 CVS Health and/or one of its affiliates

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
 
struct ButtonsView: View {
    @State private var username: String = "jdoe24"
    @State private var email: String = "jdoe24@gmail.com"
    @State private var username2: String = ""
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Buttons must have meaningful label text or `.accessibilityLabel`. Button states must be conveyed to VoiceOver users. Use a unique and specific `.accessibilityLabel` if the visible button label text does not describe its specific function. Use `.disabled(true)` to set the disabled state of a button.")
                    .padding([.bottom])
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom) 
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Username")
                        .frame(minWidth: 80, alignment:.leading)
                    TextField("", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Username")
                    Button(action: {
                        // Handle button action
                    }) {
                        Text("Edit")
                    }.accessibilityLabel("Edit Username")
                        .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                        .accessibilityIdentifier("edit1good")
                }
                HStack {
                    Text("Email")
                        .frame(minWidth: 80, alignment:.leading)
                    TextField("", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Email")
                        .font(.body)
                    Button(action: {
                        // Handle button action
                    }) {
                        Text("Edit")
                    }.accessibilityLabel("Edit Email")
                        .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                        .accessibilityIdentifier("edit2good")
                }
                DisclosureGroup("Details") {
                    Text("The good button example uses `.accessibilityLabel(\"Edit Username\")` and `.accessibilityLabel(\"Edit Email\")` to give each Edit button a unique and specific accessibility label for VoiceOver users.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Username")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $username2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Username")
                Text("Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $username2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Password")
                Button(action: {
                    // Handle button action
                }) {
                    Text("Log In")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .disabled(true) // disabled state causes false positive with performAccessibilityAudit
                        .accessibilityIdentifier("loginGood")
                }
                DisclosureGroup("Details") {
                    Text("The good Log In button example uses `.disabled(true)` to set the disabled state of the button.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Username")
                        .frame(minWidth: 80, alignment:.leading)
                    TextField("", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        // Handle button action
                    }) {
                        Text("Edit")
                    }.tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                        .accessibilityIdentifier("edit1bad")
                }
                HStack {
                    Text("Email")
                        .frame(minWidth: 80, alignment:.leading)
                    TextField("", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        // Handle button action
                    }) {
                        Text("Edit")
                    }.tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                        .accessibilityLabel("Edit Button")
                        .accessibilityIdentifier("edit2bad")
                }
                DisclosureGroup("Details") {
                    Text("The bad button example uses the same label text \"Edit\" for both buttons without providing a unique and specific `.accessibilityLabel` for VoiceOver users.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Username")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $username2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Username")
                Text("Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $username2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Password")
                Button(action: {
                    // Handle button action
                }) {
                    Text("Log In")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .tint(.gray)
                        .accessibilityIdentifier("loginBad")
                }
                DisclosureGroup("Details") {
                    Text("The bad Log In button example uses `.tint(.gray)` to visually convey that the button is disabled but VoiceOver will not speak a disabled state.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .padding()
            .navigationTitle("Buttons")

        }
 
    }
}
 
struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
