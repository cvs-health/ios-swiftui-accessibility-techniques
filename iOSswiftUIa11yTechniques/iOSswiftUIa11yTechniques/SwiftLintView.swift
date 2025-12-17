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
 
struct SwiftLintView: View {

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("SwiftLint can be used to lint your code for accessibility issues by turning on the two opt-in accessibility rules, `accessibility_label_for_image` and `accessibility_trait_for_button`. You can enable these rules by editing your project's `.swiftlint.yml` file to include them in the `opt_in_rules` list. See the link below, iOS Automation Accessibility testing at Reddit, to learn more. The bad examples below will trigger SwiftLint Warnings.")
                    .padding(.bottom)
                Link(destination: URL(string: "https://www.reddit.com/r/RedditEng/comments/1lzrsg9/ios_automation_accessibility_testing_at_reddit/")!, label: {
                    Text("iOS Automation Accessibility testing at Reddit")
                        .underline()
                }).accessibilityRemoveTraits(.isButton)
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
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .accessibilityHidden(true)
                Text("Hello, world!")
                Image("get10off")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .accessibilityLabel("Get 10% off")
                Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .accessibilityLabel("1 Star")
                Button {
                            print("Tapped")
                        } label: {
                            Image(systemName: "trash")
                        }
                        .accessibilityLabel("Delete")
                Circle()
                           .fill(Color.blue)
                           .frame(width: 50, height: 50)
                           .onTapGesture {
                               print("Tapped circle")
                           }
                           .accessibilityAddTraits(.isButton)
                           .accessibilityLabel("Blue Circle")
                DisclosureGroup("Details") {
                    Text("The good functional and informative images have an `.accessibilityLabel`. The decorative image uses `.accessibilityHidden(true)`. All the good images pass the `accessibility_label_for_image` SwiftLint rule. The good example circle button uses a tap gesture and has the `.isButton` accessibility trait causing it to pass the `accessibility_trait_for_button` SwiftLint rule.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
                Image("get10off")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                Button {
                            print("Tapped")
                        } label: {
                            Image(systemName: "trash")
                        }
                Circle()
                           .fill(Color.blue)
                           .frame(width: 50, height: 50)
                           .onTapGesture {
                               print("Tapped circle")
                           }
                           .accessibilityElement()
                DisclosureGroup("Details") {
                    Text("The bad example images are missing either `.accessibilityLabel` or `.accessibilityHidden(true)` causing them to fail the `accessibility_label_for_image` SwiftLint rule. The bad example circle button uses a tap gesture but has no `.isButton` accessibility trait causing it to fail the `accessibility_trait_for_button` SwiftLint rule.")
                }.accessibilityHint("Bad Example")

            }
            .navigationTitle("SwiftLint")
            .padding()
        }
 
    }
}

#Preview {
    NavigationStack {
        SwiftLintView()
    }
}
