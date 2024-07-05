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

struct FormA: View {
    
    @State private var showingAlert = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    
    @State private var email = ""
    @State private var emailLabel = "Email Address"
    @State private var newPassword = ""
    @State private var newPasswordLabel = "New Password *"
    @State private var newPasswordInstructions = "Password must be 8 characters long including a special character and a number."
    @State private var newPasswordError = "⚠ Password does not meet requirements."
    @State private var newPasswordErrorVisible = false
    @AccessibilityFocusState private var isNewPasswordA11yFocused: Bool
    @FocusState private var isNewPasswordFocused: Bool
    
    // Regular expressions for checking special characters and numbers
    let specialCharacterRegex = "[^A-Za-z0-9]"
    let numberRegex = "\\d"
  
    var body: some View {
        ScrollView {
            VStack {
                Text(emailLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .accessibilityHidden(true)
                TextField("", text: $email, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel(emailLabel)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                Text(newPasswordLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .accessibilityHidden(true)
                Text(newPasswordInstructions)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
                SecureField("", text: $newPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .border(newPasswordErrorVisible ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                    .accessibilityLabel(newPasswordErrorVisible ? newPasswordLabel+", invalid entry, required, "+newPasswordError+", "+newPasswordInstructions : newPasswordLabel+", required, "+newPasswordInstructions)
                    .accessibilityFocused($isNewPasswordA11yFocused)
                    .focused($isNewPasswordFocused)
                if newPasswordErrorVisible {
                    Text(newPasswordError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                        .accessibilityHidden(true)
                }
                Button(action: {
                    newPasswordErrorVisible = false
                    isNewPasswordFocused = false
                    isNewPasswordA11yFocused = false
                    
                    if newPassword.count >= 8 {
                        let hasSpecialChar = newPassword.range(of: specialCharacterRegex, options: .regularExpression) != nil
                        let hasNumber = newPassword.range(of: numberRegex, options: .regularExpression) != nil
                        if hasSpecialChar && hasNumber {
                            showingAlert = true
                            newPassword = ""
                        } else {
                            newPasswordErrorVisible = true
                            isNewPasswordFocused = true
                            isNewPasswordA11yFocused = true
                        }
                    } else {
                        newPasswordErrorVisible = true
                        isNewPasswordFocused = true
                        isNewPasswordA11yFocused = true
                    }
                }) {
                    Text("Reset Password")
                        .padding(10)
                        .background(darkRed)
                        .foregroundColor(.primary)
                        .border(.black)
                }.padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($isTriggerFocused)
                .alert("Password Reset", isPresented: $showingAlert) {
                    Button("OK") {
                        isTriggerFocused = true
                    }
                } message: {
                    Text("Your password has been successfully reset.")
                }
            }
            .navigationTitle("Reset Password A")
            .padding()

        }
 
    }

}
 
struct FormA_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FormA()
        }
    }
}
