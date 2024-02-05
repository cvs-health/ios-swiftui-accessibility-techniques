/*
   Copyright 2023 CVS Health and/or one of its affiliates

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
 
struct GroupingControlsView: View {
    @State private var getEmail = ""
    @State private var getText = ""
    @State private var getEmailBad = ""
    @State private var getTextBad = ""

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Groups of related controls need `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` applied to the group container so that VoiceOver users hear the group label spoken when first moving focus to a control in the group.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Would you like to receive text notifications?").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Yes") {
                        self.getText = "Yes"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getText == "Yes" ? Color.green : Color.black)
                    .foregroundColor(getText == "Yes" ? Color.black : Color.white)
                    .accessibility(addTraits: getText == "Yes" ? [.isSelected] : [])
                    Button("No") {
                        self.getText = "No"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getText == "No" ? Color.red : Color.black)
                    .foregroundColor(getText == "No" ? Color.black : Color.white)
                    .accessibility(addTraits: getText == "No" ? [.isSelected] : [])
                }.frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Would you like to receive text notifications?")
                Text("Do you want to join our email newsletter?").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Yes") {
                        self.getEmail = "Yes"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getEmail == "Yes" ? Color.green : Color.black)
                    .foregroundColor(getEmail == "Yes" ? Color.black : Color.white)
                    .accessibility(addTraits: getEmail == "Yes" ? [.isSelected] : [])
                    Button("No") {
                        self.getEmail = "No"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getEmail == "No" ? Color.red : Color.black)
                    .foregroundColor(getEmail == "No" ? Color.black : Color.white)
                    .accessibility(addTraits: getEmail == "No" ? [.isSelected] : [])
                }.frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Do you want to join our email newsletter?")
                DisclosureGroup("Details") {
                    Text("The good grouping controls example uses `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` on the `HStack{}` so that VoiceOver users hear the group label spoken when first moving focus to a control in the group.")
                }.padding()
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Would you like to receive text notifications?").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Yes") {
                        self.getTextBad = "Yes"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getTextBad == "Yes" ? Color.green : Color.black)
                    .foregroundColor(getTextBad == "Yes" ? Color.black : Color.white)
                    Button("No") {
                        self.getTextBad = "No"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getTextBad == "No" ? Color.red : Color.black)
                    .foregroundColor(getTextBad == "No" ? Color.black : Color.white)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Text("Do you want to join our email newsletter?").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Yes") {
                        self.getEmailBad = "Yes"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getEmailBad == "Yes" ? Color.green : Color.black)
                    .foregroundColor(getEmailBad == "Yes" ? Color.black : Color.white)
                    Button("No") {
                        self.getEmailBad = "No"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(getEmailBad == "No" ? Color.red : Color.black)
                    .foregroundColor(getEmailBad == "No" ? Color.black : Color.white)
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad grouping controls example does not use `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` on the `HStack{}` which prevents VoiceOver users from hearing the group label spoken when first moving focus to a control in the group.")
                }.padding()
            }
            .navigationTitle("Grouping Controls")
            .padding()
        }
 
    }
}
 
struct GroupingControlsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupingControlsView()
    }
}
