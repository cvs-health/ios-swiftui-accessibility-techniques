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
 
struct CheckboxesView: View {
    
    @State private var isChecked = false
    @State private var isEmailChecked = false
    @State private var isPhoneChecked = false
    @State private var isTextChecked = false
    @State private var isCheckedBad = false
    @State private var isEmailCheckedBad = false
    @State private var isPhoneCheckedBad = false
    @State private var isTextCheckedBad = false
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        ScrollView {
            VStack {
                Text("SwiftUI has no native checkbox control or accessibility trait for VoiceOver. Code checkboxes as `Toggle` elements with a custom `.toggleStyle`. Use `Toggle(\"Label Text\")` to create label text. Use `.accessibilityValue(isChecked ? \"Checked\" : \"Unchecked\")` to create custom value text for VoiceOver. Checkbox groups need an accessibility label for the group which matches the visible group label text. Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` on the checkbox group container so that VoiceOver users hear the group label spoken when first moving focus to a checkbox in the group.")
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
                Text("Good Example Single Checkbox")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Toggle(isOn: $isChecked) {
                            Text("Accept Terms")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                          }
                        .toggleStyle(CheckboxToggleStyle())
                        .accessibilityValue(isChecked ? "Checked" : "Unchecked")
                        .accessibilityIdentifier("checkboxGood")
                        .frame(maxWidth: 200)
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good single checkbox example uses a native `Toggle` with a custom `.toggleStyle` to look like a square checkbox control. Additionally `.accessibilityValue(isChecked ? \"Checked\" : \"Unchecked\")` is used to create custom value text for VoiceOver. VoiceOver reads the \"Switch button\" trait and \"Checked\" and \"Unchecked\" values.")
                }.padding(.bottom).accessibilityHint("Good Example Single Checkbox")
                Text("Good Example Checkbox Group")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Preferred contact method(s):").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    VStack {
                        Toggle(isOn: $isEmailChecked) {
                                Text("Email")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                              }
                            .toggleStyle(CheckboxToggleStyle())
                            .accessibilityValue(isEmailChecked ? "Checked" : "Unchecked")
                        Toggle(isOn: $isPhoneChecked) {
                                Text("Phone")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                              }
                            .toggleStyle(CheckboxToggleStyle())
                            .accessibilityValue(isPhoneChecked ? "Checked" : "Unchecked")
                        Toggle(isOn: $isTextChecked) {
                                Text("Text")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                              }
                            .toggleStyle(CheckboxToggleStyle())
                            .accessibilityValue(isTextChecked ? "Checked" : "Unchecked")
                    }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Preferred contact method(s):")
                        .frame(width: 200)
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good checkbox group example uses `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` on the checkbox group container so that VoiceOver users hear the group label spoken when first moving focus to a checkbox in the group.")
                }.padding(.bottom).accessibilityHint("Good Example Checkbox Group")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Single Checkbox")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Button {
                            isCheckedBad.toggle()
                        } label: {
                            if isCheckedBad {
                                HStack {
                                    Text("Accept Terms")
                                    Image(systemName: "checkmark.square")
                                      .resizable()
                                      .frame(width: 24, height: 24)
                                }
                            } else {
                                HStack {
                                    Text("Accept Terms")
                                    Image(systemName: "square")
                                      .resizable()
                                      .frame(width: 24, height: 24)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        .accessibilityIdentifier("checkboxBad")
                    Spacer()
                    Spacer()
                }
                DisclosureGroup("Details") {
                    Text("The bad single checkbox example uses a `Button` that changes an `Image` when tapped to look like a square checkbox control. VoiceOver reads a \"Button\" trait and does not read \"Checked\" or \"Unchecked\" values.")
                }.padding(.bottom).accessibilityHint("Bad Example Single Checkbox")
                Text("Bad Example Checkbox Group")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Preferred contact method(s):").frame(maxWidth: .infinity, alignment: .leading)
                VStack {
                    Toggle(isOn: $isEmailCheckedBad) {
                            Text("Email")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                          }
                        .toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: $isPhoneCheckedBad) {
                            Text("Phone")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                          }
                        .toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: $isTextCheckedBad) {
                            Text("Text")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                          }
                        .toggleStyle(CheckboxToggleStyle())
                }.padding(.trailing, 150)
                DisclosureGroup("Details") {
                    Text("The bad checkbox group example has no group accessibility label on the checkbox group container so VoiceOver users don't hear the group label spoken when first moving focus to a checkbox in the group.")
                }.accessibilityHint("Bad Example Checkbox Group")
            }
            .padding()
            .navigationTitle("Checkboxes")

        }
 
    }
}
 
struct CheckboxesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CheckboxesView()
        }
    }
}


struct CheckboxToggleStyle: ToggleStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    HStack {
      configuration.label
      Spacer()
      Image(systemName: configuration.isOn ? "checkmark.square" : "square")
        .resizable()
        .frame(width: 24, height: 24)
    }
    .onTapGesture { configuration.isOn.toggle() }
  }
}
