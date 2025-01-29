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

struct SignUp1: View {
    @FocusState private var isFullNameFocused: Bool
    @FocusState private var isNickNameFocused: Bool
    @FocusState private var isbDayFocused: Bool
    @FocusState private var isbMonthFocused: Bool
    @FocusState private var isbYearFocused: Bool
    @AccessibilityFocusState private var isFullNameA11yFocused: Bool
    @AccessibilityFocusState private var isNickNameA11yFocused: Bool
    @AccessibilityFocusState private var isbDayA11yFocused: Bool
    @AccessibilityFocusState private var isbMonthA11yFocused: Bool
    @AccessibilityFocusState private var isbYearA11yFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var fname = ""
    @State private var nname = ""
    @State private var bmonth = ""
    @State private var bday = ""
    @State private var byear = ""
    @State private var confirmToggle = false
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @State private var showingAlert = false
    @State private var submitActive = false

    @State private var errorText = ""
    @State private var errorVisible = false
    @State private var monthInvalid = false
    @State private var dayInvalid = false
    @State private var yearInvalid = false
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)


    @State private var lastFocusedField: FocusableField? = .fullName
    enum FocusableField: Hashable {
        case fullName
        case nickName
        case bDay
        case bMonth
        case bYear
    }

    func validateInputs() {
        monthInvalid = false
        dayInvalid = false
        yearInvalid = false
        errorVisible = false
        if bmonth.count != 2 && bday.count != 2 && byear.count != 4 {
            errorText = "Error: Month must be 2 digits. MM format. Day must be 2 digits. DD format. Year must be 4 digits. YYYY format."
            monthInvalid = true
            dayInvalid = true
            yearInvalid = true
            errorVisible = true
            showingAlert = true
        } else if bday.count != 2 && byear.count != 4 {
            errorText = "Error: Day must be 2 digits. DD format. Year must be 4 digits. YYYY format."
            dayInvalid = true
            yearInvalid = true
            errorVisible = true
            showingAlert = true
        } else if bmonth.count != 2 && byear.count != 4 {
            errorText = "Error: Month must be 2 digits. MM format. Year must be 4 digits. YYYY format."
            monthInvalid = true
            yearInvalid = true
            errorVisible = true
            showingAlert = true
        } else if bmonth.count != 2 && bday.count != 2 {
            errorText = "Error: Month must be 2 digits. MM format. Day must be 2 digits. DD format."
            monthInvalid = true
            dayInvalid = true
            errorVisible = true
            showingAlert = true
        } else if bmonth.count != 2 {
            errorText = "Error: Month must be 2 digits. MM format."
            monthInvalid = true
            errorVisible = true
            showingAlert = true
        } else if bday.count != 2 {
            errorText = "Error: Day must be 2 digits. DD format."
            dayInvalid = true
            errorVisible = true
            showingAlert = true
        } else if byear.count != 4 {
            errorText = "Error: Year must be 4 digits. YYYY format."
            yearInvalid = true
            errorVisible = true
            showingAlert = true
        } else {
            errorText = ""
            monthInvalid = false
            dayInvalid = false
            yearInvalid = false
            errorVisible = false
            submitActive = true
        }
    }
    func validateInputsNoAlert() {
        if errorVisible {
            monthInvalid = false
            dayInvalid = false
            yearInvalid = false
            errorVisible = false
            if bmonth.count != 2 && bday.count != 2 && byear.count != 4 {
                errorText = "Error: Month must be 2 digits. MM format. Day must be 2 digits. DD format. Year must be 4 digits. YYYY format."
                monthInvalid = true
                dayInvalid = true
                yearInvalid = true
                errorVisible = true
            } else if bday.count != 2 && byear.count != 4 {
                errorText = "Error: Day must be 2 digits. DD format. Year must be 4 digits. YYYY format."
                dayInvalid = true
                yearInvalid = true
                errorVisible = true
            } else if bmonth.count != 2 && byear.count != 4 {
                errorText = "Error: Month must be 2 digits. MM format. Year must be 4 digits. YYYY format."
                monthInvalid = true
                yearInvalid = true
                errorVisible = true
            } else if bmonth.count != 2 && bday.count != 2 {
                errorText = "Error: Month must be 2 digits. MM format. Day must be 2 digits. DD format."
                monthInvalid = true
                dayInvalid = true
                errorVisible = true
            } else if bmonth.count != 2 {
                errorText = "Error: Month must be 2 digits. MM format."
                monthInvalid = true
                errorVisible = true
            } else if bday.count != 2 {
                errorText = "Error: Day must be 2 digits. DD format."
                dayInvalid = true
                errorVisible = true
            } else if byear.count != 4 {
                errorText = "Error: Year must be 4 digits. YYYY format."
                yearInvalid = true
                errorVisible = true
            } else {
                errorText = ""
                monthInvalid = false
                dayInvalid = false
                yearInvalid = false
                errorVisible = false
            }

        }
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
                                isbYearFocused = true
                                lastFocusedField = .bYear
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isbYearA11yFocused = true
                                    }
                                case .nickName?:
                                    isNickNameFocused = false
                                    lastFocusedField = .fullName
                                    isFullNameFocused = true
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isFullNameA11yFocused = true
                                    }
                            case .bMonth?:
                                isbDayFocused = false
                                isbYearFocused = false
                                isbMonthFocused = false
                                isFullNameFocused = false
                                lastFocusedField = .nickName
                                isNickNameFocused = true
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                    isNickNameA11yFocused = true
                                }
                                case .bDay?:
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isNickNameFocused = false
                                    isFullNameFocused = false
                                    lastFocusedField = .bMonth
                                    isbMonthFocused = true
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isbMonthA11yFocused = true
                                    }
                                case .bYear?:
                                    isbDayFocused = true
                                    isbYearFocused = false
                                    isbMonthFocused = false
                                    isFullNameFocused = false
                                    lastFocusedField = .bDay
                                    isbDayFocused = false
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isbDayA11yFocused = true
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
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isbMonthFocused = false
                                        lastFocusedField = .nickName
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isNickNameA11yFocused = true
                                        }
                                    case .nickName?:
                                        isNickNameFocused = false
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isbMonthFocused = true
                                        lastFocusedField = .bMonth
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                       isbMonthA11yFocused = true
                                        }
                                case .bMonth?:
                                isbDayFocused = true
                                isbYearFocused = false
                                isbMonthFocused = false
                                    lastFocusedField = .bDay
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isbDayA11yFocused = true
                                    }
                                case .bDay?:
                                isbDayFocused = false
                                isbYearFocused = true
                                isbMonthFocused = false
                                    lastFocusedField = .bYear
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isbYearA11yFocused = true
                                    }
                                case .bYear?:
                                    isFullNameFocused = true
                                    isNickNameFocused = false
                                isbDayFocused = false
                                isbYearFocused = false
                                isbMonthFocused = false
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
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isbMonthFocused = false
                                    isFullNameFocused = false
                                    isNickNameFocused = false
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                            isFullNameA11yFocused = true
                                        }
                                case .nickName?:
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isbMonthFocused = false
                                    isFullNameFocused = false
                                    isNickNameFocused = false
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                    isNickNameA11yFocused = true
                                }
                                case .bMonth?:
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isbMonthFocused = false
                                    isFullNameFocused = false
                                    isNickNameFocused = false
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                   isbMonthA11yFocused = true
                                }
                                case .bDay?:
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isbMonthFocused = false
                                    isFullNameFocused = false
                                    isNickNameFocused = false
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                   isbDayA11yFocused = true
                                }
                                case .bYear?:
                                    isbDayFocused = false
                                    isbYearFocused = false
                                    isbMonthFocused = false
                                    isFullNameFocused = false
                                    isNickNameFocused = false
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                   isbYearA11yFocused = true
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
                            isbMonthFocused = true
                            isbMonthA11yFocused = true
                        }
                    }
                VStack {
                    Text("Birth Date")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("MM/DD/YYYY")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityHidden(true)
                }.accessibilityElement(children: .combine)
                    .accessibilityLabel("Birth Date")
                    .accessibilityValue("MM/DD/YYYY" + errorText)
                HStack {
                    let layout = (dynamicTypeSize > DynamicTypeSize.xxxLarge) ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
                    layout {
                        HStack {
                            VStack {
                                Text("Month")
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityHidden(true)
                                TextField("", text: $bmonth, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .border(monthInvalid ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                                    .accessibilityLabel("Month")
                                    .accessibilityValue(bmonth + errorText)
                                    .accessibilityHint("MM, 2 digit month")
                                    .autocorrectionDisabled(true)
                                    .textContentType(.birthdateMonth)
                                    .keyboardType(.numberPad)
                                    .focused($isbMonthFocused)
                                    .onChange(of: isbMonthFocused) {oldValue, newValue in
                                        if !newValue {
                                            // Focus lost
                                            validateInputsNoAlert()
                                        }
                                    }
                                    .accessibilityFocused($isbMonthA11yFocused)
                                    .simultaneousGesture(TapGesture().onEnded {
                                        lastFocusedField = .bMonth
                                    })
                                    .submitLabel(.next)
                                    .onChange(of: bmonth) {oldValue, newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        bmonth = String(filtered.prefix(2))
                                        
                                        guard let newValueLastChar = newValue.last else { return }
                                        if newValueLastChar == "\n" {
                                            if bmonth.count > 2 {
                                                bmonth.removeLast()
                                            }
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            isbMonthFocused = false
                                            isbDayFocused = true
                                            isbDayA11yFocused = true
                                        }
                                    }
                            }.accessibilityElement(children: .contain)
                            VStack {
                                Text("Day")
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityHidden(true)
                                TextField("", text: $bday, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .border(dayInvalid ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                                    .accessibilityLabel("Day")
                                    .accessibilityValue(bday + errorText)
                                    .accessibilityHint("DD, 2 digit day")
                                    .autocorrectionDisabled(true)
                                    .textContentType(.birthdateDay)
                                    .keyboardType(.numberPad)
                                    .focused($isbDayFocused)
                                    .onChange(of: isbDayFocused) {oldValue, newValue in
                                        if !newValue {
                                            // Focus lost
                                            validateInputsNoAlert()
                                        }
                                    }
                                    .accessibilityFocused($isbDayA11yFocused)
                                    .simultaneousGesture(TapGesture().onEnded {
                                        lastFocusedField = .bDay
                                    })
                                    .submitLabel(.next)
                                    .onChange(of: bday) {oldValue, newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        bday = String(filtered.prefix(2))
                                        
                                        guard let newValueLastChar = newValue.last else { return }
                                        if newValueLastChar == "\n" {
                                            if bday.count > 2 {
                                                bday.removeLast()
                                            }
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            isbMonthFocused = false
                                            isbYearFocused = true
                                            isbYearA11yFocused = true
                                        }

                                    }
                            }.accessibilityElement(children: .contain)
                        }
                        VStack {
                            Text("Year")
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityHidden(true)
                            TextField("", text: $byear, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .border(yearInvalid ? colorScheme == .dark ? Color(.systemRed) : darkRed : .secondary)
                                .accessibilityLabel("Year")
                                .accessibilityValue(byear + errorText)
                                .accessibilityHint("YYYY, 4 digit year")
                                .autocorrectionDisabled(true)
                                .textContentType(.birthdateYear)
                                .keyboardType(.numberPad)
                                .focused($isbYearFocused)
                                .onChange(of: isbYearFocused) {oldValue, newValue in
                                    if !newValue {
                                        // Focus lost
                                        validateInputsNoAlert()
                                    }
                                }
                                .accessibilityFocused($isbYearA11yFocused)
                                .simultaneousGesture(TapGesture().onEnded {
                                    lastFocusedField = .bYear
                                })
                                .submitLabel(.done)
                                .onChange(of: byear) {oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    byear = String(filtered.prefix(4))
                                    
                                    guard let newValueLastChar = newValue.last else { return }
                                    if newValueLastChar == "\n" {
                                        if byear.count > 4 {
                                            byear.removeLast()
                                        }
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        isbYearFocused = false
                                        isbYearA11yFocused = true
                                    }
                                }
                        }.accessibilityElement(children: .contain)
                    }
                    
  
                }.frame(maxWidth: .infinity, alignment: .leading)
//                    .accessibilityElement(children: .contain)
//                    .accessibilityLabel("Birth Date")
//                    .accessibilityValue("MM/DD/YYYY")
                if errorVisible {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                        Text(errorText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.caption)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHidden(true)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                }

                Toggle("I confirm the above is accurate.", isOn: $confirmToggle)
                    .padding()
                    .bold()
                NavigationLink(destination: ThankYou(), isActive: $submitActive) {
                    Button(action: {
                        validateInputs()
                    }) {
                        HStack {
                            Image(systemName: "smiley")
                            Text("Sign Up")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                    }
                }
                .accessibilityAction() {
                    validateInputs()
                }
                .background(Color("AccentColor"))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .clipShape(.capsule)
                .alert(errorText, isPresented: $showingAlert) {
                    Button("Ok", role: .cancel) {
                        if bmonth.count != 2 && bday.count != 2 && byear.count != 4 {
                            isbMonthFocused = true
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isbMonthA11yFocused = true
                            }
                        } else if bday.count != 2 && byear.count != 4 {
                            isbDayFocused = true
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isbDayA11yFocused = true
                            }
                        } else if bmonth.count != 2 && byear.count != 4 {
                            isbMonthFocused = true
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isbMonthA11yFocused = true
                            }
                        } else if bmonth.count != 2 && bday.count != 2 {
                            isbMonthFocused = true
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isbMonthA11yFocused = true
                            }
                        } else if bmonth.count != 2 {
                            isbMonthFocused = true
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isbMonthA11yFocused = true
                            }
                        } else if bday.count != 2 {
                            isbDayFocused = true
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isbDayA11yFocused = true
                            }
                        } else if byear.count != 4 {
                            isbYearFocused = true
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isbYearA11yFocused = true
                            }
                        }
                    }
                }

            }
            .navigationTitle("Sign Up 1")
            .padding()

        }
 
    }


}

#Preview {
    NavigationStack {
        SignUp1()
    }
}

