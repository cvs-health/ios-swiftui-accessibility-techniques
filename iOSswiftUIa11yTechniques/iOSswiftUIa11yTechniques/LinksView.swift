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
 
struct LinksView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Links are used to open a URL in the user's web browser. The \"Link\" trait indicates to VoiceOver users that it will exit the app and open in their web browser. Link text must be specific to its purpose. Link text style must be discernable without using color alone when placed inline with static text, e.g. using `.underline()`. Link text color must have 4.5:1 contrast ratio in light and dark modes.")
                    .padding(.bottom)
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
                    Text("To get started")
                    Link(destination: URL(string: "https://www.example.com/login")!, label: {
                        Text("Log In")
                            .underline()
                            .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                    }).accessibilityRemoveTraits(.isButton)
                        .accessibilityIdentifier("goodLink1a")
                    Text("or")
                    Link(destination: URL(string: "https://www.example.com/create-account")!, label: {
                        Text("Create Account")
                            .underline()
                            .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                    }).accessibilityRemoveTraits(.isButton)
                        .accessibilityIdentifier("goodLink1b")
                }
                DisclosureGroup("Details") {
                    Text("The good link example uses unique and specific link text, `.underline()` to make links visually distinct without color, and `.tint(Color(colorScheme == .dark ? .systemBlue : .blue))` to fix the default link text color contrast. Additionally `.accessibilityRemoveTraits(.isButton)` is used to remove the Button trait so that VoiceOver users don't hear \"Button\" spoken.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Link(destination: URL(string: "https://store.apple.com")!, label: {
                    Text("Shop Online")
                }).tint(Color(colorScheme == .dark ? .systemBlue : .blue)).accessibilityRemoveTraits(.isButton)
                    .accessibilityIdentifier("goodLink2")
                DisclosureGroup("Details") {
                    Text("The second good link example is correctly coded as a `Link` element which speaks a \"Link\" trait to VoiceOver. The color contrast is corrected and the Button trait removed.")
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
                    Link(destination: URL(string: "https://www.example.com/login")!, label: {
                        Text("Click here")
                    }).accessibilityIdentifier("badLink1a")
                    Text("to login, or")
                    Link(destination: URL(string: "https://www.example.com/create-account")!, label: {
                        Text("here")
                    }).accessibilityIdentifier("badLink1b")
                    Text("to create account.")
                }
                DisclosureGroup("Details") {
                    Text("The bad link example uses generic link text \"Click here\" and \"here\" and the links are not underlined to be visually distinct without color. The bad link examples also use the default color which has an insufficient contrast ratio and the default Button trait remains.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                            if let url = URL(string: "https://store.apple.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Shop Online")
                        }.accessibilityIdentifier("badLink2")
                DisclosureGroup("Details") {
                    Text("The second bad link example is incorrectly coded as a `Button` element which speaks a \"Button\" trait to VoiceOver rather than a \"Link\" trait. The default link contrast is below the WCAG minimum. ")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationBarTitle("Links")
            .padding()
        }
 
    }
}
 
struct LinksView_Previews: PreviewProvider {
    static var previews: some View {
        LinksView()
    }
}
