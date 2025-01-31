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
 
struct TextFieldsView: View {
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
    @State private var bmonth = ""
    @State private var bday = ""
    @State private var byear = ""
    @State private var birthday = ""


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Text fields require visible label text next to the field and the label text must be set as the `.accessibilityLabel` of the `TextField`. Or provide visible labels using `LabeledContent` and then an `.accessibilityLabel` is not required. Don't use `.labeledContentStyle(.vertical)` or else VoiceOver won't be able to double tap to activate the `TextField`. Don't use placeholder text which has insufficient contrast and disappears. Use `.textFieldStyle(.roundedBorder)` to make the `TextField` visually identifiable. Use `.border(.secondary)` to give the border a 3:1 contrast ratio in light and dark mode. Use `.keyboardType` to specify the keyboard displayed on input. Use `.textContentType` to enable form AutoFill for each `TextField`.")
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
                Text("Good Example Using `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("First Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $fname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("First Name")
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .accessibilityIdentifier("fNameGood")
                Text("Last Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $lname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Last Name")
                    .autocorrectionDisabled(true)
                    .textContentType(.familyName)
                    .accessibilityIdentifier("lNameGood")
                Text("Username")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $username, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Username")
                    .textContentType(.username)
                    .accessibilityIdentifier("usernameGood")
                Text("Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                SecureField("", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Password")
                    .textContentType(.password)
                    .accessibilityIdentifier("passwordGood")
                Text("Email")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $email, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Email")
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .accessibilityIdentifier("emailGood")
                Text("Street Address")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $address, axis: .vertical)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Street Address")
                    .textContentType(.streetAddressLine1)
                    .accessibilityIdentifier("streetGood")
                Text("Street Address Line 2")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $address2, axis: .vertical)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Street Address Line 2")
                    .textContentType(.streetAddressLine2)
                    .accessibilityIdentifier("street2Good")
                Text("City")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $city, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("City")
                    .textContentType(.addressCity)
                    .accessibilityIdentifier("cityGood")
                Text("State")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $state, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("State")
                    .textContentType(.addressState)
                    .accessibilityIdentifier("stateGood")
                Text("Phone Number")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $phone, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Phone Number")
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .accessibilityIdentifier("phoneGood")
                Text("Website")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $website, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Website")
                    .keyboardType(.URL)
                    .accessibilityIdentifier("websiteGood")
                Text("Birth Date")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $birthday, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Birth Date")
                    .autocorrectionDisabled(true)
                    .textContentType(.birthdate)
                    .keyboardType(.numbersAndPunctuation)
                Text("Birth Date Day")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $bday, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Birth Date Day")
                    .autocorrectionDisabled(true)
                    .textContentType(.birthdateDay)
                    .keyboardType(.numberPad)
                Text("Birth Date Month")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $bmonth, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Birth Date Month")
                    .autocorrectionDisabled(true)
                    .textContentType(.birthdateMonth)
                    .keyboardType(.numberPad)
                Text("Birth Date Year")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $byear, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Birth Date Year")
                    .autocorrectionDisabled(true)
                    .textContentType(.birthdateYear)
                    .keyboardType(.numberPad)
                DisclosureGroup("Details") {
                    Text("The first good Text Fields example uses visible label text that is set as the `.accessibilityLabel` for each `TextField`. `.border(.secondary)` is used to give the border a 3:1 contrast ratio. `.keyboardType` is used to provide the most usable keyboard for each type of input. `.textContentType` is used to enable AutoFill for each `TextField` and automatic password management.")
                }.padding(.bottom).accessibilityHint("Good Example Using `.accessibilityLabel`")
                Text("Good Example Using `LabeledContent`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                LabeledContent("First Name") {
                      TextField("", text:$fname)
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .autocorrectionDisabled(true)
                        .textContentType(.givenName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                LabeledContent("Last Name") {
                      TextField("", text:$lname)
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .autocorrectionDisabled(true)
                        .textContentType(.familyName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The second good Text Fields example uses `LabeledContent` to provide visible label text that also becomes the accessible name of each `TextField`. When using `LabeledContent` an `.accessibilityLabel` is not required. Don't stack the labels vertically or else VoiceOver TextField activation will be blocked to due to an Apple bug.")
                }.padding(.bottom).accessibilityHint("Good Example Using `LabeledContent`")
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
                Text("Bad Example Using placeholders with no label text or `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                TextField("First Name", text: $fname)
                    .textFieldStyle(.roundedBorder)
                TextField("Last Name", text: $lname)
                    .textFieldStyle(.roundedBorder)
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                TextField("Street Address", text: $address)
                    .textFieldStyle(.roundedBorder)
                TextField("", text: $address2)
                    .textFieldStyle(.roundedBorder)
                TextField("City", text: $city)
                    .textFieldStyle(.roundedBorder)
                TextField("State", text: $state)
                    .textFieldStyle(.roundedBorder)
                TextField("Phone Number", text: $phone)
                    .textFieldStyle(.roundedBorder)
                TextField("Website", text: $website)
                    .textFieldStyle(.roundedBorder)
                DisclosureGroup("Details") {
                    Text("The bad Text Fields example uses placeholder text which disappears and has insufficient contrast rather than visible label text. There is no `.accessibilityLabel` for each `TextField`. The default border style has an insufficient contrast ratio. Keyboard types are not specified. AutoFill and password management are not enabled.")
                }.padding(.bottom).accessibilityHint("Bad Example Using placeholders with no label text or `.accessibilityLabel`")
                Text("Bad Example Using `LabeledContent`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                LabeledContent("First Name") {
                      TextField("", text:$fname)
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .autocorrectionDisabled(true)
                        .textContentType(.givenName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.labeledContentStyle(.vertical) // this plus the struct and extension at the bottom enable vertical stacking of the label and textfield
                LabeledContent("Last Name") {
                      TextField("", text:$lname)
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .autocorrectionDisabled(true)
                        .textContentType(.familyName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.labeledContentStyle(.vertical)
                DisclosureGroup("Details") {
                    Text("The second bad Text Fields example uses `LabeledContent` to provide visible label text that also becomes the accessible name of each `TextField`. When using `.labeledContentStyle(.vertical)` VoiceOver operation is blocked because VoiceOver users cannot double tap to activate the TextField and enter a value. When using `LabeledContent` an `.accessibilityLabel` is not required.")
                }.accessibilityHint("Bad Example Using `LabeledContent`")
            }
            .navigationTitle("Text Fields")
            .padding()
            .gesture(TapGesture().onEnded(){_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)}) //dismiss keyboard on tap
        }
 
    }
}
 
struct TextFieldsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TextFieldsView()
        }
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
