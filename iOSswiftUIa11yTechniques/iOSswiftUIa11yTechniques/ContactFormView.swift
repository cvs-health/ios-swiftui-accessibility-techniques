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

struct ContactFormView: View {
    @State private var showingAlert = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var message = ""
    @State private var nameErrorVisible = false
    @AccessibilityFocusState private var isNameA11yFocused: Bool
    @FocusState private var isNameFocused: Bool
    @State private var nameLabel = "Full Name *"
    @State private var nameInstructions = "First Middle Last"
    @State private var nameError = "⚠ First Name is required. Please enter your first name."
    @State private var emailLabel = "Email *"
    @State private var emailError = "⚠ Email is required. Please enter your email address."
    @State private var emailErrorVisible = false
    @AccessibilityFocusState private var isEmailA11yFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @State private var messageLabel = "Message *"
    @State private var messageInstructions = "Questions, Comments, or Feedback"
    @State private var messageError = "⚠ Message is required. Please enter your question, comment, or feedback in the message field."
    @State private var messageErrorVisible = false
    @AccessibilityFocusState private var isMessageA11yFocused: Bool
    @FocusState private var isMessageFocused: Bool

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

    
   
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use the contact form below to send us a question or comment.")
                    .padding([.bottom])
                Text("Contact Form Using .accessibilityLabel and .accessibilityHint")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("* indicates required fields")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .font(.caption)
                    .padding(.top)
                Text(nameLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                TextField("", text: $name, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(nameErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(nameLabel)
                    .accessibilityHint(nameErrorVisible ? nameError+nameInstructions : nameInstructions)
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .accessibilityFocused($isNameA11yFocused)
                    .focused($isNameFocused)
                Text(nameInstructions)
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if nameErrorVisible {
                    Text(nameError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text("Phone Number")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                TextField("", text: $phone, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Phone Number")
                    .keyboardType(.phonePad)
                Text(emailLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                TextField("", text: $email, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .border(emailErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(emailLabel)
                    .accessibilityHint(emailErrorVisible ? emailError : "")
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .accessibilityFocused($isEmailA11yFocused)
                    .focused($isEmailFocused)
                if emailErrorVisible {
                    Text(emailError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Text(messageLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                TextEditor(text: $message)
                    .textFieldStyle(.roundedBorder)
                    .border(messageErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(messageLabel)
                    .accessibilityHint(messageErrorVisible ? messageError+messageInstructions : messageInstructions)
                    .accessibilityFocused($isMessageA11yFocused)
                    .focused($isMessageFocused)
                    .frame(minHeight:100, maxHeight: .infinity)
                    .padding(.horizontal, 1)
                Text(messageInstructions)
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if messageErrorVisible {
                    Text(messageError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Button(action: {
                    // Handle button action
                    nameErrorVisible = false
                    isNameFocused = false
                    isNameA11yFocused = false
                    emailErrorVisible = false
                    isEmailFocused = false
                    isEmailA11yFocused = false
                    messageErrorVisible = false
                    isMessageFocused = false
                    isMessageA11yFocused = false
                    if email.isEmpty {
                        emailErrorVisible = true
                        isEmailFocused = true
                        isEmailA11yFocused = true
                    }
                    if name.isEmpty {
                        nameErrorVisible = true
                        isNameFocused = true
                        isNameA11yFocused = true
                    }
                    if message.isEmpty {
                        messageErrorVisible = true
                        isMessageFocused = true
                        isMessageA11yFocused = true
                    }
                    if !message.isEmpty && !name.isEmpty && !email.isEmpty {
                        showingAlert = true
                    }
                }) {
                    Text("Send Message")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title3)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }
                .accessibilityFocused($isTriggerFocused)
                .padding(.top).frame(maxWidth: .infinity, alignment: .leading)
                .alert("Thanks for sending us a message!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                        isTriggerFocused = true
                    }
                } message: {
                    Text("We will read your message and reply ASAP.")
                }
                DisclosureGroup("Details") {
                    Text("The first good error validation example uses `AccessibilityFocusState` to move VoiceOver focus to the first invalid input when submitting the form with invalid data. Each invalid input has an `.accessibilityHint` matching the visible error message text so that VoiceOver users hear the error message when focused on the invalid inputs. Error messages are meaningful and specific. Required fields are indicated with a * and the meaning of the * is defined at the top of the form.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example Using `LabeledContent` and `.accessibilityHint`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("* indicates required fields")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .font(.caption)
                    .padding(.top)
                LabeledContent(nameLabel) {
                      TextField("", text:$name)
                        .textFieldStyle(.roundedBorder)
                        .border(nameErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                        .accessibilityHint(nameErrorVisible ? nameError+nameInstructions : nameInstructions)
                        .autocorrectionDisabled(true)
                        .textContentType(.givenName)
                        .accessibilityFocused($isNameA11yFocused)
                        .focused($isNameFocused)
                }.labeledContentStyle(.vertical).padding(.top)
                Text(nameInstructions)
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if nameErrorVisible {
                    Text(nameError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                LabeledContent("Phone Number") {
                      TextField("", text:$phone)
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .keyboardType(.phonePad)
                }.labeledContentStyle(.vertical).padding(.top)
                LabeledContent(emailLabel) {
                      TextField("", text:$email)
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .border(emailErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                        .accessibilityHint(emailErrorVisible ? emailError : "")
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .accessibilityFocused($isEmailA11yFocused)
                        .focused($isEmailFocused)
                }.labeledContentStyle(.vertical).padding(.top)
                if emailErrorVisible {
                    Text(emailError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                LabeledContent(messageLabel) {
                      TextEditor(text: $message)
                        .textFieldStyle(.roundedBorder)
                        .border(messageErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                        .accessibilityHint(messageErrorVisible ? messageError+messageInstructions : messageInstructions)
                        .accessibilityFocused($isMessageA11yFocused)
                        .focused($isMessageFocused)
                        .frame(minHeight:100, maxHeight: .infinity)
                        .padding(.horizontal, 1)
                }.labeledContentStyle(.vertical).padding(.top)
                Text(messageInstructions)
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if messageErrorVisible {
                    Text(messageError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Button(action: {
                    // Handle button action
                    nameErrorVisible = false
                    isNameFocused = false
                    isNameA11yFocused = false
                    emailErrorVisible = false
                    isEmailFocused = false
                    isEmailA11yFocused = false
                    messageErrorVisible = false
                    isMessageFocused = false
                    isMessageA11yFocused = false
                    if email.isEmpty {
                        emailErrorVisible = true
                        isEmailFocused = true
                        isEmailA11yFocused = true
                    }
                    if name.isEmpty {
                        nameErrorVisible = true
                        isNameFocused = true
                        isNameA11yFocused = true
                    }
                    if message.isEmpty {
                        messageErrorVisible = true
                        isMessageFocused = true
                        isMessageA11yFocused = true
                    }
                }) {
                    Text("Send Message")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title3)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }.padding(.top).frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The second good Text Fields example uses `LabeledContent` to provide visible label text that also becomes the accessible name of each `TextField`. When using `LabeledContent` an `.accessibilityLabel` is not required.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                    Text("Send Message")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title3)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }.padding(.top).frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The second good error validation example uses `AccessibilityFocusState` to move VoiceOver focus to the first invalid input when submitting the form with invalid data. Each invalid input has an `.accessibilityValue` matching the visible error message text so that VoiceOver users hear the error message when focused on the invalid inputs. Error messages are meaningful and specific. Required fields are indicated with a * and the meaning of the * is defined at the top of the form.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .padding()
            .navigationBarTitle("Contact Form")
        }
 
    }
}
 
struct ContactFormView_Previews: PreviewProvider {
    static var previews: some View {
        ContactFormView()
    }
}
