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

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Text fields require visible label text next to the field and the label text must be set as the `.accessibilityLabel` of the `TextField`. Don't use placeholder text which has insufficient contrast and disappears. Use `.textFieldStyle(.roundedBorder)` to make the `TextField` visually identifiable. Use `.border(.secondary)` to give the border a 3:1 contrast ratio in light and dark mode. Use `.keyboardType` to specify the keyboard displayed on input. Use `.textContentType` to enable form AutoFill for each `TextField`.")
                    .padding(.bottom)
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
//                LabeledContent("First Name") {
//                      TextField("", text:$fname)
//                        .textFieldStyle(.roundedBorder)
//                        .border(.secondary)
//                        .autocorrectionDisabled(true)
//                        .textContentType(.givenName)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }.labeledContentStyle(.vertical) // this plus the struct and extension at the bottom enable vertical stacking of the label and textfield
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
                    .accessibilityIdentifier("phoneGood")
                Text("Website")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $website, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Website")
                    .keyboardType(.URL)
                    .accessibilityIdentifier("websiteGood")
                DisclosureGroup("Details") {
                    Text("The good Text fields example uses visible label text that is set as the `.accessibilityLabel` for each `TextField`. `.border(.secondary)` is used to give the border a 3:1 contrast ratio. `.keyboardType` is used to provide the most usable keyboard for each type of input. `.textContentType` is used to enable AutoFill for each `TextField` and automatic password management.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                    Text("The bad Text fields example uses placeholder text which disappears and has insufficient contrast rather than visible label text. There is no `.accessibilityLabel` for each `TextField`. The default border style has an insufficient contrast ratio. Keyboard types are not specified. AutoFill and password management are not enabled.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationBarTitle("Text Fields")
            .padding()
            .gesture(TapGesture().onEnded(){_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)}) //dismiss keyboard on tap
        }
 
    }
}
 
struct TextFieldsView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldsView()
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
