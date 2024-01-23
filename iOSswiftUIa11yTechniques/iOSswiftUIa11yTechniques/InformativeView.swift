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
 
struct InformativeView: View {
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Informative images provide information or convey meaning to sighted users that must also be accessible to VoiceOver users. Give informative images an accessibility label either through `Label(\"text\")` or `.accessibilityLabel(\"text\")`.")
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
                Image("get10off")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .accessibilityLabel("Get 10% off")
                    .accessibilityIdentifier("goodImage")
                Text("Sign up for our newsletter.")
                DisclosureGroup("Details") {
                    VStack {
                        Text("The good informative image example uses `.accessibilityLabel(\"Get 10% off\")` to give it an accessibility label that matches the visible text shown in the image.")
                    }
                }.padding(.bottom).tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Hello,")
                    Label("World", systemImage: "globe").labelStyle(IconOnlyLabelStyle()).accessibilityRemoveTraits(.isImage)
                        .accessibilityIdentifier("goodIcon")
                    Text("!")
                }.accessibilityElement(children: .combine)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The good informative icon image example uses `Label(\"World\", systemImage: \"globe\").labelStyle(IconOnlyLabelStyle())` to give the informative icon an accessibility label that is not displayed visually. Additionally `.accessibilityRemoveTraits(.isImage)` must be used on the icon image so that the accessibility label is spoken to VoiceOver when the `HStack` is combined into a single focusable element using `.accessibilityElement(children: .combine)`.")
                    }
                }.padding(.bottom).tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                Image("get10off")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .accessibilityIdentifier("badImage")
                Text("Sign up for our newsletter.")
                DisclosureGroup("Details") {
                    VStack {
                        Text("The bad informative image example uses no `.accessibilityLabel` for the image causing VoiceOver to read the image filename* which is not meaningful. *Disable VoiceOver Text Recognition")
                    }
                }.padding(.bottom).tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Hello,")
                    Label("", systemImage: "globe").labelStyle(IconOnlyLabelStyle())
                        .accessibilityIdentifier("badIcon")
                    Text("!")
                }
                DisclosureGroup("Details") {
                    VStack {
                        Text("The bad informative icon image example uses no `Label` text to give the informative icon an accessibility label causing VoiceOver to read the image as \"Image\". VoiceOver focuses on each individual part of the line of text because the `HStack` is not combined into one focusable element.")
                    }
                }.padding(.bottom).tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .padding()
            .navigationTitle("Informative Images")
        }
     }
}
 
struct InformativeView_Previews: PreviewProvider {
    static var previews: some View {
        InformativeView()
    }
}
