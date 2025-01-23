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

struct SignUp0: View {
    @FocusState private var isFullNameFocused: Bool
    @FocusState private var isNickNameFocused: Bool
    @FocusState private var isBirthDateFocused: Bool
    @AccessibilityFocusState private var isFullNameA11yFocused: Bool
    @AccessibilityFocusState private var isNickNameA11yFocused: Bool
    @AccessibilityFocusState private var isBirthDateA11yFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var fname = ""
    @State private var nname = ""
    @State private var bday = ""
    @State private var confirmToggle = false
    
    @State private var lastFocusedField: FocusableField? = .fullName
    enum FocusableField: Hashable {
            case fullName
            case nickName
            case birthDate
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Full Name (Required)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                TextField("", text: $fname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Full Name (Required)")
                    .autocorrectionDisabled(true)
                    .textContentType(.name)
                    .focused($isFullNameFocused)
                    .accessibilityFocused($isFullNameA11yFocused)
                    .simultaneousGesture(TapGesture().onEnded {
                        lastFocusedField = .fullName
                    })
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Previous", systemImage: "arrow.left.square") {
                                switch lastFocusedField {
                                    case .fullName?:
                                        isFullNameFocused = false
                                        isNickNameFocused = false
                                    isBirthDateFocused = true
                                    lastFocusedField = .birthDate
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isBirthDateA11yFocused = true
                                        }
                                    case .nickName?:
                                        isNickNameFocused = false
                                    isBirthDateFocused = false
                                        lastFocusedField = .fullName
                                        isFullNameFocused = true
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isFullNameA11yFocused = true
                                        }
                                case .birthDate?:
                                        isBirthDateFocused = false
                                    isFullNameFocused = false
                                    lastFocusedField = .nickName
                                        isNickNameFocused = true
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isNickNameA11yFocused = true
                                        }
                                default:
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    break
                                }
                            }
                            Button("Next", systemImage: "arrow.right.square") {
                                switch lastFocusedField {
                                    case .fullName?:
                                        isFullNameFocused = false
                                    isBirthDateFocused = false
                                        isNickNameFocused = true
                                        lastFocusedField = .nickName
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isNickNameA11yFocused = true
                                        }
                                    case .nickName?:
                                        isFullNameFocused = false
                                        isNickNameFocused = false
                                    isBirthDateFocused = true
                                    lastFocusedField = .birthDate
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isBirthDateA11yFocused = true
                                    }
                                case .birthDate?:
                                    isFullNameFocused = true
                                    isNickNameFocused = false
                                isBirthDateFocused = false
                                    lastFocusedField = .fullName
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                    isFullNameA11yFocused = true
                                }
                                    default:
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        break
                                }
                            }
                            Spacer()
                            Button("Done") {
                                switch lastFocusedField {
                                    case .fullName?:
                                    isBirthDateFocused = false
                                    isFullNameFocused = false
                                    isNickNameFocused = false
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isFullNameA11yFocused = true
                                        }
                                    case .nickName?:
                                        isBirthDateFocused = false
                                        isFullNameFocused = false
                                        isNickNameFocused = false
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isNickNameA11yFocused = true
                                    }
                                    case .birthDate?:
                                        isBirthDateFocused = false
                                        isFullNameFocused = false
                                        isNickNameFocused = false
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isBirthDateA11yFocused = true
                                    }
                                        default:
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            break
                                }
                            }
                        }
                    }
                    .submitLabel(.next)
                    .onChange(of: fname) {oldValue, newValue in
                        guard let newValueLastChar = newValue.last else { return }
                        if newValueLastChar == "\n" {
                            fname.removeLast()
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            lastFocusedField = .fullName
                            isNickNameFocused = true
                            isNickNameA11yFocused = true
                        }
                    }
                Text("Nickname")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                Text("Max 12 characters")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                TextField("", text: $nname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Nickname")
                    .accessibilityHint("Max 12 characters")
                    .autocorrectionDisabled(true)
                    .textContentType(.nickname)
                    .focused($isNickNameFocused)
                    .accessibilityFocused($isNickNameA11yFocused)
                    .simultaneousGesture(TapGesture().onEnded {
                        lastFocusedField = .nickName
                    })
                    .submitLabel(.next)
                    .onChange(of: nname) {oldValue, newValue in
                        guard let newValueLastChar = newValue.last else { return }
                        if newValueLastChar == "\n" {
                            nname.removeLast()
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            isNickNameFocused = false
                            isBirthDateFocused = true
                            isBirthDateA11yFocused = true
                        }
                    }
                Text("Birth Date")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                Text("MM/DD/YYYY")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                TextField("", text: $bday, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Birth Date")
                    .accessibilityHint("MM/DD/YYYY")
                    .autocorrectionDisabled(true)
                    .textContentType(.birthdate)
                    .keyboardType(.numberPad)
                    .focused($isBirthDateFocused)
                    .accessibilityFocused($isBirthDateA11yFocused)
                    .simultaneousGesture(TapGesture().onEnded {
                        lastFocusedField = .birthDate
                    })
                    .submitLabel(.done)
                    .onChange(of: bday) {oldValue, newValue in
                        guard let newValueLastChar = newValue.last else { return }
                        if newValueLastChar == "\n" {
                            bday.removeLast()
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            lastFocusedField = .birthDate
                            isBirthDateFocused = false
                            isBirthDateA11yFocused = true
                        }
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        var formatted = ""

                        // Add slashes at the right positions
                        for (index, character) in filtered.enumerated() {
                            if index == 2 || index == 4 {
                                formatted += "/"
                            }
                            formatted.append(character)
                        }

                        // Limit the length to 10 (MM/DD/YYYY)
                        if formatted.count > 10 {
                            formatted = String(formatted.prefix(10))
                        }

                        bday = formatted
                    }
                Toggle("I confirm the above is accurate.", isOn: $confirmToggle)
                    .padding()
                    .bold()
                NavigationLink(destination: ThankYou()) {
                    HStack {
                        Image(systemName: "smiley")
                        Text("Sign Up")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()
                }
                .background(Color("AccentColor"))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .clipShape(.capsule)
            }
            .navigationTitle("Sign Up 0")
            .padding()

        }
 
    }


}

#Preview {
    NavigationStack {
        SignUp0()
    }
}

