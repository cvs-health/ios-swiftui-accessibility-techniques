/*
   Copyright 2024 CVS Health and/or one of its affiliates

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

struct FormB: View {
    
    @State private var showingAlert2 = false
    @AccessibilityFocusState private var isTriggerFocused2: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

       
    @State private var email2 = ""
    @State private var emailLabel2 = "Email Address"
    @State private var newPassword2 = ""
    @State private var newPasswordLabel2 = "New Password *"
    @State private var newPasswordInstructions2 = "Password must be 8 characters long including a special character and a number."
    @State private var newPasswordError2 = "⚠ Password does not meet requirements."
    @State private var newPasswordErrorVisible2 = false
    @AccessibilityFocusState private var isNewPasswordA11yFocused2: Bool
    @FocusState private var isNewPasswordFocused2: Bool

    // Regular expressions for checking special characters and numbers
    let specialCharacterRegex = "[^A-Za-z0-9]"
    let numberRegex = "\\d"
    
    var body: some View {
        ScrollView {
            VStack {
                Text(emailLabel2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .accessibilityHidden(true)
                TextField("", text: $email2, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel(emailLabel2)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                Text(newPasswordLabel2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                Text(newPasswordInstructions2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SecureField("", text: $newPassword2)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .border(newPasswordErrorVisible2 ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(newPasswordErrorVisible2 ? newPasswordLabel2+", invalid entry, required" : newPasswordLabel2 + ", required")
                    .accessibilityHint(newPasswordErrorVisible2 ? newPasswordError2+", "+newPasswordInstructions2 : newPasswordInstructions2)
                    .accessibilityFocused($isNewPasswordA11yFocused2)
                    .focused($isNewPasswordFocused2)
                if newPasswordErrorVisible2 {
                    Text(newPasswordError2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }
                Button(action: {
                    newPasswordErrorVisible2 = false
                    isNewPasswordFocused2 = false
                    isNewPasswordA11yFocused2 = false
                    
                    if newPassword2.count >= 8 {
                        let hasSpecialChar = newPassword2.range(of: specialCharacterRegex, options: .regularExpression) != nil
                        let hasNumber = newPassword2.range(of: numberRegex, options: .regularExpression) != nil
                        if hasSpecialChar && hasNumber {
                            showingAlert2 = true
                            newPassword2 = ""
                        } else {
                            newPasswordErrorVisible2 = true
                            isNewPasswordFocused2 = true
                            isNewPasswordA11yFocused2 = true
                        }
                    } else {
                        newPasswordErrorVisible2 = true
                        isNewPasswordFocused2 = true
                        isNewPasswordA11yFocused2 = true
                    }
                }) {
                    Text("Reset Password")
                        .padding(10)
                        .background(darkRed)
                        .foregroundColor(.primary)
                        .border(.black)
                }.padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($isTriggerFocused2)
                .alert("Password Reset", isPresented: $showingAlert2) {
                    Button("OK") {
                        isTriggerFocused2 = true
                    }
                } message: {
                    Text("Your password has been successfully reset.")
                }
            }
            .navigationTitle("Reset Password B")
            .padding()

        }
 
    }
    
}
 
struct FormB_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FormB()
        }
    }
}
