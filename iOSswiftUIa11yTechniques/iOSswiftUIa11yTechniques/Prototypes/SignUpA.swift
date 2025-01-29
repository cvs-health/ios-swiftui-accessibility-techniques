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

struct SignUpA: View {
    @State private var selectedDate = Calendar.current.date(byAdding: DateComponents(year: -40), to: Date()) ?? Date()
    @State private var isDatePickerPresented = false
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @FocusState private var isFullNameFocused: Bool
    @FocusState private var isNickNameFocused: Bool
    @AccessibilityFocusState private var isFullNameA11yFocused: Bool
    @AccessibilityFocusState private var isNickNameA11yFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var fname = ""
    @State private var nname = ""
    @State private var confirmToggle = false
    
    @State private var lastFocusedField: FocusableField? = .fullName
    enum FocusableField: Hashable {
            case fullName
            case nickName
    }

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Full Name (Required)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                    .accessibilityHidden(true)
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
                                        isDatePickerPresented = true
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        }
                                    case .nickName?:
                                        isNickNameFocused = false
                                        lastFocusedField = .fullName
                                        isFullNameFocused = true
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isFullNameA11yFocused = true
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
                                        isNickNameFocused = true
                                        lastFocusedField = .nickName
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isNickNameA11yFocused = true
                                        }
                                    case .nickName?:
                                        isFullNameFocused = false
                                        isNickNameFocused = false
                                        isDatePickerPresented = true
                                    default:
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        break
                                }
                            }
                            Spacer()
                            Button("Done") {
                                switch lastFocusedField {
                                    case .fullName?:
                                        isFullNameFocused = false
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isFullNameA11yFocused = true
                                        }
                                    case .nickName?:
                                        isNickNameFocused = false
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isNickNameA11yFocused = true
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
                    .accessibilityHidden(true)
                Text("Max 12 characters")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                    .accessibilityHidden(true)
                TextField("", text: $nname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Nickname")
                    .accessibilityValue(nname + ", Max 12 characters")
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
                            isDatePickerPresented = true
                        }
                    }
                Spacer().frame(height: 20)
                HStack {
                    Text("Birth Date")
                        .accessibilityHidden(true)
                    Spacer()
                    Button(action: {
                         isDatePickerPresented = true
                     }) {
                         HStack {
                             Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                 .padding(10)
                                 .background(Color.gray.opacity(0.2))
                                 .foregroundColor(colorScheme == .dark ? .white : .black)
                                 .cornerRadius(10)
                         }
                     }
                     .accessibilityLabel("Birth Date")
                     .accessibilityValue(selectedDate.formatted(date: .abbreviated, time: .omitted))
                     .accessibilityFocused($isTriggerFocused)
                     .sheet(isPresented: $isDatePickerPresented) {
                         HStack {
                             Spacer()
                             Button("Done") {
                                 isDatePickerPresented = false
                                 isTriggerFocused = true
                             }
                         }.padding()
                         DatePicker("Birth Date", selection: $selectedDate, displayedComponents: [.date])
                             .datePickerStyle(.wheel)
                             .labelsHidden()
                             .accessibilitySortPriority(1) // make VoiceOver focus go here first when sheet opens
                         .presentationDetents([.height(300)])
                         .presentationDragIndicator(.hidden)
                     }
                }
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 1)
                )
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
            .navigationTitle("Sign Up A")
            .padding()

        }
 
    }


}

#Preview {
    NavigationStack {
        SignUpA()
    }
}

