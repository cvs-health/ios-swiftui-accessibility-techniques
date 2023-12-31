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
 
struct TogglesView: View {
    
    @State private var toggleGoodOn1 = false
    @State private var toggleGoodOn2 = false
    @State private var toggleBadOn1 = false
    @State private var toggleBadOn2 = false
    @State private var isAustinBookmarked = false
    @State private var isCupertinoBookmarked = false
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        ScrollView {
            VStack {
                Text("Toggles are used to switch between two options (also called switch controls). Use `Toggle` to create native toggle controls with an \"On\" and \"Off\" state. Use `Toggle(\"Label Text\")` to create label text. Give each `Toggle` without unique label text a specific `.accessibilityLabel`. Set the correct `.accessibilityValue` if the toggles have visible value text other than On and Off.")
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
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Toggle("Use Face ID to log in.", isOn: $toggleGoodOn1)
                    .padding()
                    .accessibilityIdentifier("toggleGood1")
                DisclosureGroup("Details") {
                    Text("The first good toggle example uses a native `Toggle` with included label text. VoiceOver reads the accessibility label and the \"On\" and \"Off\" state.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Display Mode").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Light")
                        .foregroundColor(toggleGoodOn2 ? .gray : Color(.blue))
                        .onTapGesture {
                            toggleGoodOn2 = false
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    Toggle(isOn: $toggleGoodOn2) {
                        EmptyView()
                    }
                    .accessibilityLabel("Display Mode")
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .labelsHidden()
                    .accessibilityValue(toggleGoodOn2 ? "Dark" : "Light")
                    .accessibilityIdentifier("toggleGood2")
                    Text("Dark")
                        .foregroundColor(toggleGoodOn2 ? .blue : .gray)
                        .onTapGesture {
                            toggleGoodOn2 = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(toggleGoodOn2 ? Color.black.opacity(0.9) : Color.white.opacity(0.9))
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The second good toggle example uses `.toggleStyle(SwitchToggleStyle(tint: .blue))`. The `Toggle` label is hidden with `.labelsHidden()`. The values \"Light\" and \"Dark\" are also included in the `.accessibilityValue` so that VoiceOver speaks \"Light\" and \"Dark\" instead of \"On\" and \"Off\".")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 3")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Locations").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Cupertino")
                        .frame(minWidth: 100, alignment: .leading)
                    Toggle(isOn: $isCupertinoBookmarked) {
                                Image(systemName: isCupertinoBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 24))
                            }
                            .toggleStyle(.button)
                            .clipShape(Circle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("Bookmark Cupertino Location")
                            .accessibilityIdentifier("toggleGood3a")
                }
                HStack {
                    Text("Austin")
                        .frame(minWidth: 100, alignment: .leading)
                    Toggle(isOn: $isAustinBookmarked) {
                                Image(systemName: isAustinBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 24))
                            }
                            .toggleStyle(.button)
                            .clipShape(Circle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("Bookmark Austin Location")
                            .accessibilityIdentifier("toggleGood3b")
                }
                DisclosureGroup("Details") {
                    Text("The third good toggle example uses `.toggleStyle(.button)` and includes unique and specific `.accessibilityLabel` text for each bookmark button.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                Text("Bad Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Use Face ID to log in.").frame(maxWidth: .infinity, alignment: .leading)
                    Toggle("", isOn: $toggleBadOn1)
                        .labelsHidden()
                        .accessibilityIdentifier("toggleBad1")
                }.padding()
                DisclosureGroup("Details") {
                    Text("The first bad toggle example uses `Toggle(\"\").labelsHidden()` to remove the label text. A separate `Text()` element is placed next to the toggle which is not spoken to VoiceOver as the accessibility label.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Display Mode").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Light")
                        .foregroundColor(toggleGoodOn2 ? .gray : Color(.blue))
                    Toggle(isOn: $toggleGoodOn2) {
                        EmptyView()
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .labelsHidden()
                    .accessibilityIdentifier("toggleBad2")
                    Text("Dark")
                        .foregroundColor(toggleGoodOn2 ? .blue : .gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(toggleGoodOn2 ? Color.black.opacity(0.9) : Color.white.opacity(0.9))
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The second bad toggle example hides its label using `.labelsHidden()` and does not provide an `.accessibilityLabel`. The values \"Light\" and \"Dark\" are not included in the `.accessibilityValue` so VoiceOver incorrectly speaks \"On\" and \"Off\" instead of \"Light\" and \"Dark\".")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 3")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Locations").frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Cupertino")
                        .frame(minWidth: 100, alignment: .leading)
                    Toggle(isOn: $isCupertinoBookmarked) {
                                Image(systemName: isCupertinoBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 24))
                            }
                            .toggleStyle(.button)
                            .clipShape(Circle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("toggleBad3a")
                }
                HStack {
                    Text("Austin")
                        .frame(minWidth: 100, alignment: .leading)
                    Toggle(isOn: $isAustinBookmarked) {
                                Image(systemName: isAustinBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 24))
                            }
                            .toggleStyle(.button)
                            .clipShape(Circle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("toggleBad3b")
                }
                DisclosureGroup("Details") {
                    Text("The third bad toggle example uses `.toggleStyle(.button)` and does not include unique and specific `.accessibilityLabel` text for each bookmark button.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .padding()
            .navigationBarTitle("Toggles")

        }
 
    }
}
 
struct TogglesView_Previews: PreviewProvider {
    static var previews: some View {
        TogglesView()
    }
}
