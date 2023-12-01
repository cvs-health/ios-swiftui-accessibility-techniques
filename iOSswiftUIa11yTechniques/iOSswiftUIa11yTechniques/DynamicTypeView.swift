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
 
struct DynamicTypeView: View {
    
    @State private var email: String = ""
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @FocusState var isInputActive: Bool

    var body: some View {
        ScrollView {
            VStack {
                Text("Dynamic Type is used to select text styles that automatically scale to larger sizes in response to the user's system text size settings. Use a `.font()` style like `.largeTitle`, `.caption`, `.headline`, `.subheadline`, etc. Or use text with no size defined and it will dynamically scale. Avoid using `.lineLimit()` which will cause text truncation. Use `axis: .vertical` to enable `TextField` value text to expand vertically rather than truncate.")
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
                Text("Email Address").frame(maxWidth: .infinity, alignment: .leading).font(.largeTitle).padding()
                    .accessibilityIdentifier("goodLabel")
                TextField(
                    "",
                    text: $email,
                    axis: .vertical
                ).font(.largeTitle).padding()
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.secondary)
                .accessibilityLabel("Email Address")
                .accessibilityIdentifier("goodTextField")
                Button(action: {
                    // Handle button action
                }) {
                    Text("Signup for newsletter")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.largeTitle)
                }
                .accessibilityIdentifier("goodButton")
                DisclosureGroup("Details") {
                    Text("The first good dynamic type example uses `.font(.largeTitle)` which scales to multiple lines when enlarged. The text field uses `axis: .vertical` to allow values larger than one line to expand vertically.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                let layout = (dynamicTypeSize > DynamicTypeSize.large) ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
                layout {
                    Link(destination: URL(string: "https://www.example.com/terms")!, label: {
                        Text("Terms of Use")
                            .underline()
                            .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                            .font(.title)
                    }).accessibilityRemoveTraits(.isButton)
                    Text(dynamicTypeSize > DynamicTypeSize.large ? "" : "|")
                    Link(destination: URL(string: "https://www.example.com/privacy")!, label: {
                        Text("Privacy Policy")
                            .underline()
                            .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                            .font(.title)
                    }).accessibilityRemoveTraits(.isButton)
                }
                DisclosureGroup("Details") {
                    Text("The second good dynamic type example uses `AnyLayout()` conditional layout to display two links in an `HStack` at smaller text sizes or a `VStack` at larger text sizes.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 3")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Lorem Ipsum").font(.largeTitle)
                DisclosureGroup("Details") {
                    Text("The third good dynamic type example uses `.font(.largeTitle)` which resizes when the user adjusts their system text size settings.")
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
                Text("Email Address").frame(maxWidth: .infinity, alignment: .leading).font(.largeTitle).lineLimit(1).padding()
                    .accessibilityIdentifier("badLabel")
                TextField(
                    "",
                    text: $email
                ).font(.largeTitle).padding()
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.secondary)
                .accessibilityIdentifier("badTextField")
                Button(action: {
                    // Handle button action
                }) {
                    Text("Signup for newsletter")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.largeTitle)
                        .lineLimit(1)
                }
                .accessibilityIdentifier("badButton")
                DisclosureGroup("Details") {
                    Text("The first bad dynamic type example uses `.lineLimit(1)` which truncates text that grows larger than one line. The text field uses the default horizontal axis causing values larger than one line to truncate.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Link(destination: URL(string: "https://www.example.com/terms")!, label: {
                        Text("Terms of Use")
                            .underline()
                            .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                            .font(.title)
                    }).accessibilityRemoveTraits(.isButton)
                    Text("|")
                        .padding()
                    Link(destination: URL(string: "https://www.example.com/privacy")!, label: {
                        Text("Privacy Policy")
                            .underline()
                            .tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                            .font(.title)
                    }).accessibilityRemoveTraits(.isButton)
                }
                DisclosureGroup("Details") {
                    Text("The second bad dynamic type example uses an `HStack` layout to display two links horizontally even at larger text sizes which reduces the readability")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 3")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Lorem Ipsum").font(.system(size: 30))
                DisclosureGroup("Details") {
                    Text("The third bad dynamic type example uses a fixed sized font `.font(.system(size: 30))` which does not resize when the user adjusts their system text size settings.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .padding()
            .navigationBarTitle("Dynamic Type")

        }
 
    }
}
 
struct DynamicTypeView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicTypeView()
    }
}
