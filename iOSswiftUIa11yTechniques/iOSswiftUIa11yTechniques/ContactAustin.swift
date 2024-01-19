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

struct ContactAustin: View {
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

  
   
    
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use the contact form below to send the Austin office a question or comment.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("* indicates required fields")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .font(.caption)
                    .padding(.top)
                //This is the .accessibilityLabel and .accessibilityHint coded form
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
                    if name.isEmpty {
                        nameErrorVisible = true
                        isNameFocused = true
                        isNameA11yFocused = true
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
                .alert("Thanks for sending the Austin office a message!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                        isTriggerFocused = true
                    }
                } message: {
                    Text("We will read your message and reply ASAP.")
                }
                Spacer(minLength: 100)
                Text(".aL .aH").frame(maxWidth: .infinity, alignment: .trailing).font(.caption2).foregroundStyle(.gray)
            }
            .padding()
            .navigationTitle("Contact Austin Office")
        }
 
    }
}
 
struct ContactAustin_Previews: PreviewProvider {
    static var previews: some View {
        ContactAustin()
    }
}
