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
 
struct TextFieldsFocusManagement: View {

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState private var isFirstNameFocused: Bool
    @AccessibilityFocusState private var isFirstNameA11yFocused: Bool
    @FocusState private var isLastNameFocused: Bool
    @AccessibilityFocusState private var isLastNameA11yFocused: Bool
    @FocusState private var isPhoneFocused: Bool
    @AccessibilityFocusState private var isPhoneA11yFocused: Bool
    @State private var first = ""
    @State private var last = ""
    @State private var phone = ""

    @State private var lastFocusedField: FocusableField?
    enum FocusableField: Hashable {
            case firstName
            case lastName
            case phone
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Text fields will not return Accessibility Focus by default after the user dismisses the keyboard. Use `AccessibilityFocusState` to return Accessibility Focus after the Done button is activated on the keyboard `.toolbar`.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Using `AccessibilityFocusState`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    Text("First Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $first, axis: .vertical)
                        .accessibilityLabel("First Name")
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .focused($isFirstNameFocused)
                        .accessibilityFocused($isFirstNameA11yFocused)
                        .autocorrectionDisabled(true)
                        .textContentType(.givenName)
                        .simultaneousGesture(TapGesture().onEnded {
                            lastFocusedField = .firstName
                        })
                        .submitLabel(.next)
                        .onChange(of: first) {oldValue, newValue in // .onChange to handle when user hits the submit button and prevent a new line
                            guard let newValueLastChar = newValue.last else { return }
                            if newValueLastChar == "\n" {
                                first.removeLast()
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                lastFocusedField = .lastName
                                isLastNameFocused = true
                                isLastNameA11yFocused = true
                            }
                        }
                    Text("Last Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $last, axis: .vertical)
                        .accessibilityLabel("Last Name")
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .focused($isLastNameFocused)
                        .accessibilityFocused($isLastNameA11yFocused)
                        .autocorrectionDisabled(true)
                        .textContentType(.familyName)
                        .simultaneousGesture(TapGesture().onEnded {
                            lastFocusedField = .lastName
                        })
                        .submitLabel(.next)
                        .onChange(of: last) {oldValue, newValue in
                            guard let newValueLastChar = newValue.last else { return }
                            if newValueLastChar == "\n" {
                                last.removeLast()
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                lastFocusedField = .phone
                                isPhoneFocused = true
                                isPhoneA11yFocused = true
                            }
                        }
                    Text("Phone Number")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $phone, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .border(.secondary)
                        .focused($isPhoneFocused)
                        .accessibilityFocused($isPhoneA11yFocused)
                        .accessibilityLabel("Phone Number")
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .simultaneousGesture(TapGesture().onEnded {
                            lastFocusedField = .phone
                        })
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            switch lastFocusedField {
                                case .firstName?:
                                    isFirstNameFocused = false
                                    isFirstNameA11yFocused = true
                                case .lastName?:
                                    isLastNameFocused = false
                                    isLastNameA11yFocused = true
                                case .phone?:
                                    isPhoneFocused = false
                                    isPhoneA11yFocused = true
                                default:
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    break
                            }
                        }
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good example uses `AccessibilityFocusState` to return Accessibility Focus after the Done button is activated on the keyboard `.toolbar`.")
                }
            }
            .navigationTitle("Text Fields Focus Management")
            .padding()
        }
 
    }
}
 
struct TextFieldsFocusManagement_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TextFieldsFocusManagement()
        }
    }
}


