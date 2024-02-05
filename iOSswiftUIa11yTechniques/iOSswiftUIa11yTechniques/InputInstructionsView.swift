/*
   Copyright 2023-2024 CVS Health and/or one of its affiliates

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

struct InputInstructionsView: View {
    @State private var username = ""
    @State private var password = ""
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Input instructions are used to convey required information or value format requirements for an input. VoiceOver users need to hear the input instruction text when focused on the input. Use an `.accessibilityHint` matching the visible instruction text for each input.")
                    .padding([.bottom])
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Username")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $username, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Username")
                    .accessibilityHint("4 to 10 characters, no spaces.")
                    .autocorrectionDisabled(true)
                    .textContentType(.username)
                    .accessibilityIdentifier("usernameGood")
                Text("4 to 10 characters, no spaces.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .font(.caption)
                Text("Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                TextField("", text: $password, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Password")
                    .accessibilityHint("8 character minimum, at least one uppercase, one number, and one special character, no spaces.")
                    .autocorrectionDisabled(true)
                    .textContentType(.password)
                    .accessibilityIdentifier("passwordGood")
                Text("8 character minimum, at least one uppercase, one number, and one special character, no spaces.")
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    // Handle button action
                }) {
                Text("Create Account")
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .font(.title3)
                    .fontWeight(.bold)
                    .opacity(0.8)
                }.padding(.top).frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good input instructions example uses an `.accessibilityHint` on each `TextField` matching the visible instruction text so that VoiceOver users hear the input requirements when focused on the inputs.")
                }.padding()
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Username")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $username, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Username")
                    .autocorrectionDisabled(true)
                    .textContentType(.username)
                    .accessibilityIdentifier("usernameBad")
                Text("4 to 10 characters, no spaces.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .font(.caption)
                Text("Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                TextField("", text: $password, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Password")
                    .autocorrectionDisabled(true)
                    .textContentType(.password)
                    .accessibilityIdentifier("passwordBad")
                Text("8 character minimum, at least one uppercase, one number, and one special character, no spaces.")
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    // Handle button action
                }) {
                Text("Create Account")
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .font(.title3)
                    .fontWeight(.bold)
                    .opacity(0.8)
                }.padding(.top).frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad input instructions example does not use an `.accessibilityHint` on each `TextField` matching the visible instruction text. VoiceOver users don't hear the input requirements when focused on the inputs.")
                }.padding()
            }
            .padding()
            .navigationTitle("Input Instructions")
        }
 
    }
}
 
struct InputInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InputInstructionsView()
    }
}
