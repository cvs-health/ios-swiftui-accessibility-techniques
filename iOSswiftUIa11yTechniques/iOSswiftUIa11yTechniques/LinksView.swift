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
    
    var attributedString: AttributedString {
        var result = AttributedString("To get started Login or Create Account. Contact Us if you need help.")
        let loginLink = result.range(of: "Login")!
        result[loginLink].link = URL(string: "https://example.com/login")
        result[loginLink].underlineStyle = Text.LineStyle(nsUnderlineStyle: .single)
        let createLink = result.range(of: "Create Account")!
        result[createLink].link = URL(string: "https://example.com/create-account")
        result[createLink].underlineStyle = Text.LineStyle(nsUnderlineStyle: .single)
        let contactLink = result.range(of: "Contact Us")!
        result[contactLink].link = URL(string: "https://example.com/contact")
        result[contactLink].underlineStyle = Text.LineStyle(nsUnderlineStyle: .single)
        return result
    }
    var attributedStringBad: AttributedString {
        var result = AttributedString("To get started Login or Create Account. Contact Us if you need help.")
        let loginLink = result.range(of: "Login")!
        result[loginLink].link = URL(string: "https://example.com/login")
        let createLink = result.range(of: "Create Account")!
        result[createLink].link = URL(string: "https://example.com/create-account")
        let contactLink = result.range(of: "Contact Us")!
        result[contactLink].link = URL(string: "https://example.com/contact")
        return result
    }

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Links are used to open a URL in the user's web browser. The \"Link\" trait indicates to VoiceOver users that it will exit the app and open in their web browser. Link text must be specific to its purpose. Link text style must be discernable without using color alone when placed inline with static text, e.g. using `.underline()`. Link text color must have 4.5:1 contrast ratio in light and dark modes. Choose an `AccentColor` with sufficient contrast for light and dark appearance in the assets catalog `Assets.xcassets` file.")
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
                    }).accessibilityRemoveTraits(.isButton)
                        .accessibilityIdentifier("goodLink1a")
                    Text("or")
                    Link(destination: URL(string: "https://www.example.com/create-account")!, label: {
                        Text("Create Account")
                            .underline()
                    }).accessibilityRemoveTraits(.isButton)
                        .accessibilityIdentifier("goodLink1b")
                }
                DisclosureGroup("Details") {
                    Text("The good link example uses unique and specific link text, `.underline()` to make links visually distinct without color. An `AccentColor` with sufficient contrast for light and dark appearance is specified in the assets catalog `Assets.xcassets` file. Additionally `.accessibilityRemoveTraits(.isButton)` is used to remove the Button trait so that VoiceOver users don't hear \"Button\" spoken.")
                }.padding()
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Link(destination: URL(string: "https://store.apple.com")!, label: {
                    Text("Shop Online")
                }).accessibilityRemoveTraits(.isButton)
                    .accessibilityIdentifier("goodLink2")
                DisclosureGroup("Details") {
                    Text("The second good link example is correctly coded as a `Link` element which speaks a \"Link\" trait to VoiceOver. The color contrast is corrected and the Button trait removed.")
                }.padding()
                Text("Good AttributedString Inline Links Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text(attributedString)
                DisclosureGroup("Details") {
                    Text("The good `AttributedString` inline links example uses `AttributedString` to set `.underlineStyle = Text.LineStyle(nsUnderlineStyle: .single)`. An `AccentColor` with sufficient contrast for light and dark appearance is specified in the assets catalog `Assets.xcassets` file. VoiceOver users must focus each link invidiually using the Rotor. ")
                }.padding()
                Text("Markdown Links Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("To get started [Log In](https://www.example.com/login) or [Create Account](https://www.example.com/create-account). [Contact Us](https://www.example.com/contact) if you need help.")
                DisclosureGroup("Details") {
                    Text("The markdown links example uses markdown format links `[Name](https://www.example.com)` where each link must be focused invidually using the VoiceOver Rotor. The markdown links have a `AccentColor` applied with sufficient contrast but they cannot be underlined or have different text style than the surrounding inline text.")
                }.padding()
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
                        .tint(.blue)
                    Text("to login, or")
                    Link(destination: URL(string: "https://www.example.com/create-account")!, label: {
                        Text("here")
                    }).accessibilityIdentifier("badLink1b")
                        .tint(.blue)
                    Text("to create account.")
                }
                DisclosureGroup("Details") {
                    Text("The bad link example uses generic link text \"Click here\" and \"here\" and the links are not underlined to be visually distinct without color. The bad link examples also use the `.tint(.blue)` color which has an insufficient contrast ratio and the default Button trait remains.")
                }.padding()
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
                    .tint(.blue)
                DisclosureGroup("Details") {
                    Text("The second bad link example is incorrectly coded as a `Button` element which speaks a \"Button\" trait to VoiceOver rather than a \"Link\" trait. The `.tint(.blue)` color link contrast is below the WCAG minimum. ")
                }.padding()
                Text("Bad AttributedString Inline Links Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text(attributedStringBad)
                DisclosureGroup("Details") {
                    Text("The bad `AttributedString` inline links example uses `AttributedString` with the default link style for each link inside the attributed string. VoiceOver users must focus each link invidiually using the Rotor.")
                }.padding()
                Text("Bad Markdown Links Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("To get started [Log In](https://www.example.com/login) or [Create Account](https://www.example.com/create-account). [Contact Us](https://www.example.com/contact) if you need help.")
                    .tint(.blue)
                DisclosureGroup("Details") {
                    Text("The bad markdown links example uses Markdown inline links with `.tint(.blue)` which have insufficient contrast and are not underlined.")
                }.padding()
            }
            .navigationTitle("Links")
            .padding()
        }
 
    }
}
 
struct LinksView_Previews: PreviewProvider {
    static var previews: some View {
        LinksView()
    }
}
