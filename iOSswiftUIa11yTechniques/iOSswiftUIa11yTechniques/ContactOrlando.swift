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

struct ContactOrlando: View {
    @State private var showingAlert = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var message = ""
    @State private var useridErrorVisible = false
    @State private var useridOverUnderDigitsErrorVisible = false
    @AccessibilityFocusState private var isUseridA11yFocused: Bool
    @FocusState private var isUseridFocused: Bool
    @State private var useridLabel = "User ID (required)"
    @State private var useridInstructions = "The last 5 digits of your account number."
    @State private var useridValue = "The last 5 digits of your account number."
    @State private var useridError = "⚠ User ID is required. Please enter the last 5 digits of your account number."
    @State private var useridOverUnderDigitsError = "⚠ User ID is not 5 digits. Please enter only the last 5 digits of your account number."
    @State private var emailLabel = "Email (required)"
    @State private var emailError = "⚠ Email is required. Please enter your email address."
    @State private var emailErrorVisible = false
    @AccessibilityFocusState private var isEmailA11yFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @State private var messageLabel = "Message (required)"
    @State private var messageInstructions = "Questions, Comments, or Feedback"
    @State private var messageError = "⚠ Message is required. Please enter your question, comment, or feedback in the message field."
    @State private var messageErrorVisible = false
    @AccessibilityFocusState private var isMessageA11yFocused: Bool
    @FocusState private var isMessageFocused: Bool

  
   
    
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use the contact form below to send the Orlando office a question or comment.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                //This is the Pulse annotations and .accessibilityValue coded form
                Text(useridLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .bold()
                    .accessibilityHidden(true)
                Text(useridInstructions)
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
                TextField("", text: $name, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(useridErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(useridLabel)
                    .accessibilityValue(useridValue)
                    .autocorrectionDisabled(true)
                    .textContentType(.username)
                    .keyboardType(.numberPad)
                    .accessibilityFocused($isUseridA11yFocused)
                    .focused($isUseridFocused)
                if useridErrorVisible {
                    Text(useridError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                        .accessibilityHidden(true)
                }else if useridOverUnderDigitsErrorVisible {
                    Text(useridOverUnderDigitsError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                        .accessibilityHidden(true)
                }
                Text("Phone Number (optional)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .bold()
                    .accessibilityHidden(true)
                Text("10-digit, U.S. only, for example 999-999-9999")
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
                TextField("", text: $phone, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Phone Number (optional)")
                    .keyboardType(.phonePad)
                    .accessibilityValue(phone+", 10-digit, U.S. only, for example 999-999-9999")
                Text(emailLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .bold()
                    .accessibilityHidden(true)
                TextField("", text: $email, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(emailErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(emailLabel)
                    .accessibilityValue(emailErrorVisible ? email+", "+emailError : email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .accessibilityFocused($isEmailA11yFocused)
                    .focused($isEmailFocused)
                if emailErrorVisible {
                    Text(emailError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                        .accessibilityHidden(true)
                }
                Text(messageLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .bold()
                    .accessibilityHidden(true)
                Text(messageInstructions)
                    .italic()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
                TextEditor(text: $message)
                    .textFieldStyle(.roundedBorder)
                    .border(messageErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(messageLabel)
                    .accessibilityValue(messageErrorVisible ? message+", "+messageError+", "+messageInstructions : message+", "+messageInstructions)
                    .accessibilityFocused($isMessageA11yFocused)
                    .focused($isMessageFocused)
                    .frame(minHeight:100, maxHeight: .infinity)
                    .padding(.horizontal, 1)
                if messageErrorVisible {
                    Text(messageError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                        .accessibilityHidden(true)
                }
                Button(action: {
                    // Handle button action
                    useridErrorVisible = false
                    useridOverUnderDigitsErrorVisible = false
                    isUseridFocused = false
                    isUseridA11yFocused = false
                    emailErrorVisible = false
                    isEmailFocused = false
                    isEmailA11yFocused = false
                    messageErrorVisible = false
                    isMessageFocused = false
                    isMessageA11yFocused = false
                    useridValue = useridInstructions
                    if message.isEmpty {
                        messageErrorVisible = true
                        isMessageFocused = true
                        isMessageA11yFocused = true
                    }
                    if email.isEmpty {
                        emailErrorVisible = true
                        isEmailFocused = true
                        isEmailA11yFocused = true
                    }
                    if name.isEmpty && name.count < 1 {
                        useridValue = useridError+", "+useridInstructions
                        useridErrorVisible = true
                        isUseridFocused = true
                        isUseridA11yFocused = true
                    }
                    if name.count != 5 && name.count > 0 {
                        useridValue = useridOverUnderDigitsError+", "+useridInstructions
                        useridOverUnderDigitsErrorVisible = true
                        isUseridFocused = true
                        isUseridA11yFocused = true
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
                .alert("Thanks for contacting Orlando office!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                        isTriggerFocused = true
                    }
                } message: {
                    Text("We'll reply as soon as possible.")
                }
                Spacer(minLength: 100)
                Text(".aL .aV").frame(maxWidth: .infinity, alignment: .trailing).font(.caption2).foregroundStyle(.gray).accessibilityHidden(true)

            }
            .padding()
            .navigationTitle("Contact Orlando Office")
        }
 
    }
}
 
struct ContactOrlando_Previews: PreviewProvider {
    static var previews: some View {
        ContactOrlando()
    }
}
