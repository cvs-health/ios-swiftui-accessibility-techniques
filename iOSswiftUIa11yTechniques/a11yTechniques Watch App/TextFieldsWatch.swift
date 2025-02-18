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

struct TextFieldsWatch: View {
    
    @State private var text = ""
    @State private var username = ""
    @State private var password = ""
    @State private var fname = ""
    @State private var lname = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var address2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var website = ""
    @State private var usernameBad = ""
    @State private var passwordBad = ""
    @State private var fnameBad = ""
    @State private var lnameBad = ""
    @State private var phoneBad = ""
    @State private var emailBad = ""
    @State private var addressBad = ""
    @State private var address2Bad = ""
    @State private var cityBad = ""
    @State private var stateBad = ""
    @State private var websiteBad = ""

    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    
    var body: some View {
        ScrollView {
            Text("Text fields require visible label text next to the field set as the `.accessibilityLabel` of the `TextField`. Or provide visible labels using `LabeledContent` and then an `.accessibilityLabel` is not required. Don't use placeholder text which has insufficient contrast and disappears. Use `.border(.secondary)` to give the border a 3:1 contrast ratio in light and dark mode. Use `.textContentType` to enable form AutoFill for each `TextField`.")
            Text("Platform Defect Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.orange)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.orange)
                .padding(.bottom)
            Text("`.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Text("First Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $fname, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("First Name")
                .autocorrectionDisabled(true)
                .textContentType(.givenName)
                .accessibilityIdentifier("fNameGood")
            Text("Last Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $lname, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("Last Name")
                .autocorrectionDisabled(true)
                .textContentType(.familyName)
                .accessibilityIdentifier("lNameGood")
            Text("Username")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $username, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("Username")
                .textContentType(.username)
                .accessibilityIdentifier("usernameGood")
            Text("Password")
                .frame(maxWidth: .infinity, alignment: .leading)
            SecureField("", text: $password)
                .border(.secondary)
                .accessibilityLabel("Password")
                .textContentType(.password)
                .accessibilityIdentifier("passwordGood")
            Text("Email")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $email, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("Email")
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .accessibilityIdentifier("emailGood")
            Text("Street Address")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $address, axis: .vertical)
                .autocorrectionDisabled(true)
                .border(.secondary)
                .accessibilityLabel("Street Address")
                .textContentType(.streetAddressLine1)
                .accessibilityIdentifier("streetGood")
            Text("Street Address Line 2")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $address2, axis: .vertical)
                .autocorrectionDisabled(true)
                .border(.secondary)
                .accessibilityLabel("Street Address Line 2")
                .textContentType(.streetAddressLine2)
                .accessibilityIdentifier("street2Good")
            Text("City")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $city, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("City")
                .textContentType(.addressCity)
                .accessibilityIdentifier("cityGood")
            Text("State")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $state, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("State")
                .textContentType(.addressState)
                .accessibilityIdentifier("stateGood")
            Text("Phone Number")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $phone, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("Phone Number")
                .textContentType(.telephoneNumber)
                .accessibilityIdentifier("phoneGood")
            Text("Website")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $website, axis: .vertical)
                .border(.secondary)
                .accessibilityLabel("Website")
                .accessibilityIdentifier("websiteGood")
            NavigationLink(destination: DetailGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("`.accessibilityLabel`")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`LabeledContent`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            LabeledContent("First Name") {
                  TextField("", text:$fname)
                    .border(.secondary)
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            LabeledContent("Last Name") {
                  TextField("", text:$lname)
                    .border(.secondary)
                    .autocorrectionDisabled(true)
                    .textContentType(.familyName)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            NavigationLink(destination: DetailGood2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("`LabeledContent`")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`LabeledContent .vertical`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            LabeledContent("First Name") {
                  TextField("", text:$fname)
                    .border(.secondary)
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.labeledContentStyle(.vertical) // this plus the struct and extension at the bottom enable vertical stacking of the label and textfield
            LabeledContent("Last Name") {
                  TextField("", text:$lname)
                    .border(.secondary)
                    .autocorrectionDisabled(true)
                    .textContentType(.familyName)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.labeledContentStyle(.vertical)
            NavigationLink(destination: DetailBad2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("LabeledContent .vertical`")
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
            Text("No `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            TextField("First Name", text: $fnameBad)
            TextField("Last Name", text: $lnameBad)
            TextField("Username", text: $usernameBad)
            SecureField("Password", text: $passwordBad)
            TextField("Email", text: $emailBad)
            TextField("Street Address", text: $addressBad)
            TextField("", text: $address2Bad)
            TextField("City", text: $cityBad)
            TextField("State", text: $stateBad)
            TextField("Phone Number", text: $phoneBad)
                .accessibilityIdentifier("phoneBad")
            TextField("Website", text: $website)
            NavigationLink(destination: DetailBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No `.accessibilityLabel`")
                .buttonStyle(.plain)
                .padding(.bottom)

        }
    }
}

struct DetailGood: View {
    var body: some View {
        ScrollView {
            Text("The first platform defect Text Fields example uses visible label text that is set as the `.accessibilityLabel` for each `TextField`. `.border(.secondary)` is used to give the border a 3:1 contrast ratio. `.textContentType` is used to enable AutoFill for each `TextField` and automatic password management. VoiceOver does not read the `.accessibilityLabel` as expected.")
        }
            .navigationTitle("`.accessibilityLabel`")
    }
}
struct DetailGood2: View {
    var body: some View {
        ScrollView {
            Text("The second platform defect Text Fields example uses `LabeledContent` to provide visible label text that also becomes the accessible name of each `TextField`. When using `LabeledContent` an `.accessibilityLabel` is not required.  VoiceOver does not read the `LabeledContent` as expected. VoiceOver cannot focus on the label text.")
        }
            .navigationTitle("`LabeledContent`")
    }
}
struct DetailBad: View {
    var body: some View {
        ScrollView {
            Text("The bad Text Fields example uses placeholder text which disappears and has insufficient contrast rather than visible label text. There is no `.accessibilityLabel` for each `TextField`. The default border style has an insufficient contrast ratio. AutoFill and password management are not enabled.")
        }
        .navigationTitle("No `.accessibilityLabel`")
    }
}
struct DetailBad2: View {
    var body: some View {
        ScrollView {
            Text("The last platform defect Text Fields example uses `LabeledContent` to provide visible label text that also becomes the accessible name of each `TextField`. When using `LabeledContent` an `.accessibilityLabel` is not required.  VoiceOver does not read the `LabeledContent` as expected. VoiceOver cannot focus on the label text.")
        }
        .navigationTitle("`LabeledContent .vertical`")
    }
}

#Preview {
    NavigationStack {
        TextFieldsWatch()
    }
}

struct VerticalLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
    }
}

extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    static var vertical: VerticalLabeledContentStyle { .init() }
}
