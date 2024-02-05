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
 
struct HeadingsView: View {
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Headings are used to title sections of content. The header trait must be applied to heading text to enable VoiceOver users to quickly navigate to headings. Use `.accessibilityAddTraits(.isHeader)` to set text as a heading for VoiceOver users. Additionally if you want to provide a level for the heading use `.accessibilityHeading(.h1)` or `(.h2-h6)` with the `.accessibilityAddTraits(.isHeader)`. When using heading levels make sure the headings do not skip a level, e.g., don't skip from a Heading Level 1 to a Heading Level 3.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("FAQ")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    //.accessibilityHeading(/*@START_MENU_TOKEN@*/.h1/*@END_MENU_TOKEN@*/)//.accessibilityHeading only works with VoiceOver if the .isHeader trait is also applied!
                    .accessibilityIdentifier("goodHeading")
                DisclosureGroup("I received a promotion, but I cannot log in to the website.") {
                    Text("In order to access your promotions online, we invite you to create an account. Just go to the Sign In page in the app and tap the banner at the bottom of the screen.")
                }
                DisclosureGroup("Details") {
                    VStack {
                        Text("The good example FAQ heading uses `.accessibilityAddTraits(.isHeader)` which allows VoiceOver users to quickly navigate to the heading using the Rotor.")
                    }
                }.padding(.bottom)
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
                    .padding([.bottom])
                Text("FAQ")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("badHeading1")
                DisclosureGroup("I received a promotion, but I cannot log in to the website.") {
                    Text("In order to access your promotions online, we invite you to create an account. Just go to the Sign In page in the app and tap the banner at the bottom of the screen.")
                }
                DisclosureGroup("Details") {
                    VStack {
                        Text("The first bad example FAQ heading does not use `.accessibilityAddTraits(.isHeader)` which prevents VoiceOver users from being able to quickly navigate to the heading using the Rotor.")
                    }
                }.padding(.bottom)
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.bottom])
                Text("FAQ")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("FAQ heading")
                    .accessibilityIdentifier("badHeading2")
                DisclosureGroup("I received a promotion, but I cannot log in to the website.") {
                    Text("In order to access your promotions online, we invite you to create an account. Just go to the Sign In page in the app and tap the banner at the bottom of the screen.")
                }
                DisclosureGroup("Details") {
                    VStack {
                        Text("The second bad example FAQ heading uses `.accessibilityLabel(\"FAQ heading\")` which incorrectly modifies the accessible name of the text by adding \" heading\" and does not allow VoiceOver users to quickly navigate to the heading using the Rotor.")
                    }
                }.padding(.bottom)
            }
            .padding()
            .navigationTitle("Headings")
        }
    }
}
 
struct HeadingsView_Previews: PreviewProvider {
    static var previews: some View {
        HeadingsView()
    }
}
