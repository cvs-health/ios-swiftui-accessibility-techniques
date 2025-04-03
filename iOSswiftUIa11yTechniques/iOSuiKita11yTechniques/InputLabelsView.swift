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
 
struct InputLabelsView: View {
    @AccessibilityFocusState private var isEmailHelpFocused: Bool
    @AccessibilityFocusState private var isUsernameHelpFocused: Bool
    
    @State private var showingAlertUsername = false
    @State private var showingAlertEmail = false

    @State private var username: String = ""
    @State private var email: String = ""
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Accessibility Input Labels can provide multiple alternative voice input labels for Voice Control users to speak when tapping a control via voice commands. Use `.accessibilityInputLabels` to provide multiple voice input labels in descending order of importance. The first input label provided will be displayed to Voice Control users with the \"Show Names\" command. Use the Voice Control \"Show Names\" and \"Tap\" commands to test this technique.")
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
                HStack {
                    Text("Username")
                        .frame(minWidth: 80, alignment:.leading)
                    TextField("", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Username")
                    Button(action: {
                        // Handle button action
                        showingAlertUsername = true
                    }) {
                        Label("Help for Username", systemImage: "questionmark.app").labelStyle(IconOnlyLabelStyle())
                    }
                    .accessibilityFocused($isUsernameHelpFocused)
                        .accessibilityInputLabels(["Username Help", "Username icon", "Help for Username"])
                        .alert("Username Help Tapped", isPresented: $showingAlertUsername) {
                            Button("OK", role: .cancel) {
                                isUsernameHelpFocused = true
                            }
                        } message: {
                            Text("You tapped the ? help icon for username!")
                        }
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
                        showingAlertEmail = true
                    }) {
                        Label("Help for Email", systemImage: "questionmark.app").labelStyle(IconOnlyLabelStyle())
                    }
                    .accessibilityFocused($isEmailHelpFocused)
                        .accessibilityInputLabels(["Email Help", "Email icon", "Help for Email"])
                        .alert("Email Help Tapped", isPresented: $showingAlertEmail) {
                            Button("OK", role: .cancel) {
                                isEmailHelpFocused = true
                            }
                        } message: {
                            Text("You tapped the ? help icon for email!")
                        }
                }
                DisclosureGroup("Details") {
                    Text("The good accessibility input labels example uses `.accessibilityInputLabels([\"Username Help\", \"Username icon\", \"Help for Username\"])` and `.accessibilityInputLabels([\"Email Help\", \"Email icon\", \"Help for Email\"])`to give each help icon button multiple voice command input labels enabling Voice Control users to speak a variety of possible voice commands to tap the icon buttons.")
                }.padding(.bottom)
            }
            .padding()
            .navigationTitle("Accessibility Input Labels")

        }
 
    }
}
 
struct InputLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InputLabelsView()
        }
    }
}
