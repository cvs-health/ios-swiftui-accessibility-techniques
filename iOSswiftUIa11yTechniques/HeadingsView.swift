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
    private var darkOrange = Color(red: 203 / 255, green: 77 / 255, blue: 0 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Headings are used to title sections of content. The header trait must be applied to heading text to enable VoiceOver users to quickly navigate to headings. Use `.accessibilityAddTraits(.isHeader)` to set text as a heading for VoiceOver users. Additionally if you want to provide a level for the heading use `.accessibilityHeading(.h1)` or `(.h2-h6)` with the `.accessibilityAddTraits(.isHeader)`. When using heading levels make sure the headings do not skip a level, e.g., don't skip from a Heading Level 1 to a Heading Level 3.")
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
                Text("Good Example `.isHeader` Trait")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("goodHeading")
                VStack(alignment: .leading) {
                    Text("Monday to Friday 8AM to 9PM")
                    Text("Saturday 9AM to 10PM")
                    Text("Sunday 10AM to 6PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The first good example Store Hours heading uses `.accessibilityAddTraits(.isHeader)` which allows VoiceOver users to quickly navigate to the heading using the Rotor.")
                    }
                }.padding(.bottom).accessibilityHint("Good Example .isHeader Trait")
                Text("Good Example `.isHeader` Trait and `.accessibilityHeading`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)//.accessibilityHeading only works with VoiceOver if the .isHeader trait is also applied!
                    .accessibilityIdentifier("goodHeading2")
                VStack(alignment: .leading) {
                    Text("Monday to Friday 8AM to 9PM")
                    Text("Saturday 9AM to 10PM")
                    Text("Sunday 10AM to 6PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The second good example Store Hours heading uses `.accessibilityAddTraits(.isHeader)` and `.accessibilityHeading(.h2)` which allows VoiceOver users to quickly navigate to the heading using the Rotor and hear the heading level.")
                    }
                }.padding(.bottom).accessibilityHint("Good Example .isHeader Trait and .accessibilityHeading")
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
                Text("Bad Example No Heading Trait")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("badHeading1")
                VStack(alignment: .leading) {
                    Text("Monday to Friday 8AM to 9PM")
                    Text("Saturday 9AM to 10PM")
                    Text("Sunday 10AM to 6PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The first bad example Store Hours heading does not use `.accessibilityAddTraits(.isHeader)` which prevents VoiceOver users from being able to quickly navigate to the heading using the Rotor.")
                    }
                }.padding(.bottom).accessibilityHint("Bad Example No Heading Trait")
                Text("Bad Example Fake \"Heading\" in `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Store Hours heading")
                    .accessibilityIdentifier("badHeading2")
                VStack(alignment: .leading) {
                                    Text("Monday to Friday 8AM to 9PM")
                                    Text("Saturday 9AM to 10PM")
                                    Text("Sunday 10AM to 6PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The second bad example Store Hours heading uses `.accessibilityLabel(\"Store Hours heading\")` which incorrectly modifies the accessible name of the text by adding \" heading\" and does not allow VoiceOver users to quickly navigate to the heading using the Rotor.")
                    }
                }.padding(.bottom).accessibilityHint("Bad Example Fake \"Heading\" in .accessibilityLabel")
                Text("Platform Defect Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.orange) : darkOrange)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.orange) : darkOrange)
                    .padding(.bottom)
                Text("Platform Defect Example `.accessibilityHeading(.unspecified)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHeading(.unspecified)
                VStack(alignment: .leading) {
                    Text("Monday to Friday 8AM to 9PM")
                    Text("Saturday 9AM to 10PM")
                    Text("Sunday 10AM to 6PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The platform defect example Store Hours heading uses `.accessibilityHeading(.unspecified)` which should create a heading without a level for VoiceOver users, however, the code does not work and it does not become a heading for VoiceOver users.")
                    }
                }.padding(.bottom).accessibilityHint("Platform Defect Example `.accessibilityHeading(.unspecified)`")
                Text("Platform Defect Example `.accessibilityHeading(.h2)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHeading(.h2)
                VStack(alignment: .leading) {
                    Text("Monday to Friday 8AM to 9PM")
                    Text("Saturday 9AM to 10PM")
                    Text("Sunday 10AM to 6PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The platform defect example Store Hours heading uses `.accessibilityHeading(.h2)` which should create a heading with a level 2 for VoiceOver users, however, the code does not work and it does not become a heading for VoiceOver users. Heading level code will only work if `.accessibilityAddTraits(.isHeader)` is included.")
                    }
                }.padding(.bottom).accessibilityHint("Platform Defect Example `.accessibilityHeading(.unspecified)`")
            }
            .padding()
            .navigationTitle("Headings")
        }
    }
}
 
struct HeadingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HeadingsView()
        }
    }
}
