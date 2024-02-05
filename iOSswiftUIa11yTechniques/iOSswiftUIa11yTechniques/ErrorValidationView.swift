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

struct ErrorValidationView: View {
    @State private var text = ""
    @State private var fname = ""
    @State private var lname = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var firstNameErrorVisible = false
    @AccessibilityFocusState private var isFirstNameA11yFocused: Bool
    @FocusState private var isFirstNameFocused: Bool
    @State private var fnameLabel = "First Name *"
    @State private var fnameError = "⚠ First Name is required. Please enter your first name."
    @State private var lnameLabel = "Last Name *"
    @State private var lnameError = "⚠ Last Name is required. Please enter your last name."
    @State private var lastNameErrorVisible = false
    @AccessibilityFocusState private var isLastNameA11yFocused: Bool
    @FocusState private var isLastNameFocused: Bool
    @State private var emailLabel = "Email *"
    @State private var emailError = "⚠ Email is required. Please enter your email address."
    @State private var emailErrorVisible = false
    @AccessibilityFocusState private var isEmailA11yFocused: Bool
    @FocusState private var isEmailFocused: Bool

    @State private var fname2 = ""
    @State private var lname2 = ""
    @State private var phone2 = ""
    @State private var email2 = ""
    @State private var firstNameErrorVisible2 = false
    @AccessibilityFocusState private var isFirstNameA11yFocused2: Bool
    @FocusState private var isFirstNameFocused2: Bool
    @State private var fnameLabel2 = "First Name *"
    @State private var fnameError2 = "⚠ First Name is required. Please enter your first name."
    @State private var lnameLabel2 = "Last Name *"
    @State private var lnameError2 = "⚠ Last Name is required. Please enter your last name."
    @State private var lastNameErrorVisible2 = false
    @AccessibilityFocusState private var isLastNameA11yFocused2: Bool
    @FocusState private var isLastNameFocused2: Bool
    @State private var emailLabel2 = "Email *"
    @State private var emailError2 = "⚠ Email is required. Please enter your email address."
    @State private var emailErrorVisible2 = false
    @AccessibilityFocusState private var isEmailA11yFocused2: Bool
    @FocusState private var isEmailFocused2: Bool

    
    @State private var fnameBad = ""
    @State private var lnameBad = ""
    @State private var phoneBad = ""
    @State private var emailBad = ""
    @State private var firstNameErrorVisibleBad = false
    @State private var fnameLabelBad = "First Name"
    @State private var fnameErrorBad = "This field is required."
    @State private var lnameLabelBad = "Last Name"
    @State private var lnameErrorBad = "This field is required."
    @State private var lastNameErrorVisibleBad = false
    @State private var emailLabelBad = "Email"
    @State private var emailErrorBad = "This field is required."
    @State private var emailErrorVisibleBad = false

    
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Error validation is used to convey error messages for missing or incorrectly entered data. Use `AccessibilityFocusState` to move VoiceOver focus to the first invalid input or error text when submitting a form with invalid data. Use an `.accessibilityHint` or `.accessibilityValue` matching the visible error message text for each invalid input. Visually indicate required fields e.g. with an *.")
                    .padding([.bottom])
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
                Text("Good Example Using .accessibilityHint")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("* indicates required fields")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .font(.caption)
                Text(fnameLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $fname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(firstNameErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(fnameLabel)
                    .accessibilityHint(firstNameErrorVisible ? fnameError : "")
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .accessibilityIdentifier("fNameGood")
                    .accessibilityFocused($isFirstNameA11yFocused)
                    .focused($isFirstNameFocused)
                if firstNameErrorVisible {
                    Text(fnameError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text(lnameLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $lname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .border(lastNameErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(lnameLabel)
                    .accessibilityHint(lastNameErrorVisible ? lnameError : "")
                    .autocorrectionDisabled(true)
                    .textContentType(.familyName)
                    .accessibilityIdentifier("lNameGood")
                    .accessibilityFocused($isLastNameA11yFocused)
                    .focused($isLastNameFocused)
                if lastNameErrorVisible {
                    Text(lnameError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text("Phone Number")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $phone, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Phone Number")
                    .keyboardType(.phonePad)
                    .accessibilityIdentifier("phoneGood")
                Text(emailLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $email, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .border(emailErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(emailLabel)
                    .accessibilityHint(emailErrorVisible ? emailError : "")
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .accessibilityIdentifier("emailGood")
                    .accessibilityFocused($isEmailA11yFocused)
                    .focused($isEmailFocused)
                if emailErrorVisible {
                    Text(emailError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Button(action: {
                    // Handle button action
                    firstNameErrorVisible = false
                    isFirstNameFocused = false
                    isFirstNameA11yFocused = false
                    lastNameErrorVisible = false
                    isLastNameFocused = false
                    isLastNameA11yFocused = false
                    emailErrorVisible = false
                    isEmailFocused = false
                    isEmailA11yFocused = false
                    if email.isEmpty {
                        emailErrorVisible = true
                        isEmailFocused = true
                        isEmailA11yFocused = true
                    }
                    if lname.isEmpty {
                        lastNameErrorVisible = true
                        isLastNameFocused = true
                        isLastNameA11yFocused = true
                    }
                    if fname.isEmpty {
                        firstNameErrorVisible = true
                        isFirstNameFocused = true
                        isFirstNameA11yFocused = true
                    }
                }) {
                    Text("Join Newsletter")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title2)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }.padding()
                DisclosureGroup("Details") {
                    Text("The first good error validation example uses `AccessibilityFocusState` to move VoiceOver focus to the first invalid input when submitting the form with invalid data. Each invalid input has an `.accessibilityHint` matching the visible error message text so that VoiceOver users hear the error message when focused on the invalid inputs. Error messages are meaningful and specific. Required fields are indicated with a * and the meaning of the * is defined at the top of the form.")
                }.padding()
                Text("Good Example Using .accessibilityValue")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("* indicates required fields")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .font(.caption)
                Text(fnameLabel2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $fname2, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(firstNameErrorVisible2 ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(fnameLabel2)
                    .accessibilityValue(firstNameErrorVisible2 ? fname2+fnameError2 : fname2)
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .accessibilityIdentifier("fNameGood2")
                    .accessibilityFocused($isFirstNameA11yFocused2)
                    .focused($isFirstNameFocused2)
                if firstNameErrorVisible2 {
                    Text(fnameError2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text(lnameLabel2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $lname2, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .border(lastNameErrorVisible2 ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(lnameLabel2)
                    .accessibilityValue(lastNameErrorVisible2 ? lname2+lnameError2 : lname2)
                    .autocorrectionDisabled(true)
                    .textContentType(.familyName)
                    .accessibilityIdentifier("lNameGood2")
                    .accessibilityFocused($isLastNameA11yFocused2)
                    .focused($isLastNameFocused2)
                if lastNameErrorVisible2 {
                    Text(lnameError2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text("Phone Number")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $phone2, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Phone Number")
                    .keyboardType(.phonePad)
                    .accessibilityIdentifier("phoneGood2")
                Text(emailLabel2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $email2, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .border(emailErrorVisible2 ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(emailLabel2)
                    .accessibilityValue(emailErrorVisible2 ? email2+emailError2 : email2)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .accessibilityIdentifier("emailGood2")
                    .accessibilityFocused($isEmailA11yFocused2)
                    .focused($isEmailFocused2)
                if emailErrorVisible2 {
                    Text(emailError2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Button(action: {
                    // Handle button action
                    firstNameErrorVisible2 = false
                    isFirstNameFocused2 = false
                    isFirstNameA11yFocused2 = false
                    lastNameErrorVisible2 = false
                    isLastNameFocused2 = false
                    isLastNameA11yFocused2 = false
                    emailErrorVisible2 = false
                    isEmailFocused2 = false
                    isEmailA11yFocused2 = false
                    if email2.isEmpty {
                        emailErrorVisible2 = true
                        isEmailFocused2 = true
                        isEmailA11yFocused2 = true
                    }
                    if lname2.isEmpty {
                        lastNameErrorVisible2 = true
                        isLastNameFocused2 = true
                        isLastNameA11yFocused2 = true
                    }
                    if fname2.isEmpty {
                        firstNameErrorVisible2 = true
                        isFirstNameFocused2 = true
                        isFirstNameA11yFocused2 = true
                    }
                }) {
                    Text("Join Newsletter")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title2)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }.padding()
                DisclosureGroup("Details") {
                    Text("The second good error validation example uses `AccessibilityFocusState` to move VoiceOver focus to the first invalid input when submitting the form with invalid data. Each invalid input has an `.accessibilityValue` matching the visible error message text so that VoiceOver users hear the error message when focused on the invalid inputs. Error messages are meaningful and specific. Required fields are indicated with a * and the meaning of the * is defined at the top of the form.")
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
                Text(fnameLabelBad)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $fnameBad, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(firstNameErrorVisibleBad ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(fnameLabelBad)
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .accessibilityIdentifier("fNameBad")
                if firstNameErrorVisibleBad {
                    Text(fnameErrorBad)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text(lnameLabelBad)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $lnameBad, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .border(lastNameErrorVisibleBad ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(lnameLabelBad)
                    .autocorrectionDisabled(true)
                    .textContentType(.familyName)
                    .accessibilityIdentifier("lNameBad")
                if lastNameErrorVisibleBad {
                    Text(lnameErrorBad)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text("Phone Number")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $phoneBad, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Phone Number")
                    .keyboardType(.phonePad)
                    .accessibilityIdentifier("phoneBad")
                Text(emailLabelBad)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $emailBad, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .border(emailErrorVisibleBad ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(emailLabel)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .accessibilityIdentifier("emailBad")
                if emailErrorVisibleBad {
                    Text(emailErrorBad)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Button(action: {
                    // Handle button action
                    firstNameErrorVisibleBad = false
                    lastNameErrorVisibleBad = false
                    emailErrorVisibleBad = false
                    if emailBad.isEmpty {
                        emailErrorVisibleBad = true
                    }
                    if lnameBad.isEmpty {
                        lastNameErrorVisibleBad = true
                    }   
                    if fnameBad.isEmpty {
                        firstNameErrorVisibleBad = true
                    }
                }) {
                    Text("Join Newsletter")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title2)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }.padding()

                DisclosureGroup("Details") {
                    Text("The bad error validation example does not move VoiceOver focus to the first invalid input when submitting the form with invalid data. Each invalid input does not speak its error message text to VoiceOver users when focused on the invalid inputs. Error messages are generic and not specific. Required fields are not indicated.")
                }.padding()
            }
            .padding()
            .navigationTitle("Error Validation")
        }
 
    }
}
 
struct ErrorValidationView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorValidationView()
    }
}
