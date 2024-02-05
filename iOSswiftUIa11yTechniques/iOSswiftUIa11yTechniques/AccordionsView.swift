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

struct CustomDisclosureGroupStyle<Label: View>: DisclosureGroupStyle {
    @Environment(\.colorScheme) var colorScheme

    let button: Label
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isExpanded ? "minus" : "plus").foregroundColor(Color(colorScheme == .dark ? .systemBlue : .blue))
            configuration.label.foregroundColor(Color(colorScheme == .dark ? .systemBlue : .blue)).padding(.trailing)
        }
        .accessibilityElement(children: .combine)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        }
        if configuration.isExpanded {
            configuration.content
                .disclosureGroupStyle(self)
        }
    }
}
 
struct AccordionsView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @State private var showTextBad = false
    @State private var isExpanded = false
    let ipsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Accordions hide and show content. Use `DisclosureGroup` to create an accessible accordion with expanded and collapsed states for VoiceOver. Use `DisclosureGroupStyle` to create a custom accordion style using the native `DisclosureGroup`.")
                    .padding(.bottom)
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
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                DisclosureGroup("Terms and Conditions") {
                    Text(ipsum)
                }.padding()
                    .accessibilityIdentifier("accordionGood1")
                DisclosureGroup("Details") {
                    Text("The good accordion example uses a native `DisclosureGroup`. VoiceOver speaks \"Collapsed, Double-tap to expand\" and \"Expanded, Double-tap to collapse\" as the state and hint text.")
                }.padding()
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                DisclosureGroup("Terms and Conditions") {
                    Text(ipsum)
                }.padding([.leading,.trailing])
                .disclosureGroupStyle(CustomDisclosureGroupStyle(button: Label("", systemImage: "plus")))
                DisclosureGroup("Details") {
                    Text("The second good accordion example uses a custom `DisclosureGroupStyle`. VoiceOver speaks the same \"Collapsed, Double-tap to expand\" and \"Expanded, Double-tap to collapse\" state and hint text.")
                }.padding()
                    .accessibilityIdentifier("accordionGood2")
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
                Button(action: {
                    showTextBad.toggle()
                }) {
                    HStack {
                        Text("Terms and Conditions")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: showTextBad ? "chevron.down" : "chevron.right")
                    }.padding()
                }
                .accessibilityIdentifier("accordionBad")
                if showTextBad {
                    Text(ipsum)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing])
                }
                DisclosureGroup("Details") {
                    Text("The bad accordion example is coded as a `Button` that hides and shows text. VoiceOver does not speak an expanded or collapsed state or hint. The `.foregroundColor(.blue)` also has an insufficient contrast ratio in light mode.")
                }.padding()
            }
            .navigationTitle("Accordions")
            .padding()
        }
 
    }
}
 
struct AccordionsView_Previews: PreviewProvider {
    static var previews: some View {
        AccordionsView()
    }
}
