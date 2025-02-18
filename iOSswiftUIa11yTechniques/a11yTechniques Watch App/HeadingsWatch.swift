/*
   Copyright 2025 CVS Health and/or one of its affiliates

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

struct HeadingsWatch: View {
    
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    
    var body: some View {
        ScrollView {
            Text("Headings are used to title sections of content. The header trait must be applied to heading text to enable VoiceOver users to quickly navigate to headings. Use `.accessibilityAddTraits(.isHeader)` to set text as a heading for VoiceOver users. Additionally if you want to provide a level for the heading use `.accessibilityHeading(.h1)` or `(.h2-h6)` with the `.accessibilityAddTraits(.isHeader)`. When using heading levels make sure the headings do not skip a level, e.g., don't skip from a Heading Level 1 to a Heading Level 3.")
            Text("Good Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.green)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.green)
                .padding(.bottom)
            Text("`.isHeader` Trait")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
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
            NavigationLink(destination: DetailHeadingsGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("`.isHeader` Trait")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`.isHeader` Trait and `.accessibilityHeading`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
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
            NavigationLink(destination: DetailHeadingsGood2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("`.isHeader` Trait and `.accessibilityHeading`")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Bad Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.red)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.red)
                .padding(.bottom)
            Text("No Heading Trait")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
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
            NavigationLink(destination: DetailHeadingsBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No Heading Trait")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Fake \"Heading\" in `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
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
            NavigationLink(destination: DetailHeadingsBad2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Fake \"Heading\" in `.accessibilityLabel`")
                .buttonStyle(.plain)

        }
    }
}

struct DetailHeadingsGood: View {
    var body: some View {
        ScrollView {
            Text("The first good example Store Hours heading uses `.accessibilityAddTraits(.isHeader)` which allows VoiceOver users to quickly navigate to the heading using the Rotor.")
        }
            .navigationTitle("`.isHeader` Trait")
    }
}
struct DetailHeadingsGood2: View {
    var body: some View {
        ScrollView {
            Text("The second good example Store Hours heading uses `.accessibilityAddTraits(.isHeader)` and `.accessibilityHeading(.h2)` which allows VoiceOver users to quickly navigate to the heading using the Rotor and hear the heading level.")
        }
            .navigationTitle("`.isHeader` Trait and `.accessibilityHeading`")
    }
}
struct DetailHeadingsBad: View {
    var body: some View {
        ScrollView {
            Text("The first bad example Store Hours heading does not use `.accessibilityAddTraits(.isHeader)` which prevents VoiceOver users from being able to quickly navigate to the heading using the Rotor.")
        }
        .navigationTitle("No `Image(decorative:)`")
    }
}
struct DetailHeadingsBad2: View {
    var body: some View {
        ScrollView {
            Text("The second bad example Store Hours heading uses `.accessibilityLabel(\"Store Hours heading\")` which incorrectly modifies the accessible name of the text by adding \" heading\" and does not allow VoiceOver users to quickly navigate to the heading using the Rotor.")
        }
        .navigationTitle("Fake \"Heading\" in `.accessibilityLabel`")
    }
}

#Preview {
    NavigationStack {
        HeadingsWatch()
    }
}
